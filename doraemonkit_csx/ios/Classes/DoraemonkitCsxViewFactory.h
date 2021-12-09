//
//  DoraemonkitCsxViewFactory.h
//  doraemonkit_csx
//
//  Created by 曹世鑫 on 2021/2/20.
//
//原生视图注册

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoraemonkitCsxViewFactory : NSObject

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar;

@end

NS_ASSUME_NONNULL_END
