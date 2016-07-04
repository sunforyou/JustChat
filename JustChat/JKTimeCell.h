//
//  JKTimeCell.h
//  JustChat
//
//  Created by 宋旭 on 16/6/27.
//  Copyright © 2016年 sky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JKTimeCell : UITableViewCell

/**
 *  生成时间标签实例
 *
 *  @param tableView <#tableView description#>
 *  @param time      <#time description#>
 *
 *  @return <#return value description#>
 */
+ (instancetype)timeCell:(UITableView *)tableView time:(NSString *)time;

/**
 *  显示时间标签
 */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
