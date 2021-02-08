//
//  CommonTool.h
//  doraemonkit_csx
//
//  Created by 曹世鑫 on 2021/2/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommonTool : NSObject
//进入app的设置界面；
+ (BOOL)openAppSetting;

//获取iOS设备的信息
+ (NSDictionary *)getDeviceInfo;

//获取所有userdefault存储的数据
+ (NSDictionary *)getUserDefaults;

//本地存储
+ (void)setUserDefault:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
