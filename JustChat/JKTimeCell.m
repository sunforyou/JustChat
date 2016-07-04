//
//  JKTimeCell.m
//  JustChat
//
//  Created by 宋旭 on 16/6/27.
//  Copyright © 2016年 sky. All rights reserved.
//

#import "JKTimeCell.h"

@implementation JKTimeCell

+ (instancetype)timeCell:(UITableView *)tableView time:(NSString *)time {
    static NSString *ID = @"TimeCell";
    JKTimeCell *timeCell = [tableView dequeueReusableCellWithIdentifier:ID];
    timeCell.timeLabel.text = time;
    
    return timeCell;
}

- (void)awakeFromNib {
    // Initialization code
    self.selectedBackgroundView = [[UIView alloc] init];
    self.backgroundColor = [UIColor clearColor];
}

@end
