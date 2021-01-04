import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:device_info_csx/device_info_csx.dart';

void main() {
  const MethodChannel channel = MethodChannel('device_info_csx');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await DeviceInfoCsx.platformVersion, '42');
  });
}
