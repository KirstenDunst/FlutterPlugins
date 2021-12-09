//
//  DoraemonkitCsxViewFactory.m
//  doraemonkit_csx
//
//  Created by 曹世鑫 on 2021/2/20.
//

#import "DoraemonkitCsxViewFactory.h"
#import "PlatformView/Location/LocationMockFactory.h"

@implementation DoraemonkitCsxViewFactory

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    //定位视图
    [registrar registerViewFactory:[[LocationMockFactory alloc] initWithMessenger:registrar.messenger] withId:@"MyLocationPlatformView"];
}
@end
