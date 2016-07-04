//
//  JKAudioPlayTool.m
//  JustChat
//
//  Created by 宋旭 on 16/6/27.
//  Copyright © 2016年 sky. All rights reserved.
//

#import "JKAudioPlayTool.h"
#import "EMCDDeviceManager.h"

static UIImageView *imageViewAnimated;

@implementation JKAudioPlayTool

+ (void)playWithMessage:(EMMessage *)message atLabel:(UILabel *)label receiver:(BOOL)receiver {
    
    /** 移除以前的动画 */
    [imageViewAnimated removeFromSuperview];
    
    /** 搜索本地音频文件 */
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [(EMVoiceMessageBody *)message.body localPath];
    
    /** 本地音频文件不存在，使用远程服务的文件路径 */
    if(![fileManager fileExistsAtPath:[(EMVoiceMessageBody *)message.body localPath]])
    {
        filePath = [(EMVoiceMessageBody *)message.body remotePath];
    }
    
    /** 播放音频 */
    [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:filePath completion:^(NSError *error) {
        [imageViewAnimated removeFromSuperview];
        if (!error) {
            NSLog(@"播放完成");
        }else{
            NSLog(@"播放失败 %@",error);
        }
    }];
    
    /** 添加播放动画 */
    UIImageView *animationImgView = [[UIImageView alloc] init];
    if (receiver) {
        animationImgView.frame = CGRectMake(0, 0, 25, 25);
    } else {
        animationImgView.frame = CGRectMake(label.bounds.size.width - 25, 0, 25, 25);
    }
    
    NSMutableArray *images = [NSMutableArray array];
    if (receiver) {
        [images addObject:[UIImage imageNamed:@"chat_receiver_audio_playing000"]];
        [images addObject:[UIImage imageNamed:@"chat_receiver_audio_playing001"]];
        [images addObject:[UIImage imageNamed:@"chat_receiver_audio_playing002"]];
        [images addObject:[UIImage imageNamed:@"chat_receiver_audio_playing003"]];
    } else {
        [images addObject:[UIImage imageNamed:@"chat_sender_audio_playing_000"]];
        [images addObject:[UIImage imageNamed:@"chat_sender_audio_playing_001"]];
        [images addObject:[UIImage imageNamed:@"chat_sender_audio_playing_002"]];
        [images addObject:[UIImage imageNamed:@"chat_sender_audio_playing_003"]];
    }
    animationImgView.animationImages = images;
    animationImgView.animationDuration = 1;
    [label addSubview:animationImgView];
    [animationImgView startAnimating];
    
    imageViewAnimated = animationImgView;
}

+ (void)stop {
    if ([EMCDDeviceManager sharedInstance].isPlaying) {
        [[EMCDDeviceManager sharedInstance] stopPlaying];
        [imageViewAnimated removeFromSuperview];
    }
}

@end
