import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../apm.dart';
import '../csx_dokit.dart';
import '../kit.dart';
import '../page/dokit_app.dart';
import '../utils/time_util.dart';
import 'http_mock.dart';
import 'http_mock_edit.dart';

class HttpInfo1 implements IInfo {
  HttpInfo1(this.uri, this.method, this.requestId, {this.isMock = false})
      : startTimestamp = DateTime.now().millisecondsSinceEpoch;

  final Uri? uri;
  final String method;
  final String requestId;
  final int startTimestamp;

  String? error;
  HttpRequest request = HttpRequest();
  HttpResponse? response;
  bool isMock;

  bool expand = false;

  @override
  String getValue() {
    var subMsg = '';
    if (error != null) {
      subMsg = 'Error:$error';
    } else {
      subMsg =
          'Duration:${response == null ? '' : '${response!.endTimestamp - startTimestamp}'}\nRequest:${request.toString()}\n\nResponse:${response.toString()}';
    }
    return 'Uri:$uri\nMethod:$method\n$subMsg';
  }
}

class HttpRequest {
  final Map<String, dynamic>? header;
  final dynamic body;
  final Map<String, dynamic>? queryParameters;

  HttpRequest({this.header, this.body, this.queryParameters});

  @override
  String toString() {
    return 'HEADER: ${jsonEncode(header)}\nBODY: ${(body is Map || body is List) ? jsonEncode(body) : body.toString()}\nQUERY:${jsonEncode(queryParameters)}';
  }
}

class HttpResponse {
  final int? statusCode;
  final Map<String, dynamic>? header;
  final int endTimestamp;
  final dynamic data;

  HttpResponse({this.statusCode, this.data, this.header})
      : endTimestamp = DateTime.now().millisecondsSinceEpoch;

  @override
  String toString() {
    return 'statusCode: $statusCode\nDATA: $data';
  }
}

class HttpKit extends ApmKit {
  @override
  Widget createDisplayPage() {
    return HttpPage();
  }

  Function? listener;

  @override
  String getIcon() {
    return 'assets/images/dk_net_monitor.png';
  }

  @override
  IStorage createStorage() {
    return CommonStorage(maxCount: 60);
  }

  @override
  String getKitName() {
    return ApmKitName.kitHttp;
  }

  @override
  void start() {
    // final origin = HttpOverrides.current;
    // HttpOverrides.global = DoKitHttpOverrides(origin);
  }

  @override
  void stop() {}

  void registerListener(Function listener) {
    this.listener = listener;
  }

  void unregisterListener() {
    listener = null;
  }
}

class HttpPage extends StatefulWidget {
  const HttpPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return HttpPageState();
  }
}

class HttpPageState extends State<HttpPage> {
  late ScrollController _offsetController;
  static bool showSystemChannel = true;

  Future<void> _listener() async {
    if (!mounted) {
      return;
    }
    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      await SchedulerBinding.instance.endOfFrame;
      if (!mounted) {
        return;
      }
    }
    setState(() {
      // 如果正在查看，就不自动滑动到底部
      if (_offsetController.offset < 10) {
        _offsetController.jumpTo(0);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _offsetController = ScrollController();
    ApmKitManager.instance
        .getKit<HttpKit>(ApmKitName.kitHttp)
        ?.registerListener(_listener);
  }

  @override
  void dispose() {
    super.dispose();
    ApmKitManager.instance
        .getKit<HttpKit>(ApmKitName.kitHttp)
        ?.unregisterListener();
  }

  @override
  Widget build(BuildContext context) {
    final items = ApmKitManager.instance
            .getKit<HttpKit>(ApmKitName.kitHttp)
            ?.getStorage()
            .getAll()
            .reversed
            .toList() ??
        [];
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xff337cc4), width: 1),
                borderRadius: BorderRadius.circular(2), // 也可控件一边圆角大小
              ),
              margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
              padding: const EdgeInsets.all(2),
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  setState(() {
                    ApmKitManager.instance
                        .getKit<HttpKit>(ApmKitName.kitHttp)
                        ?.getStorage()
                        .clear();
                  });
                },
                child: const Text(
                  '清除本页数据',
                  style: TextStyle(color: Color(0xff333333), fontSize: 12),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xff337cc4), width: 1),
                borderRadius: BorderRadius.circular(2), // 也可控件一边圆角大小
              ),
              margin: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
              padding: const EdgeInsets.all(2),
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _offsetController.jumpTo(0),
                child: const Text(
                  '滑动到底部',
                  style: TextStyle(color: Color(0xff333333), fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            alignment: Alignment.topCenter,
            color: const Color(0xfff5f6f7),
            child: Scrollbar(
              scrollbarOrientation: ScrollbarOrientation.right,
              thumbVisibility: true,
              controller: _offsetController,
              child: ListView.builder(
                controller: _offsetController,
                itemCount: items.length,
                reverse: true,
                padding: const EdgeInsets.only(
                  left: 4,
                  right: 4,
                  bottom: 0,
                  top: 8,
                ),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) =>
                    HttpItemWidget(
                  item: items[index] as HttpInfo1,
                  index: index,
                  isLast: index == items.length - 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class HttpItemWidget extends StatefulWidget {
  const HttpItemWidget({
    super.key,
    required this.item,
    required this.index,
    required this.isLast,
  });

  final HttpInfo1 item;
  final int index;
  final bool isLast;

  @override
  State<StatefulWidget> createState() {
    return _HttpItemWidgetState();
  }
}

class _HttpItemWidgetState extends State<HttpItemWidget> {
  String getCode() {
    return widget.item.response?.statusCode.toString() ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    var urlStr = widget.item.uri.toString();
    var requestHeader = widget.item.request.header == null
        ? null
        : jsonEncode(widget.item.request.header);
    var requestQuery = widget.item.request.queryParameters == null
        ? null
        : jsonEncode(widget.item.request.queryParameters);
    var requestTempBody = widget.item.request.body;
    String? requestBody = requestTempBody == null
        ? null
        : ((requestTempBody is Map || requestTempBody is List)
            ? jsonEncode(requestTempBody)
            : requestTempBody.toString());
    var responseHeader = widget.item.response?.header == null
        ? null
        : jsonEncode(widget.item.response?.header);
    var responseData = widget.item.response?.data;
    String? responseStr = responseData == null
        ? null
        : ((responseData is Map || responseData is List)
            ? jsonEncode(widget.item.response?.data)
            : widget.item.response!.data.toString());
    return GestureDetector(
        onLongPress: () async {
          var text =
              'Uri:$urlStr\n\nRequest:\nHeader:$requestHeader\nQuery:$requestQuery\nBody:$requestBody\n\nResponse:\nx-request-id:${widget.item.response?.header?['x-request-id']}\n$responseStr';
          await Clipboard.setData(
            ClipboardData(
              text: text,
            ),
          );
          CsxDokit.i.toastC('请求已拷贝至剪贴板');
        },
        onTap: () {
          setState(() {
            widget.item.expand = !widget.item.expand;
          });
        },
        child: Stack(
          children: [
            Card(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width - 80,
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom: 12,
                    ),
                    child: RichText(
                      maxLines: widget.item.expand ? 9999 : 7,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: <InlineSpan>[
                          if (widget.item.isMock)
                            WidgetSpan(
                              child: Container(
                                height: 11,
                                margin: const EdgeInsets.only(right: 4),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    color: Colors.orange),
                                child: Text(
                                  '[Mock]',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: Color(0xffffffff),
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          TextSpan(
                            text:
                                '[${TimeUtils.toTimeString(widget.item.startTimestamp)}]',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xff333333),
                              height: 1.2,
                            ),
                          ),
                          WidgetSpan(
                            child: Container(
                              height: 11,
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.only(left: 6, right: 6),
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(2),
                                ),
                                color: [
                                  200,
                                  0,
                                ].contains(widget.item.response?.statusCode)
                                    ? const Color(0xff337cc4)
                                    : const Color(0xffd0607e),
                              ),
                              child: Text(
                                getCode(),
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Color(0xffffffff),
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                          TextSpan(
                            text: '  ${widget.item.method}'
                                '  Cost:${(widget.item.response?.endTimestamp ?? 0) > 0 ? ('${widget.item.response!.endTimestamp - widget.item.startTimestamp}ms') : '-'} ',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xff666666),
                              height: 1.5,
                            ),
                          ),
                          const TextSpan(
                            text: '\nUri: ',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xff333333),
                              height: 1.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: urlStr,
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.5,
                              color: Color(0xff666666),
                            ),
                          ),
                          const TextSpan(
                            text: '\nRequestHeader: ',
                            style: TextStyle(
                              height: 1.5,
                              fontSize: 10,
                              color: Color(0xff333333),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: requestHeader,
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.5,
                              color: Color(0xff666666),
                            ),
                          ),
                          const TextSpan(
                            text: '\nParameters: ',
                            style: TextStyle(
                              fontSize: 10,
                              height: 1.5,
                              color: Color(0xff333333),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: requestQuery,
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.5,
                              color: Color(0xff666666),
                            ),
                          ),
                          const TextSpan(
                            text: '\nRequestBody: ',
                            style: TextStyle(
                              fontSize: 10,
                              height: 1.5,
                              color: Color(0xff333333),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: requestBody,
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.5,
                              color: Color(0xff666666),
                            ),
                          ),
                          const TextSpan(
                            text: '\nResponseHeader: ',
                            style: TextStyle(
                              height: 1.5,
                              fontSize: 10,
                              color: Color(0xff333333),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: responseHeader,
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.5,
                              color: Color(0xff666666),
                            ),
                          ),
                          const TextSpan(
                            text: '\nResponse: ',
                            style: TextStyle(
                              fontSize: 10,
                              height: 1.5,
                              color: Color(0xff333333),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: responseStr,
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.5,
                              color: Color(0xff666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Image.asset(
                    widget.item.expand
                        ? 'assets/images/dk_channel_expand_h.png'
                        : 'assets/images/dk_channel_expand_n.png',
                    package: dkPackageName,
                    height: 14,
                    width: 9,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: GestureDetector(
                //转到添加mock处理页面
                onTap: () => enterNewOverLayer(
                  (entry) => EditMockPage(
                    mockModel: MockModel(
                        '',
                        responseStr ?? '',
                        MockFilterModel(
                          widget.item.uri?.path ?? '',
                          filterAskType: HttpAskType.parse(widget.item.method),
                          filterQueryParam: widget.item.request.queryParameters,
                          filterBodyParam: requestBody,
                          bodyParamType: MockLocalTool.parseDataForParamType(
                                  requestTempBody) ??
                              ParamType.json,
                        ),
                        paramType: MockLocalTool.parseDataForParamType(
                                widget.item.response?.data) ??
                            ParamType.json),
                    saveCallBack: (mockModel) {
                      ApmKitManager.instance
                          .getKit<HttpMockKit>(ApmKitName.kitMock)
                          ?.save(mockModel);
                      MockLocalTool.editData();
                      entry?.remove();
                      CsxDokit.i.toastC('添加成功,请前往Mock分组查看');
                    },
                  ),
                ),
                child: Icon(
                  Icons.data_object,
                  size: 20,
                  color: Colors.blueAccent,
                ),
              ),
            )
          ],
        ));
  }
}
