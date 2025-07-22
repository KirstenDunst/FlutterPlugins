import 'dart:async';
import 'dart:io';
import 'package:csx_util/extension/string_ext.dart';
import 'package:csx_util/util/shared_preferences_util.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../interapter/response_interceptor.dart';
import '../model/dio_http_config.dart';
import '../model/shared_preference_key.dart';
import '../model/wrapped_response.dart';

///基于hyx业务的网络请求工具封装
class DioHttpUtil {
  final _rest = Dio();
  HttpConfig get httpConfig => _httpConfig;
  late HttpConfig _httpConfig;
  ErrorModel get errorModel => _errorModel;
  late ErrorModel _errorModel;
  String? _tag;
  Function(String)? _logCall;

  ///http异常（DioError）
  final StreamController<WrappedResponse> httpExceptionStream =
      StreamController.broadcast();

  ///业务异常
  final StreamController<WrappedResponse> businessExceptionStream =
      StreamController.broadcast();

  String _proxy = '';
  String get proxy => _proxy;
  set proxy(String value) {
    if (_proxy != _baseUrl) {
      _proxy = value;
      SharedPreferenceService.instance.set(HTTPSharedPreKey.proxy, value);
      debugPrint('设置了新的代理 $value');
    }
  }

  String _baseUrl = '';
  String get baseUrl => _baseUrl;
  set baseUrl(String value) {
    if (value != _baseUrl) {
      _baseUrl = value;
      SharedPreferenceService.instance.set<String>(
        HTTPSharedPreKey.baseUrl,
        value,
      );
      _rest.options.baseUrl = baseUrl;
      debugPrint('设置了新的baseUrl');
    }
  }

  DioHttpUtil._internal() {
    _errorModel = ErrorModel.normal;
  }

  factory DioHttpUtil({String? tag}) {
    var instance = _instanceMap[tag ?? 'default'];
    if (instance == null) {
      instance = DioHttpUtil._internal();
      instance._tag = tag;
      _instanceMap[tag ?? 'default'] = instance;
    }
    return instance;
  }

  static void removeInstance({required String tag}) {
    debugPrint('removeInstance _tag = $tag');
    _instanceMap.remove(tag);
  }

  static final Map<String, DioHttpUtil> _instanceMap = {};

  initConfig(
    HttpConfig config, {
    bool Function(X509Certificate cert, String host, int port)?
    badCertificateCallback,
    Function(String)? logCall,
  }) async {
    _httpConfig = config;
    debugPrint('_httpConfig = $_httpConfig');

    ///首先读取SharedPreference中自定义的baseUrl
    var configUrl = await SharedPreferenceService.instance.get<String>(
      HTTPSharedPreKey.baseUrl,
      '',
    );

    ///baseUrl解析
    if (configUrl.isNotNullOrEmpty) {
      _baseUrl = configUrl;
    } else {
      _baseUrl = config.defaultBaseUrl;
    }

    ///Base Options
    _rest.transformer = BackgroundTransformer();
    _rest.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: _httpConfig.connectTimeout,
      sendTimeout: _httpConfig.sendTimeout,
      receiveTimeout: _httpConfig.receiveTimeout,
      contentType: Headers.jsonContentType,
    );

    ///代理配置
    _proxy = await SharedPreferenceService.instance.get<String>(
      HTTPSharedPreKey.proxy,
      '',
    );
    var httpClientAdapter = _rest.httpClientAdapter as IOHttpClientAdapter;
    httpClientAdapter.createHttpClient = () {
      debugPrint('HttpUtil, onHttpClientCreate');
      var client = HttpClient();
      client.badCertificateCallback = badCertificateCallback;
      client.findProxy = (url) {
        return validateProxy(proxy) ? 'PROXY $proxy' : 'DIRECT';
      };
      return client;
    };

    //基础拦截器配置 增加tag后，此部分功能需要调整到外部使用者调用
    addInterceptor(DioResponseInterceptor());
  }

  void uploadErrorModel(ErrorModel model) => _errorModel = model;

  ///添加自定义拦截器
  void addInterceptor(Interceptor interceptor, {int? index}) {
    if (index == null || index < 0) {
      _rest.interceptors.add(interceptor);
    } else {
      _rest.interceptors.insert(index, interceptor);
    }
  }

  ///不对response按照[WrappedResponse]格式解析，返回原始response
  Future<Response> originGet(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return doOriginRequest(
      _rest.get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  ///不对response按照[WrappedResponse]格式解析，返回原始response
  Future<Response> originPost(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return doOriginRequest(
      _rest.post(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  ///不对response按照[WrappedResponse]格式解析，返回原始response
  Future<Response> doOriginRequest(Future<Response> task) async {
    try {
      return await task;
    } catch (error, stack) {
      _logCall?.call('HttpUtil error, doOriginRequest $error $stack');
      rethrow;
    }
  }

  Options _composeWrappedOptions(Options? options, bool? collectException) {
    var composeOptions = options ?? Options();
    if (composeOptions.extra != null) {
      composeOptions.extra!['wrapped'] = true;
      composeOptions.extra!['collectException'] =
          collectException ?? _httpConfig.collectException;
    } else {
      composeOptions.extra = {'wrapped': true};
      composeOptions.extra!['collectException'] =
          collectException ?? _httpConfig.collectException;
    }
    return composeOptions;
  }

  ///[collectException] false代表本次请求时，异常不会被加入统一的异常流
  Future<WrappedResponse> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool? collectException,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return doRequest(
      _rest.get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: _composeWrappedOptions(options, collectException),
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  ///[collectException] false代表本次请求时，异常不会被加入统一的异常流
  Future<WrappedResponse> post(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool? collectException,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return doRequest(
      _rest.post(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: _composeWrappedOptions(options, collectException),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  ///[collectException] false代表本次请求时，异常不会被加入统一的异常流
  Future<WrappedResponse> postFormUrlencoded(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool? collectException,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return doRequest(
      _rest.post(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: _composeWrappedOptions(options, collectException)
          ..contentType = Headers.formUrlEncodedContentType,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  ///[collectException] false代表本次请求时，异常不会被加入统一的异常流
  Future<WrappedResponse> put(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool? collectException,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return doRequest(
      _rest.put(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: _composeWrappedOptions(options, collectException),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  ///[collectException] false代表本次请求时，异常不会被加入统一的异常流
  Future<WrappedResponse> patch(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool? collectException,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return doRequest(
      _rest.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: _composeWrappedOptions(options, collectException),
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      ),
    );
  }

  ///[collectException] false代表本次请求时，异常不会被加入统一的异常流
  Future<WrappedResponse> delete(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool? collectException,
    CancelToken? cancelToken,
  }) async {
    return doRequest(
      _rest.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        options: _composeWrappedOptions(options, collectException),
      ),
    );
  }

  Future<WrappedResponse> doRequest(Future<Response> task) async {
    try {
      var response = await task;
      return response.data as WrappedResponse;
    } on DioException catch (err) {
      var wrappedResponse = err.response?.data as WrappedResponse?;
      if (wrappedResponse != null) {
        throw wrappedResponse;
      } else {
        throw WrappedResponse(
          code: err.response?.statusCode,
          success: false,
          msg: _httpConfig.errorHandler.parseErrorMessage(err, tag: _tag),
        );
      }
    } catch (error, stack) {
      _logCall?.call('HttpUtil error, doRequest $error $stack');
      throw WrappedResponse(code: -1, success: false, msg: error.toString());
    }
  }

  void dispose() {
    httpExceptionStream.close();
    businessExceptionStream.close();
  }
}

bool validateProxy(String proxy) {
  final reg = RegExp(r'[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}:[0-9]{4}');
  return reg.hasMatch(proxy);
}
