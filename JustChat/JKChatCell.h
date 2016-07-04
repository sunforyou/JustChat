//
//  JKChatCell.h
//  JustChat
//
//  Created by 宋旭 on 16/6/27.
//  Copyright © 2016年 sky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMSDK.h"

static NSString *SenderCell = @"SenderCell";
static NSString *ReceiverCell = @"ReceiverCell";

@interface JKChatCell : UITableViewCell

/**
 *  生成自定义消息实例
 *
 *  @param tableView <#tableView description#>
 *  @param message   <#message description#>
 *
 *  @return <#return value description#>
 */
+ (instancetype)chatCell:(UITableView *)tableView message:(EMMessage *)message;

/**
 *  消息文字
 */
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

/**
 *  消息图片
 */
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

/**
 *  消息实例
 */
@property (strong, nonatomic) EMMessage *message;

/**
 *  cell的高度
 */
- (CGFloat)cellHeight;

@end
