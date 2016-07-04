//
//  JKContactsViewController.m
//  JustChat
//
//  Created by 宋旭 on 16/6/27.
//  Copyright © 2016年 sky. All rights reserved.
//

#import "JKContactsViewController.h"
#import "JKChatViewController.h"

@interface JKContactsViewController () <EMContactManagerDelegate, EMChatManagerDelegate, UIAlertViewDelegate>
/**
 * 好友列表
 */
@property(nonatomic,strong) NSArray *buddyList;
/**
 *  请求添加好友的用户名
 */
@property(nonatomic,copy) NSString *username;


@end

@implementation JKContactsViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    /** 注册好友回调 */
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    /** 添加回调监听代理 */
    [[EMClient sharedClient] addDelegate:(id<EMClientDelegate>)self delegateQueue:nil];
    /** 从数据库获取好友列表 */
    if (!(self.buddyList = [[EMClient sharedClient].contactManager getContactsFromDB])) {
        [self fetchBuddyList];
    } else {
        [self.tableView reloadData];
    }
}

- (void)dealloc {
    //移除好友回调
    [[EMClient sharedClient].contactManager removeDelegate:self];
    [[EMClient sharedClient] removeDelegate:self];
}

#pragma mark - Private Methods
- (BOOL)fetchBuddyList {
    __block BOOL success = NO;
    /** 从服务器获取好友列表 */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        self.buddyList = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
        if (!error) {
            success = YES;
        }
    });
    sleep(3);
    if (success) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableView reloadData];
        }];
    }
    return success;
}

/**
 *  开始刷新好友列表
 *
 *  @param rc <#rc description#>
 */
- (IBAction)beginRefreshAction:(UIRefreshControl *)rc {
    // 刷新从服务器获取最新的联系人列表
    NSLog([self fetchBuddyList] ? @"获取最新好友列表---->成功" : @"获取最新好友列表---->失败");
    [rc endRefreshing];
}

#pragma mark - TableView DataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.buddyList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    cell.textLabel.text = self.buddyList[indexPath.row];
    return cell;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id desVc = segue.destinationViewController;
    if ([desVc isKindOfClass:[JKChatViewController class]]) {
        NSInteger row = [self.tableView indexPathForSelectedRow].row;
        JKChatViewController *chatVc = desVc;
        chatVc.title = self.buddyList[row];
    }
}

#pragma mark - TableView Delegate Methods

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            EMError *error = [[EMClient sharedClient].contactManager deleteContact:self.buddyList[indexPath.row]];
            if (!error) {
                NSLog(@"删除成功");
            }
        });
        [self fetchBuddyList];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    JKChatViewController *chatVc = [sb instantiateViewControllerWithIdentifier:@"JKChatViewController"];
    chatVc.title = self.buddyList[indexPath.row];
    [self.navigationController pushViewController:chatVc animated:YES];
}

#pragma mark - ContactManager Delegate Methods
/**
 *  发出的好友请求被接受了
 *
 *  @param username <#username description#>
 */
- (void)didReceiveAgreedFromUsername:(NSString *)aUsername {
    NSString *message = [aUsername stringByAppendingString:@" 同意添加你为好友"];
    [self presentBuddyRequestAlertControllerWithMessage:message];
    // 刷新表格，显示新好友
    [self fetchBuddyList];
}

/**
 *  发出的好友请求被拒绝了
 *
 *  @param username <#username description#>
 */
- (void)didReceiveDeclinedFromUsername:(NSString *)aUsername {
    NSString *message = [aUsername stringByAppendingString:@" 拒绝了你的好友请求"];
    [self presentBuddyRequestAlertControllerWithMessage:message];
}


/**
 *  自动登录完成回调
 *
 *  @param loginInfo <#loginInfo description#>
 *  @param error     <#error description#>
 */
- (void)didAutoLoginWithError:(EMError *)aError {
    if (!aError) {
        [self fetchBuddyList];
        NSLog(@"%@",self.buddyList);
    } else {
        NSLog(@"自动登录错误:%@",aError);
    }
}

/**
 *  收到好友添加请求
 *
 *  @param username <#username description#>
 *  @param message  <#message description#>
 */
- (void)didReceiveFriendInvitationFromUsername:(NSString *)aUsername
                                       message:(NSString *)aMessage {
    self.username = aUsername;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"好友添加请求"
                                                                   message:aMessage
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *reject = [UIAlertAction actionWithTitle:@"拒绝"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                       [[EMClient sharedClient].contactManager declineInvitationForUsername:self.username];
                                                   }];
    
    UIAlertAction *accept = [UIAlertAction actionWithTitle:@"接受"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [[EMClient sharedClient].contactManager acceptInvitationForUsername:self.username];
                                                   }];
    
    [alert addAction:reject];
    [alert addAction:accept];
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 *  弹出好友请求窗口
 *
 *  @param message <#message description#>
 */
- (void)presentBuddyRequestAlertControllerWithMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"好友请求"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
