//
//  JKToolBarViewForInput.h
//  JustChat
//
//  Created by 宋旭 on 16/6/27.
//  Copyright © 2016年 sky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JKChatInputToolBarDelegate <NSObject>

/**
 * 开始录音
 */
- (void)beginRecord;

/**
 * 取消录音
 */
- (void)cancelRecord;

/**
 * 结束录音
 */
- (void)endRecord;

@end

@interface JKToolBarViewForInput : UIView

@property (nonatomic, weak) IBOutlet id<JKChatInputToolBarDelegate> delegate;

@end
