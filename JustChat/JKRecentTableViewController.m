//
//  JKRecentTableViewController.m
//  JustChat
//
//  Created by 宋旭 on 16/6/27.
//  Copyright © 2016年 sky. All rights reserved.
//

#import "JKRecentTableViewController.h"
#import "JKChatViewController.h"
#import "EMSDK.h"

@interface JKRecentTableViewController () <EMChatManagerDelegate>

@property (nonatomic, strong) NSArray *conversations;

@end

@implementation JKRecentTableViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConversations];
    /** 注册消息回调 */
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateUI];
}

- (void)dealloc {
    /** 移除消息回调 */
    [[EMClient sharedClient].chatManager removeDelegate:self];
}

#pragma mark - Private Methods
/**
 *  加载历史对话记录
 */
- (void)loadConversations {
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    
    if (0 == conversations.count) {
        conversations = [[EMClient sharedClient].chatManager loadAllConversationsFromDB];
    }
    self.conversations = conversations;
}

/**
 *  刷新UI
 */
- (void)updateUI {
    [self.tableView reloadData];
    
    /** 设置tabbarButton的总未读消息数 */
    NSInteger totalCount = 0;
    for (EMConversation *conversation in self.conversations) {
        totalCount += [conversation unreadMessagesCount];
    }
    
    if (totalCount > 0) {
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%zd",totalCount];
    } else {
        self.navigationController.tabBarItem.badgeValue = nil;
    }
    /** AppIcon的badge */
    [UIApplication sharedApplication].applicationIconBadgeNumber = totalCount;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConversationCell"];
    
    EMConversation *conversation = self.conversations[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ 未读消息数%zd", conversation.conversationId,conversation.unreadMessagesCount];
    
    // 最后一条信息
    EMMessageBody *body = [conversation latestMessage].body;
    
    switch (body.type) {
        case EMMessageBodyTypeText:
            cell.detailTextLabel.text = [(EMTextMessageBody *)body text];
            break;
        case EMMessageBodyTypeImage:
            cell.detailTextLabel.text = @"[图片]";
            break;
        case EMMessageBodyTypeVoice:
            cell.detailTextLabel.text = [NSString stringWithFormat:@"[语音]%d'",[(EMVoiceMessageBody *)body duration]];
            break;
        default:
            cell.detailTextLabel.text = @"未知的消息类型";
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    JKChatViewController *chatVC = [storyBoard instantiateViewControllerWithIdentifier:@"JKChatViewController"];
    EMConversation *conversation = self.conversations[indexPath.row];
    chatVC.title = conversation.conversationId;
    
    /** 转入聊天界面 */
    [self.navigationController pushViewController:chatVC animated:YES];
}

#pragma mark - EMChatManager Delegate Methods
/**
 *  更新会话列表
 *
 *  @param aConversationList 新的会话列表
 */
- (void)didUpdateConversationList:(NSArray *)aConversationList {
    self.conversations = aConversationList;
    [self updateUI];
}

/**
 *  消息状态发生改变
 *
 *  @param aMessage <#aMessage description#>
 *  @param aError   <#aError description#>
 */
-(void)didMessageStatusChanged:(EMMessage *)aMessage error:(EMError *)aError {
    [self updateUI];
}

- (void)didConnectionStateChanged:(EMConnectionState)aConnectionState {
    NSLog(@"服务器连接状态:%@",aConnectionState == 0 ? @"已连接" : @"未连接");
}

@end
