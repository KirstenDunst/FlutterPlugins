#import "BackgroundAliveCsxPlugin.h"
#import <AVFoundation/AVFoundation.h>
#import "CSXPlayAudio.h"

@interface BackgroundAliveCsxPlugin ()<AVAudioPlayerDelegate>
//播放器
@property (nonatomic, strong) CSXPlayAudio *myPlayer;
@end

@implementation BackgroundAliveCsxPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"background_alive_csx"
            binaryMessenger:[registrar messenger]];
  BackgroundAliveCsxPlugin* instance = [[BackgroundAliveCsxPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"openBackgroundTask" isEqualToString:call.method]) {
      //后台播放音频
      AVAudioSession *session = [AVAudioSession sharedInstance];
      [session setActive:YES error:nil];
      [session setCategory:AVAudioSessionCategoryPlayback error:nil];
      //让app支持接受远程控制事件(可以不添加控制事件)
      [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
      
//      NSURL *url = [[NSBundle mainBundle] URLForResource:@"silent" withExtension:@"mp3"];
      NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"background_alive_csx" withExtension:@"bundle"];
      NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
      NSData *mp3Data = [NSData dataWithContentsOfFile:[bundle pathForResource:@"summer" ofType:@"mp3"]];
      
      [self.myPlayer setplayData:mp3Data isCirculation:true];
      [self.myPlayer play];
  } else if ([@"stopBackgroundTask" isEqualToString:call.method]) {
      [self.myPlayer stop];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

# pragma ===lazy
- (CSXPlayAudio *) myPlayer {
    if (_myPlayer == nil) {
        _myPlayer = [CSXPlayAudio sharedAudioPlayer];
    }
    return _myPlayer;
}

@end
