//
//  JKLoginViewController.m
//  JustChat
//
//  Created by 宋旭 on 16/6/26.
//  Copyright © 2016年 sky. All rights reserved.
//

#import "JKLoginViewController.h"
#import "MBProgressHUD+Add.h"
#import "EMSDK.h"

@interface JKLoginViewController () <EMClientDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inputUserNameField;

@property (weak, nonatomic) IBOutlet UITextField *inputPasswordField;

- (IBAction)loginButtonClicked:(UIButton *)sender;

- (IBAction)registerButtonClicked:(UIButton *)sender;

@end

@implementation JKLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - Button Clicked Events
- (IBAction)loginButtonClicked:(UIButton *)sender {
    [MBProgressHUD showMessag:@"登录中..." toView:nil];
    
    /** 异步登录 */
    [[EMClient sharedClient] asyncLoginWithUsername:_inputUserNameField.text password:_inputPasswordField.text success:^{
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            /** 进入主界面 */
            self.view.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
            
            [MBProgressHUD showSuccess:@"登录成功" toView:nil];
        }];
        /** 设置下次自动登录 */
        [[EMClient sharedClient].options setIsAutoLogin:YES];
        
    } failure:^(EMError *aError) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [MBProgressHUD showError:@"登录失败,请检查用户名、密码" toView:nil];
        }];
        NSLog(@"登录失败\n %@", aError);
    }];
    
}

- (IBAction)registerButtonClicked:(UIButton *)sender {
    
    [MBProgressHUD showSuccess:@"注册中..." toView:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *aError = [[EMClient sharedClient] registerWithUsername:_inputUserNameField.text
                                                               password:_inputPasswordField.text];
        if (aError == nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [MBProgressHUD showSuccess:@"注册成功,请登录" toView:nil];
            }];
        } else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [MBProgressHUD showError:@"注册失败,请检查用户名、密码后重新输入" toView:nil];
            }];
            NSLog(@"注册失败!\n 错误码:%u,错误描述:%@", aError.code, aError.errorDescription);
        }
    });
}

#pragma mark - EMClientDelegate Methods

- (void)didLoginFromOtherDevice {
    NSLog(@"--------->当前账号已在其他设备登录");
}

#pragma mark - 键盘处理
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
