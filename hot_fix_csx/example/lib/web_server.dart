/*
 * @Author: Cao Shixin
 * @Date: 2021-10-15 17:17:50
 * @LastEditors: Cao Shixin
 * @LastEditTime: 2022-04-20 09:13:56
 * @Description: 
 */
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_utils/flutter_utils.dart';
import 'package:jaguar/jaguar.dart';

class WebServer {
  factory WebServer() => _getInstance();
  static WebServer get instance => _getInstance();
  static WebServer? _instance;
  static WebServer _getInstance() {
    _instance ??= WebServer._internal();
    return _instance!;
  }

  String get localWebUrl => 'http://$_host:$_port/?page=';
  String get rootPath => _directoryPath;
  ValueNotifier<bool> get onServerLoadingNotifier => _onServerLoadingNotifier;
  late String _directoryPath, _host;
  late int _port;
  late ValueNotifier<bool> _onServerLoadingNotifier;

  WebServer._internal() {
    _directoryPath = '';
    _port = 8865;
    _host = Platform.isAndroid ? 'localhost' : '127.0.0.1';
    _onServerLoadingNotifier = ValueNotifier(true);
  }

  set directory(String path) {
    _directoryPath = path;
  }

  ///开启服务
  Future startServer() async {
    LogUtil.logI('startServer: ${_server != null}');
    if (_server != null) return;
    LogUtil.logI('startServer:dir=$_directoryPath');
    final directory = Directory(_directoryPath);
    _onServerLoadingNotifier.value = true;
    if (!await directory.exists()) {
      LogUtil.logI('web directory not exists:$_directoryPath');
      throw Exception('web directory not exists');
    }
    if (kDebugMode) print(directory.path);
    _jaguarServer.staticFiles('*', directory);
    await _jaguarServer.serve(
        logRequests: kDebugMode,
        idleTimeout: null,
        sessionTimeout: 24 * 3600 //24 hours
        );
    _onServerLoadingNotifier.value = false;
    LogUtil.logI('startServer success');
  }

  ///关闭服务
  Future stopServer() async {
    LogUtil.logI('stopServer');
    await _server?.close();
    _server = null;
  }

  Future restartServer() async {
    LogUtil.logD('restartServer');
    if (_server == null) {
      startServer();
      return;
    }
    _onServerLoadingNotifier.value = true;
    await _jaguarServer.restart(logRequests: kDebugMode);
    _onServerLoadingNotifier.value = false;
  }

  Jaguar? _server;
  Jaguar get _jaguarServer {
    _server ??= Jaguar(port: _port, autoCompress: true);
    return _server!;
  }
}
