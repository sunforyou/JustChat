//
//  JKMostTableViewController.m
//  JustChat
//
//  Created by 宋旭 on 16/6/27.
//  Copyright © 2016年 sky. All rights reserved.
//

#import "JKMostTableViewController.h"
#import "MBProgressHUD+Add.h"
#import "EMSDK.h"

@interface JKMostTableViewController ()

@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

@end

@implementation JKMostTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 显示登录名
    NSString *title = [NSString stringWithFormat:@"退出登录(%@)",[[EMClient sharedClient] currentUsername]];
    [self.logoutBtn setTitle:title forState:UIControlStateNormal];
}

- (IBAction)logoutAction:(UIButton *)logoutBtn {
    /** 退出后，不再接收远程推送离线消息 */
    UIView *rootView = self.view.window.rootViewController.view;
    [MBProgressHUD showMessag:@"退出登录中..." toView:nil];
    /** 主动退出登录 */
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        EMError *error = [[EMClient sharedClient] logout:YES];
        if (!error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                self.view.window.rootViewController = [UIStoryboard storyboardWithName:@"JKLogin" bundle:nil].instantiateInitialViewController;
                [MBProgressHUD showSuccess:@"退出成功" toView:rootView];
            }];
            
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [MBProgressHUD showError:error.description toView:nil];
            }];
        }
    });
}

@end
