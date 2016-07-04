//
//  JKChatCell.m
//  JustChat
//
//  Created by 宋旭 on 16/6/27.
//  Copyright © 2016年 sky. All rights reserved.
//

#import "JKChatCell.h"
#import "EMSDK.h"
#import "JKAudioPlayTool.h"

@implementation JKChatCell

- (void)awakeFromNib {
    // Initialization code
    [self.contentView bringSubviewToFront:self.msgLabel];
    
    /** 添加点击手势 */
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.bgImageView addGestureRecognizer:tap];
    self.bgImageView.userInteractionEnabled = YES;
    
    /** 设置背景和选中背景为透明 */
    self.backgroundColor = [UIColor clearColor];
    self.selectedBackgroundView = [[UIView alloc] init];
}

- (void)tap:(UITapGestureRecognizer *)tap {
    BOOL isReceiver = [self.reuseIdentifier isEqualToString:ReceiverCell];
    if (EMMessageBodyTypeVoice == self.message.body.type ) {
        // 播放语音(自己写的工具类)
        [JKAudioPlayTool playWithMessage:self.message
                                 atLabel:self.msgLabel
                                receiver:isReceiver];
    }
}


+ (instancetype)chatCell:(UITableView *)tableView message:(EMMessage *)message {
    // 获取当前登录用户名
    NSString *loginUsername = [[EMClient sharedClient] currentUsername];
    JKChatCell *cell = nil;
    // 消息收发
    if ([message.from isEqualToString:loginUsername]) {
        cell = [tableView dequeueReusableCellWithIdentifier:SenderCell];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:ReceiverCell];
    }
    
    // 设置消息模型，内部set方法，实现数据显示
    cell.message = message;
    
    return cell;
}

- (CGFloat)cellHeight {
    /** 重新布局子控件 */
    [self layoutIfNeeded];
    return 15 + self.msgLabel.bounds.size.height + 10 + 10;
}

- (void)setMessage:(EMMessage *)message {
    _message = message;
    
    switch (message.body.type) {
        case EMMessageBodyTypeText:
            /** 文本消息 */
            self.msgLabel.text = [(EMTextMessageBody *)message.body text];
            break;
        case EMMessageBodyTypeVoice:
            /** 语音消息 */
            self.msgLabel.attributedText = [self getVoiceAttText];
            break;
        default:
            /** 未知消息 */
            self.msgLabel.text = @"未知消息类型";
            break;
    }
}

/**
 * 获取声音的富文本
 */
- (NSAttributedString *)getVoiceAttText {
    
    /** 获取音频的时间 */
    double duration = [(EMVoiceMessageBody *)self.message.body duration];
    
    /** 接收方(好友) */
    BOOL isReceiver = [self.reuseIdentifier isEqualToString:ReceiverCell];
    
    /** 富文本 */
    /** 接收方 ＝ 图片 + 时长
     *  发送方 ＝ 时长 + 图片
     */
    NSMutableAttributedString *attStrM = [[NSMutableAttributedString alloc] init];
    if (isReceiver) {
        // 拼接图片
        [attStrM appendAttributedString:[self audioAtt:@"chat_receiver_audio_playing_full"]];
        // 拼接时长
        [attStrM appendAttributedString:[self timeAtt:duration]];
        
    } else {
        // 拼接时长
        [attStrM appendAttributedString:[self timeAtt:duration]];
        
        // 拼接图片
        [attStrM appendAttributedString:[self audioAtt:@"chat_sender_audio_playing_full"]];
    }
    return [attStrM copy];
}


- (NSAttributedString *)timeAtt:(double)duration {
    NSString *timeStr = [NSString stringWithFormat:@"%.0lf '",duration];
    return [[NSAttributedString alloc] initWithString:timeStr];
}

/** 音频图片 */
- (NSAttributedString *)audioAtt:(NSString *)imgName {
    NSTextAttachment *imgAttach = [[NSTextAttachment alloc] init];
    imgAttach.image = [UIImage imageNamed:imgName];
    NSAttributedString *audioAtt = [NSAttributedString attributedStringWithAttachment:imgAttach];
    imgAttach.bounds = CGRectMake(0, -7, 25, 25);
    return audioAtt;
}

@end
