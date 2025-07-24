import 'package:flutter_test/flutter_test.dart';
import 'package:icon_replance_csx/icon_replance_csx.dart';
import 'package:icon_replance_csx/icon_replance_csx_platform_interface.dart';
import 'package:icon_replance_csx/icon_replance_csx_method_channel.dart';
import 'package:icon_replance_csx/icon_replance_model.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockIconReplanceCsxPlatform
    with MockPlatformInterfaceMixin
    implements IconReplanceCsxPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool?> removeSysAlert() {
    throw UnimplementedError();
  }

  @override
  Future<bool?> resetSysAlert() {
    throw UnimplementedError();
  }

  @override
  Future<String?> nowIconName() {
    throw UnimplementedError();
  }

  @override
  Future<EditIconBackModel?> changeIcon(String? iconName,
      {List<String>? aliasNames,
      bool changeNow = false,
      String? androidPackage}) {
    throw UnimplementedError();
  }
}

void main() {
  final IconReplanceCsxPlatform initialPlatform =
      IconReplanceCsxPlatform.instance;

  test('$MethodChannelIconReplanceCsx is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelIconReplanceCsx>());
  });

  test('getPlatformVersion', () async {
    IconReplanceCsx iconReplanceCsxPlugin = IconReplanceCsx();
    MockIconReplanceCsxPlatform fakePlatform = MockIconReplanceCsxPlatform();
    IconReplanceCsxPlatform.instance = fakePlatform;

    expect(await iconReplanceCsxPlugin.getPlatformVersion(), '42');
  });
}
