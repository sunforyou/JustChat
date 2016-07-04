//
//  JKToolBarViewForInput.m
//  JustChat
//
//  Created by 宋旭 on 16/6/27.
//  Copyright © 2016年 sky. All rights reserved.
//

#import "JKToolBarViewForInput.h"

@interface JKToolBarViewForInput()

/** 录音按钮 */
@property(nonatomic,weak)IBOutlet UIButton *recordBtn;

@property(nonatomic,weak)IBOutlet UITextView *textView;

- (IBAction)cancelRecordAction:(id)sender;

@end

@implementation JKToolBarViewForInput

- (IBAction)voiceAction:(UIButton *)voiceBtn {
    [self endEditing:YES];
    self.recordBtn.hidden = !self.recordBtn.hidden;
    self.textView.hidden = !self.textView.hidden;
    NSString *normalImg = @"chatBar_record";
    if (!self.recordBtn.hidden) {
        normalImg = @"chatBar_keyboard";
    }
    
    [voiceBtn setImage:[UIImage imageNamed:normalImg] forState:UIControlStateNormal];
}

- (IBAction)beginRecordAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(beginRecord)]) {
        [self.delegate beginRecord];
    }
}

- (IBAction)cancelRecordAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cancelRecord)]) {
        [self.delegate cancelRecord];
    }
}

- (IBAction)endRecordAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(endRecord)]) {
        [self.delegate endRecord];
    }
}

@end
