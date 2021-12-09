//
//  GPSMockerTool.h
//  doraemonkit_csx
//
//  Created by 曹世鑫 on 2021/2/19.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GPSMockerTool : NSObject

+ (GPSMockerTool *)shareInstance;

- (void)addLocationBinder:(id)binder delegate:(id)delegate;

- (BOOL)mockPoint:(CLLocation*)location;

- (void)stopMockPoint;

@property (nonatomic, assign) BOOL isMocking;

@end

NS_ASSUME_NONNULL_END
