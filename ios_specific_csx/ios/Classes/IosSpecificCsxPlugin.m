#import "IosSpecificCsxPlugin.h"
#if __has_include(<ios_specific_csx/ios_specific_csx-Swift.h>)
#import <ios_specific_csx/ios_specific_csx-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "ios_specific_csx-Swift.h"
#endif

@implementation IosSpecificCsxPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftIosSpecificCsxPlugin registerWithRegistrar:registrar];
}
@end
