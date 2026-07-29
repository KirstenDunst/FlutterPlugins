#import "./include/limiting_direction_csx/LimitingDirectionCsxPlugin.h"
static FlutterMethodChannel *channel;

@interface LimitingDirectionCsxPlugin () {
    UIDeviceOrientation iOSOrientation;
    UIDeviceOrientation lastLandOrientation;
}
@end

@implementation LimitingDirectionCsxPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  channel = [FlutterMethodChannel
      methodChannelWithName:@"limiting_direction_csx"
            binaryMessenger:[registrar messenger]];
  LimitingDirectionCsxPlugin* instance = [[LimitingDirectionCsxPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init{
    self = [super init];
    if (self) {
       iOSOrientation = [UIDevice currentDevice].orientation;
        [channel invokeMethod:@"orientationCallback" arguments:[self dealOrientationCallBack]];
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotateDevice:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    }
    return self;
}

- (void)rotateDevice:(NSNotification *)sender {
    UIDevice *device = [sender valueForKey:@"object"];
    iOSOrientation = device.orientation;
    [channel invokeMethod:@"orientationCallback" arguments:[self dealOrientationCallBack]];
}

- (NSString *)dealOrientationCallBack {
    NSString *tempStr = @"0";
    switch (iOSOrientation) {
        case UIDeviceOrientationUnknown:
            tempStr = @"0";
            break;
        case UIDeviceOrientationPortrait:
            tempStr = @"1";
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            tempStr = @"2";
            break;
        case UIDeviceOrientationLandscapeLeft:
            tempStr = @"3";
            break;
        case UIDeviceOrientationLandscapeRight:
            tempStr = @"4";
            break;
        case UIDeviceOrientationFaceUp:
            tempStr = @"5";
            break;
        case UIDeviceOrientationFaceDown:
            tempStr = @"6";
            break;
       
        default:
            tempStr = @"0";
            break;
    }
    return  tempStr;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"changeScreenDirection" isEqualToString:call.method]) {
        NSNumber *index = [NSNumber numberWithInt: [call.arguments[0] intValue]];
        if ([index isEqualToNumber:@0]) {
            if (iOSOrientation == UIDeviceOrientationLandscapeLeft || iOSOrientation == UIDeviceOrientationLandscapeRight) {
                lastLandOrientation = iOSOrientation;
            }
            iOSOrientation = UIDeviceOrientationPortrait;
        } else if([index isEqualToNumber:@1]) {
            iOSOrientation = UIDeviceOrientationLandscapeLeft;
        } else if([index isEqualToNumber:@2]) {
            iOSOrientation = UIDeviceOrientationLandscapeRight;
        } else if([index isEqualToNumber:@3]) {
            if (iOSOrientation != UIDeviceOrientationPortrait && iOSOrientation != UIDeviceOrientationPortraitUpsideDown) {
                iOSOrientation = UIDeviceOrientationPortrait;
            }
        } else if([index isEqualToNumber:@4]) {
            if (iOSOrientation != UIDeviceOrientationLandscapeLeft && iOSOrientation != UIDeviceOrientationLandscapeRight) {
                if (lastLandOrientation) {
                    iOSOrientation = lastLandOrientation;
                } else {
                    iOSOrientation = UIDeviceOrientationLandscapeLeft;
                }
            }
            lastLandOrientation = iOSOrientation;
        } else if([index isEqualToNumber:@6]) {
            if (iOSOrientation == UIDeviceOrientationPortraitUpsideDown) {
                iOSOrientation = UIDeviceOrientationPortrait;
            }
        }
        if (@available(iOS 16.0, *)) {
            UIWindowScene *windowScene = UIApplication.sharedApplication.windows.firstObject.windowScene;
            if (windowScene) {
                UIWindowSceneGeometryPreferencesIOS *preferences =
                    [[UIWindowSceneGeometryPreferencesIOS alloc]
                     initWithInterfaceOrientations:[self transFromUIDeviceOrientation:(iOSOrientation)]];
                [windowScene requestGeometryUpdateWithPreferences:preferences
                                                       errorHandler:^(NSError * _Nonnull error) {
                    NSLog(@"requestGeometryUpdate error: %@", error);
                }];
            }
        } else {
            [[UIDevice currentDevice] setValue:@(iOSOrientation) forKey:@"orientation"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LimitingDirectionCsxPlugin" object:nil userInfo:@{@"orientationMask": index}];
        [UIViewController attemptRotationToDeviceOrientation];
        result(nil);
    } else if ([@"getNowDeviceDirection" isEqualToString:call.method]) {
        result([self dealOrientationCallBack]);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (UIInterfaceOrientationMask) transFromUIDeviceOrientation:(UIDeviceOrientation)orientation {
    UIInterfaceOrientationMask orientationMask = UIInterfaceOrientationMaskPortrait;
    switch (orientation) {
        case UIDeviceOrientationUnknown:
            orientationMask = UIInterfaceOrientationMaskPortrait;
            break;
        case UIDeviceOrientationPortrait:
            orientationMask = UIInterfaceOrientationMaskPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientationMask = UIInterfaceOrientationMaskPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientationMask = UIInterfaceOrientationMaskLandscapeLeft;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientationMask = UIInterfaceOrientationMaskLandscapeRight;
            break;
            
        default:
            orientationMask = UIInterfaceOrientationMaskPortrait;
            break;
    }
    
    return orientationMask;
}

@end
