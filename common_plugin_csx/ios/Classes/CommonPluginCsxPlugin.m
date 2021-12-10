#import "CommonPluginCsxPlugin.h"
#include <CommonCrypto/CommonDigest.h>

@implementation CommonPluginCsxPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"common_plugin_csx"
                                     binaryMessenger:[registrar messenger]];
    CommonPluginCsxPlugin* instance = [[CommonPluginCsxPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getFileMd5" isEqualToString:call.method]) {
        NSString *md5Str = [self md5WithFilePath:[NSString stringWithFormat:@"%@",call.arguments]];
        result(md5Str);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

/** 获取文件的md5值*/
- (NSString*)md5WithFilePath:(NSString*)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path isDirectory:nil]) {
       NSData *data = [NSData dataWithContentsOfFile:path];
       unsigned char digest[CC_MD5_DIGEST_LENGTH];
       CC_MD5( data.bytes, (CC_LONG)data.length, digest );
       NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
       for( int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ ) {
          [output appendFormat:@"%02x", digest[i]];
       }
       return output;
    } else {
       return @"";
    }
}
@end
