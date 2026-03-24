import 'dart:async';

import 'package:doraemonkit_csx/apm/version.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info/package_info.dart';
import 'package:vm_service/vm_service.dart';

import 'vm_service_wrapper.dart';

class VmHelper {
  VmHelper._privateConstructor();

  static final VmHelper _instance = VmHelper._privateConstructor();

  static VmHelper get instance => _instance;

  // 各Isolate内存使用情况
  final memoryInfo = <IsolateRef, MemoryUsage>{};
  AllocationProfile? allocationProfile;
  PackageInfo? packageInfo;

  // flutter版本
  String _flutterVersion = '';

  VM? get vm => VMServiceWrapper.instance.vm;

  Future<void> resolveVMInfo() async {
    if (!VMServiceWrapper.instance.connected) {
      return;
    }
    await PackageInfo.fromPlatform().then((value) => packageInfo = value);
    updateMemoryUsage();
    updateFlutterVersion();
    updateAllocationProfile();
  }

  String get flutterVersion {
    if (!VMServiceWrapper.instance.connected) {
      return 'Flutter Attach后可获取版本号';
    }
    if (_flutterVersion != '') {
      return _flutterVersion;
    } else {
      return 'Flutter Attach后可获取版本号';
    }
  }

  void updateMemoryUsage() {
    var mainId = VMServiceWrapper.instance.main?.id;
    if (!VMServiceWrapper.instance.connected || mainId == null) {
      return;
    }
    VMServiceWrapper.instance.service
        ?.getMemoryUsage(mainId)
        .then((value) => memoryInfo[VMServiceWrapper.instance.main!] = value);
  }

  void updateFlutterVersion() {
    if (!VMServiceWrapper.instance.connected) {
      return;
    }
    VMServiceWrapper.instance
        .callExtensionService('flutterVersion')
        .then(
          (value) => {
            if (value != null)
              {_flutterVersion = FlutterVersion.parse(value.json!).version},
          },
        );
  }

  void updateAllocationProfile() {
    var mainId = VMServiceWrapper.instance.main?.id;
    if (!VMServiceWrapper.instance.connected || mainId == null) {
      return;
    }
    VMServiceWrapper.instance.service
        ?.getAllocationProfile(mainId)
        .then((value) => allocationProfile = value);
  }

  void testPrintScript() async {
    // Script script = await compute(getScriptList, 'main.dart');
    var script = await getScriptList('main.dart');
    if (kDebugMode) {
      print(script?.source ?? 'null');
    }
  }
}

Future<Script?> getScriptList(String fileName) async {
  if (!VMServiceWrapper.instance.connected) {
    await VMServiceWrapper.instance.connect();
  }
  var mainId = VMServiceWrapper.instance.main?.id;
  if (VMServiceWrapper.instance.connected && mainId != null) {
    return VMServiceWrapper.instance.service?.getScripts(mainId).then<Script?>((
      scriptList,
    ) async {
      var id = scriptList.scripts
          ?.firstWhere((element) => element.id?.contains(fileName) == true)
          .id;
      if (id == null) {
        return Future.value(null);
      }
      return await VMServiceWrapper.instance.service?.getObject(mainId, id)
          as Script;
    });
  }

  return null;
}
