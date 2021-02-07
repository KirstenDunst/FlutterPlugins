#import "DoraemonkitCsxPlugin.h"
#import "CommonTool.h"

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
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"openSettingPage" isEqualToString:call.method]) {
      bool openResult = [CommonTool openAppSetting];
      result([NSNumber numberWithBool:openResult]);
  } else if ([@"getIosDeviceInfo" isEqualToString:call.method]) {
      result([CommonTool getDeviceInfo]);
  }else {
    result(FlutterMethodNotImplemented);
  }
}



@end
