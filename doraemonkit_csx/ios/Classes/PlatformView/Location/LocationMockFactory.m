//
//  LocationMockView.m
//  doraemonkit_csx
//
//  Created by 曹世鑫 on 2021/2/19.
//

#import "LocationMockFactory.h"
#import "LocationMockView.h"

@interface LocationMockFactory ()

@property (nonatomic, strong)NSObject<FlutterBinaryMessenger> *messenger;

@end

@implementation LocationMockFactory
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messager{
    self = [super init];
    if (self) {
        self.messenger = messager;
    }
    return self;
}

//设置参数的编码方式
-(NSObject<FlutterMessageCodec> *)createArgsCodec{
    return [FlutterStandardMessageCodec sharedInstance];
}

//用来创建 ios 原生view
- (NSObject <FlutterPlatformView> *)createWithFrame:(CGRect)frame viewIdentifier:(int64_t)viewId arguments:(id _Nullable)args {
    LocationMockView *myPlatformViewObject = [[LocationMockView alloc] initWithFrame:frame viewId:viewId args:args];
    return myPlatformViewObject;
}
@end
