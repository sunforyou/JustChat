//
//  JKAddFriendOrGroupViewController.m
//  JustChat
//
//  Created by 宋旭 on 16/6/27.
//  Copyright © 2016年 sky. All rights reserved.
//

#import "JKAddFriendOrGroupViewController.h"
#import "EMSDK.h"

@interface JKAddFriendOrGroupViewController ()

@property (weak, nonatomic) IBOutlet UITextField *friendName;

@end

@implementation JKAddFriendOrGroupViewController

- (IBAction)AddAction:(id)sender {
    
    if (!self.friendName.text.length) {
        [self displayNoticeWithMessage:self.friendName.placeholder];
    } else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            EMError *error = [[EMClient sharedClient].contactManager addContact:self.friendName.text
                                                                        message:@"我想加您为好友"];
            if (!error) {
                [self displayNoticeWithMessage:@"好友添加申请发送成功"];
                dispatch_async(dispatch_get_main_queue(), ^{
                   self.view.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
                });
            } else {
                [self displayNoticeWithMessage:@"添加好友申请发送失败"];
            }
        });
    }
}

#pragma mark - AlertController
- (void)displayNoticeWithMessage:(NSString *)message {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"好的"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       
                                                   }];
        
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

/** 点击背景回收键盘 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
@end
