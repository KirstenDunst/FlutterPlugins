#import "LimitingDirectionCsxPlugin.h"

@interface LimitingDirectionCsxPlugin () {
    UIDeviceOrientation iOSOrientation;
    UIDeviceOrientation lastLandOrientation;
}
@end

@implementation LimitingDirectionCsxPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"limiting_direction_csx"
            binaryMessenger:[registrar messenger]];
  LimitingDirectionCsxPlugin* instance = [[LimitingDirectionCsxPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init{
    self = [super init];
    if (self) {
       iOSOrientation = [UIDevice currentDevice].orientation;
       [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotateDevice:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)rotateDevice:(NSObject *)sender {
    UIDevice *device = [sender valueForKey:@"object"];
    iOSOrientation = device.orientation;
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
        [[UIDevice currentDevice] setValue:@(iOSOrientation) forKey:@"orientation"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LimitingDirectionCsxPlugin" object:nil userInfo:@{@"orientationMask": index}];
        [UIViewController attemptRotationToDeviceOrientation];
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
