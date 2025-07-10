import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:icon_replance_csx/icon_replance_csx_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelIconReplanceCsx platform = MethodChannelIconReplanceCsx();
  const MethodChannel channel = MethodChannel('icon_replance_csx');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
