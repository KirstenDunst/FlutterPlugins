//
//  MainViewController.h
//  Runner
//
//  Created by 曹世鑫 on 2020/12/28.
//

#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainViewController : FlutterViewController

@end

@interface OrientationUtil : NSObject
+ (UIInterfaceOrientationMask) getOrientationMaskWithIndex:(int)index;
@end

NS_ASSUME_NONNULL_END
