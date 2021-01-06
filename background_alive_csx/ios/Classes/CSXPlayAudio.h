
//
//  CSXPlayAudio.h
//  JSbrige
//
//  Created by 曹世鑫 on 2018/8/7.
//  Copyright © 2018年 曹世鑫. All rights reserved.
//

//播放结束返回，播放有错误的时候返回错误信息，成功为空
typedef void(^PlayBack)(BOOL isPlay, NSString *errorStr);

@interface CSXPlayAudio : NSObject

/**
 *  音乐播放管理器
 */
+ (instancetype)sharedAudioPlayer;

/**
 *  开始播放
 */
- (void)play;

/**
 *  暂停播放
 */
- (void)stop;

/**
 *  设置播放的数据
 *  @param  data  音乐的 data
 *  @param  isCirculation  是否循环播放
 */
- (void)setplayData:(NSData *)data isCirculation:(BOOL)isCirculation;


/**
 *  设置音乐播放的路径（非网络音乐）
 *  @param  url  歌曲路径
 *  @param  isCirculation  是否循环播放
 */
- (void)setplayURL:(NSURL *)url isCirculation:(BOOL)isCirculation back:(PlayBack)back;


- (void)playWithFileName:(NSString *)name;

- (void)playSoundWithName:(NSString *)name;

@end
