//
//  FBPlayAudio.m
//  JSbrige
//
//  Created by 曹世鑫 on 2018/8/7.
//  Copyright © 2018年 曹世鑫. All rights reserved.
//

#import "CSXPlayAudio.h"
#import <AVFoundation/AVFoundation.h>

@interface CSXPlayAudio ()<AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic, copy)PlayBack backBlock;
@end

@implementation CSXPlayAudio

+ (id)sharedAudioPlayer {
    static CSXPlayAudio *audioPlayer ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioPlayer = [[CSXPlayAudio alloc] init];
    });
    return audioPlayer;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)play {
    [self.audioPlayer play];
}

- (void)stop {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
    }
}

- (void)setplayData:(NSData *)data isCirculation:(BOOL)isCirculation {
    NSError *error;
    if (self.audioPlayer != nil) {
        self.audioPlayer = nil;
    }
    self.audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:&error];
    if (isCirculation) {
        self.audioPlayer.numberOfLoops = -1;
    }
    [self.audioPlayer prepareToPlay];
}

- (void)setplayURL:(NSURL *)url isCirculation:(BOOL)isCirculation back:(PlayBack)back{
    NSError *error;
    if (self.audioPlayer != nil) {
        self.audioPlayer = nil;
    }
    self.backBlock = back;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.audioPlayer.delegate = self;
    if (isCirculation) {
        self.audioPlayer.numberOfLoops = -1;
    }
    [self.audioPlayer prepareToPlay];
}

- (void)playWithFileName:(NSString *)name {
    if (name && name.length > 0) {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"caf"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        [self setplayData:data isCirculation: false];
        [self play];
    }
}

- (void)playSoundWithName:(NSString *)name {
    NSString *audioFile=[[NSBundle mainBundle] pathForResource:name ofType:@"caf"];
    NSURL *fileUrl=[NSURL fileURLWithPath:audioFile];
    //1.获得系统声音ID
    SystemSoundID soundID=0;
    /**
     * inFileUrl:音频文件url
     * outSystemSoundID:声音id（此函数会将音效文件加入到系统音频服务中并返回一个长整形ID）
     */
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    //如果需要在播放完之后执行某些操作，可以调用如下方法注册一个播放完成回调函数
    //    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    //2.播放音频
    AudioServicesPlaySystemSound(soundID);//播放音效
    //    AudioServicesPlayAlertSound(soundID);//播放音效并震动
}


#pragma mark -------AVAudioPlayer的代理方法
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    //播放完成
    [player stop]; // 停止播放
    player = nil;  // 释放player
    if (self.backBlock) {
        self.backBlock(YES, nil);
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    if (self.backBlock) {
        self.backBlock(NO, error.localizedDescription);
    }
}

@end
