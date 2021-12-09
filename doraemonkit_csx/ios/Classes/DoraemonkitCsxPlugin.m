#import "DoraemonkitCsxPlugin.h"
#import "Tool/Common/CommonTool.h"
#import "DoraemonkitCsxViewFactory.h"

typedef NS_ENUM(NSInteger, CallMethood){
    unknown,
    getPlatformVersion,
    openSettingPage,
    getIosDeviceInfo,
    getUserDefaults,
    setUserDefault,
 };
@interface DoraemonkitCsxPlugin ()
@property(nonatomic, strong)NSDictionary *callMethodDic;
@end

@implementation DoraemonkitCsxPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel *channel = [FlutterMethodChannel
      methodChannelWithName:@"doraemonkit_csx"
            binaryMessenger:[registrar messenger]];
  DoraemonkitCsxPlugin* instance = [[DoraemonkitCsxPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
    [DoraemonkitCsxViewFactory registerWithRegistrar:registrar];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    switch ([self change:call.method]) {
        case getPlatformVersion://获取系统版本号
            result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
            break;
        case openSettingPage:{
            //打开app设置界面
            bool openResult = [CommonTool openAppSetting];
            result([NSNumber numberWithBool:openResult]);
            }
            break;
        case getIosDeviceInfo://获取设备信息
            result([CommonTool getDeviceInfo]);
            break;
        case getUserDefaults://获取userdefault存储的数据
            result([CommonTool getUserDefaults]);
            break;
        case setUserDefault://本地存储
            [CommonTool setUserDefault:call.arguments];
            break;
        case unknown:
        default:
            result(FlutterMethodNotImplemented);
            break;
    }
}

- (CallMethood)change:(NSString *)str {
    if ([self.callMethodDic.allKeys containsObject:str]) {
        return (CallMethood)[self.callMethodDic[str] integerValue];
    }
    return unknown;
}

#pragma lazy
- (NSDictionary *)callMethodDic {
    if (!_callMethodDic) {
        _callMethodDic = @{@"getPlatformVersion":@(getPlatformVersion),@"openSettingPage":@(openSettingPage),@"getIosDeviceInfo":@(getIosDeviceInfo),@"getUserDefaults":@(getUserDefaults),@"setUserDefault":@(setUserDefault)};
    }
    return _callMethodDic;
}
@end
