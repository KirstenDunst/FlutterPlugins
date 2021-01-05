#import "BackgroundAliveCsxPlugin.h"

@implementation BackgroundAliveCsxPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"background_alive_csx"
            binaryMessenger:[registrar messenger]];
  BackgroundAliveCsxPlugin* instance = [[BackgroundAliveCsxPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"playBackgroundVideo" isEqualToString:call.method]) {
    //后台播放音频
  } else {
    result(FlutterMethodNotImplemented);
  }
}

@end
