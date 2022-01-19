#import "HotFixCsxPlugin.h"
#if __has_include(<hot_fix_csx/hot_fix_csx-Swift.h>)
#import <hot_fix_csx/hot_fix_csx-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "hot_fix_csx-Swift.h"
#endif

@implementation HotFixCsxPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftHotFixCsxPlugin registerWithRegistrar:registrar];
}
@end
