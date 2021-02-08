//
//  DoraemonkitCsxSandbox.m
//  doraemonkit_csx
//
//  Created by 曹世鑫 on 2021/2/7.
//

#import "DoraemonkitCsxSandbox.h"

@implementation DoraemonkitCsxSandbox

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"doraemonkit_csx_sandbox"
            binaryMessenger:[registrar messenger]];
    DoraemonkitCsxSandbox* instance = [[DoraemonkitCsxSandbox alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  }
}
@end
