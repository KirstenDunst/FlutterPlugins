import 'package:doraemonkit_csx/channel/channel.dart';
import 'package:doraemonkit_csx/channel/common/common_method_channel.dart';
import 'package:doraemonkit_csx/channel/common/common_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockDoraemonkitCsxPlatform
    with MockPlatformInterfaceMixin
    implements DoraemonkitCsxPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Map> getUserDefaults() => Future.value({});
  @override
  Future setUserDefault(Map<String, dynamic> tempJson) => Future.value();
  @override
  Future<bool> openiOSSettingPage() => Future.value(true);

  @override
  Future openAndroidDeveloperOptions() => Future.value();

  @override
  Future<bool> openAndroidLocalLanguagesPage() => Future.value(true);
}

void main() {
  final DoraemonkitCsxPlatform initialPlatform =
      DoraemonkitCsxPlatform.instance;

  test('$MethodChannelDoraemonkitCsx is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelDoraemonkitCsx>());
  });

  test('getPlatformVersion', () async {
    MockDoraemonkitCsxPlatform fakePlatform = MockDoraemonkitCsxPlatform();
    DoraemonkitCsxPlatform.instance = fakePlatform;

    expect(await DoraemonkitCsx.getPlatformVersion(), '42');
  });
}
