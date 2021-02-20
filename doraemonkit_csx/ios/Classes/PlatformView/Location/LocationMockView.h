//
//  LocationMockView.h
//  doraemonkit_csx
//
//  Created by 曹世鑫 on 2021/2/19.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocationMockView : NSObject<FlutterPlatformView>

- (id)initWithFrame:(CGRect)frame viewId:(int64_t)viewId args:(id)args;

@end

NS_ASSUME_NONNULL_END
