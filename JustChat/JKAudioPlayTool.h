//
//  JKAudioPlayTool.h
//  JustChat
//
//  Created by 宋旭 on 16/6/27.
//  Copyright © 2016年 sky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "EMSDK.h"

@interface JKAudioPlayTool : NSObject

+ (void)playWithMessage:(EMMessage *)message atLabel:(UILabel *)label receiver:(BOOL)receiver;
+ (void)stop;

@end
