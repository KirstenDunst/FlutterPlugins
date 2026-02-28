import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'common_method_channel.dart';

abstract class DoraemonkitCsxPlatform extends PlatformInterface {
  /// Constructs a DoraemonkitCsxPlatform.
  DoraemonkitCsxPlatform() : super(token: _token);

  static final Object _token = Object();

  static DoraemonkitCsxPlatform _instance = MethodChannelDoraemonkitCsx();

  /// The default instance of [DoraemonkitCsxPlatform] to use.
  ///
  /// Defaults to [MethodChannelDoraemonkitCsx].
  static DoraemonkitCsxPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DoraemonkitCsxPlatform] when
  /// they register themselves.
  static set instance(DoraemonkitCsxPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Map> getUserDefaults() {
    throw UnimplementedError('getUserDefaults() has not been implemented.');
  }

  Future setUserDefault(Map<String, dynamic> tempJson) async {
    throw UnimplementedError('setUserDefault() has not been implemented.');
  }

  Future<bool> openiOSSettingPage() {
    throw UnimplementedError('openiOSSettingPage() has not been implemented.');
  }

  Future openAndroidDeveloperOptions() {
    throw UnimplementedError(
      'openDeveloperOptions() has not been implemented.',
    );
  }

  Future<bool> openAndroidLocalLanguagesPage() {
    throw UnimplementedError(
      'openLocalLanguagesPage() has not been implemented.',
    );
  }
}
