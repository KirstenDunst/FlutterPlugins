import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:package_info/package_info.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';
import 'package:vm_service/utils.dart';

import 'version.dart';

class VmHelper {
  VmHelper._privateConstructor();

  static final VmHelper _instance = VmHelper._privateConstructor();

  static VmHelper get instance => _instance;

  late VmService serviceClient;
  late Version _protocolVersion;
  Version? _dartIoVersion;
  VM? vm;

  // flutter版本
  String _flutterVersion = '';

  // 各Isolate内存使用情况
  Map<IsolateRef, MemoryUsage> memoryInfo = {};
  bool connected = false;
  AllocationProfile? allocationProfile;
  PackageInfo? packageInfo;

  Map<String, List<String>> get registeredMethodsForService =>
      _registeredMethodsForService;
  final Map<String, List<String>> _registeredMethodsForService = {};

  Future<void> startConnect() async {
    var info = await Service.getInfo();
    if (info.serverUri == null) {
      if (kDebugMode) {
        print("service  protocol url is null,start vm service fail");
      }
      return;
    }
    Uri uri = convertToWebSocketUrl(serviceProtocolUrl: info.serverUri!);
    serviceClient = await vmServiceConnectUri(uri.toString(), log: StdoutLog());
    if (kDebugMode) {
      print('socket connected in service $info');
    }
    connected = true;

    vm = await serviceClient.getVM();
    vm!.isolates?.forEach((element) async {
      var memoryUsage = await serviceClient.getMemoryUsage(element.id!);
      memoryInfo[element] = memoryUsage;
    });
    loadExtensionService();
    PackageInfo.fromPlatform().then((value) => packageInfo = value);
  }

  // 获取flutter版本，目前比较鸡肋，需要借助devtools向vmservice注册的服务来获取,flutter 未 attach的情况下无法使用。
  void loadExtensionService() async {
    final serviceStreamName = await this.serviceStreamName;
    serviceClient.onEvent(serviceStreamName).listen(handleServiceEvent);
    final streamIds = [
      EventStreams.kDebug,
      EventStreams.kExtension,
      EventStreams.kGC,
      EventStreams.kIsolate,
      EventStreams.kLogging,
      EventStreams.kStderr,
      EventStreams.kStdout,
      EventStreams.kTimeline,
      EventStreams.kVM,
      serviceStreamName,
    ];

    await Future.wait(
      streamIds.map((String id) async {
        try {
          await serviceClient.streamListen(id);
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }),
    );
    resolveFlutterVersion();
  }

  String get flutterVersion {
    if (_flutterVersion != '') {
      return _flutterVersion;
    } else {
      return 'Flutter Attach后可获取版本号';
    }
  }

  Future<String> get serviceStreamName async =>
      (await isProtocolVersionSupported(SemanticVersion(major: 3, minor: 22)))
      ? 'Service'
      : '_Service';

  Future<bool> isProtocolVersionSupported(
    SemanticVersion supportedVersion,
  ) async {
    _protocolVersion = await serviceClient.getVersion();
    return isProtocolVersionSupportedNow(supportedVersion);
  }

  bool isProtocolVersionSupportedNow(SemanticVersion supportedVersion) {
    return _versionSupported(_protocolVersion, supportedVersion);
  }

  bool _versionSupported(Version version, SemanticVersion supportedVersion) {
    return SemanticVersion(
      major: version.major ?? 0,
      minor: version.minor ?? 0,
    ).isSupported(supportedVersion);
  }

  Future<bool> isDartIoVersionSupported(
    SemanticVersion supportedVersion,
    String isolateId,
  ) async {
    _dartIoVersion ??= await getDartIOVersion(isolateId);
    return _versionSupported(_dartIoVersion!, supportedVersion);
  }

  Future<Version> getDartIOVersion(String isolateId) =>
      serviceClient.getDartIOVersion(isolateId);

  void handleServiceEvent(Event e) {
    if (e.kind == EventKind.kServiceRegistered) {
      final serviceName = e.service;
      _registeredMethodsForService
          .putIfAbsent(serviceName ?? '', () => [])
          .add(e.method ?? '');
      if (_flutterVersion == '' && serviceName == 'flutterVersion') {
        resolveFlutterVersion();
      }
    }

    if (e.kind == EventKind.kServiceUnregistered) {
      final serviceName = e.service;
      _registeredMethodsForService.remove(serviceName);
    }
  }

  void resolveFlutterVersion() {
    callMethod('flutterVersion')?.then(
      (value) =>
          _flutterVersion = FlutterVersion.parse(value.json ?? {}).version,
    );
  }

  Future<Response>? callMethod(String method) {
    if (registeredMethodsForService.containsKey(method)) {
      return (serviceClient.callMethod(
        registeredMethodsForService[method]?.last ?? '',
        isolateId: vm?.isolates?.first.id,
      ));
    }
    return null;
  }

  void updateMemoryUsage() {
    if (connected) {
      for (var element in vm?.isolates ?? []) {
        serviceClient
            .getMemoryUsage(element.id)
            .then((value) => memoryInfo[element] = value);
      }
    }
  }

  Future<void> dumpAllocationProfile() async {
    if (connected) {
      serviceClient
          .getAllocationProfile(vm!.isolates!.first.id!)
          .then((value) => allocationProfile = value);
    }
  }

  Future<void> disConnect() async {
    if (kDebugMode) {
      print('waiting for client to shut down...');
    }
    serviceClient.dispose();
    await serviceClient.onDone;
    connected = false;
    if (kDebugMode) {
      print('service client shut down');
    }
  }
}

class StdoutLog extends Log {
  @override
  void warning(String message) {
    if (kDebugMode) {
      print(message);
    }
  }

  @override
  void severe(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
}
