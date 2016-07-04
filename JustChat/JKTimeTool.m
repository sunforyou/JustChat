//
//  JKTimeTool.m
//  JustChat
//
//  Created by 宋旭 on 16/6/27.
//  Copyright © 2016年 sky. All rights reserved.
//

#import "JKTimeTool.h"

@implementation JKTimeTool

+ (NSString *)timeStr:(long long)timestamp {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    /** 当前月的 "号数" */
    NSDateComponents *compnents = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth fromDate:[NSDate date]];
    NSInteger currentDay = compnents.day;
    NSInteger currentMoth = compnents.month;
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp/1000.0];
    /** 发信息的时间 "号数" */
    compnents =[calendar components:NSCalendarUnitDay|NSCalendarUnitMonth fromDate:date];
    NSInteger msgDay = compnents.day;
    NSInteger msgMoth = compnents.month;
    
    /*
     * 今天 -- HH:mm:ss
     * 昨天 -- 昨天:HH:mm:ss
     * 昨天以前 -- yyyy-MM-dd HH:mm:ss
     */
    NSString *timeFormat = nil;
    if (msgDay == currentDay && msgMoth == currentMoth) {
        timeFormat = @"HH:mm";
    } else if (msgMoth == currentMoth && (msgDay + 1) == currentDay) {
        timeFormat = @"昨天 HH:mm";
    } else {
        timeFormat = @"yyyy-MM-dd HH:mm";
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = timeFormat;
    return [dateFormatter stringFromDate:date];
}

@end
