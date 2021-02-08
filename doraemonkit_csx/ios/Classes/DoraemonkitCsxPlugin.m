#import "DoraemonkitCsxPlugin.h"
#import "Tool/Common/CommonTool.h"

@implementation DoraemonkitCsxPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"doraemonkit_csx"
            binaryMessenger:[registrar messenger]];
  DoraemonkitCsxPlugin* instance = [[DoraemonkitCsxPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
      //获取系统版本号
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"openSettingPage" isEqualToString:call.method]) {
      //打开app设置界面
      bool openResult = [CommonTool openAppSetting];
      result([NSNumber numberWithBool:openResult]);
  } else if ([@"getIosDeviceInfo" isEqualToString:call.method]) {
      //获取设备信息
      result([CommonTool getDeviceInfo]);
  } else if ([@"getUserDefaults" isEqualToString:call.method]) {
      //获取userdefault存储的数据
      result([CommonTool getUserDefaults]);
  } else if ([@"setUserDefault" isEqualToString:call.method]) {
      //本地存储
      [CommonTool setUserDefault:call.arguments];
  } else {
    result(FlutterMethodNotImplemented);
  }
}



@end
