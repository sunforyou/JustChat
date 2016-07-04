//
//  JKChatViewController.m
//  JustChat
//
//  Created by 宋旭 on 16/6/27.
//  Copyright © 2016年 sky. All rights reserved.
//

#import "JKChatViewController.h"
#import "JKChatCell.h"
#import "JKTimeCell.h"
#import "EMCDDeviceManager.h"
#import "JKAudioPlayTool.h"
#import "JKTimeTool.h"

@interface JKChatViewController () <UITableViewDataSource,UITableViewDelegate,EMChatManagerDelegate,UITextViewDelegate>
/** 聊天表格 */
@property (weak, nonatomic) IBOutlet UITableView *tableView;
/** 计算cell高度的对象 */
@property (strong, nonatomic) JKChatCell *chatCellTool;
/** "输入控件"高度约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewHeihgt;
/** "输入控件"底部约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
/** 录音按钮 */
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
/** 聊天文本输入框 */
@property (weak, nonatomic) IBOutlet UITextView *textView;
/** 背景 */
@property (weak, nonatomic) IBOutlet UIImageView *textBg;
/** 最后一条的时间 */
@property (copy, nonatomic) NSString  *lastTime;
/** 聊天记录-数据源 */
@property (strong, nonatomic) NSMutableArray *records;
/** 当前会话 */
@property (strong, nonatomic) EMConversation *conversation;

@end

@implementation JKChatViewController

#pragma mark - Controller Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    /** 注册对话代理 */
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    /** 添加键盘显示与隐藏监听 */
    [self setupKeyboardObserver];
    /** 加载聊天数据 */
    [self loadChatData];
    /** 隐藏录音按钮 */
    self.recordBtn.hidden = YES;
    /** 背景色*/
    self.tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
}

-(void)viewDidAppear:(BOOL)animated{
    [self refreshDataAndScroll];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
}

/**
 *  加载聊天消息
 */
- (void)loadChatData {
    // 获取当前会话对象
    self.conversation = [[EMClient sharedClient].chatManager getConversation:self.title
                                                                        type:EMConversationTypeChat
                                                            createIfNotExist:YES];
    
    /** 当前时间到1970年间最新的100条消息 */
    long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    NSArray *records = [self.conversation loadMoreMessagesFrom:0
                                                            to:timestamp
                                                      maxCount:100];
    
    // 遍历信息为已读
    [records enumerateObjectsUsingBlock:^(EMMessage *msg, NSUInteger idx, BOOL *stop) {
        [self addDataSourceWithMessage:msg];
    }];
}

#pragma mark - Sending Messages
/**
 *  发送文字消息
 *
 *  @param text
 */
- (void)sendWithText:(NSString *)text {
    EMTextMessageBody *textBody = [[EMTextMessageBody alloc] initWithText:text];
    [self sendMessageWithBody:textBody];
}

/**
 *  发送图片消息
 *
 *  @param data <#data description#>
 */
- (void)sendImageWithData:(NSData *)data imageNamed:(NSString *)name {
    EMImageMessageBody *pictureBody = [[EMImageMessageBody alloc] initWithData:data
                                                                   displayName:name];
    [self sendMessageWithBody:pictureBody];
}

/**
 *  发送语音消息
 *
 *  @param filePath <#filePath description#>
 *  @param duration <#duration description#>
 */
- (void)sendWithRecordFile:(NSString *)filePath duration:(NSInteger)duration {
    EMVoiceMessageBody *voiceMessageBody = [[EMVoiceMessageBody alloc] initWithLocalPath:filePath displayName:@"[语音]"];
    voiceMessageBody.duration = (int)duration;
    [self sendMessageWithBody:voiceMessageBody];
}

/**
 *  向服务器发送聊天消息
 *
 *  @param body <#body description#>
 */
- (void)sendMessageWithBody:(EMMessageBody *)body {
    if (!body) return;
    
    NSString *from = [[EMClient sharedClient] currentUsername];
    
    EMMessage *message = [[EMMessage alloc] initWithConversationID:self.title
                                                              from:from
                                                                to:self.title
                                                              body:body
                                                               ext:nil];
    /** 设置消息类型为单聊 */
    message.chatType = EMChatTypeChat;
    /** 添加到数据源 */
    [self addDataSourceWithMessage:message];
    /** 刷新并滚动表格 */
    [self refreshDataAndScroll];
    /** 发送网络请求 */
    [[EMClient sharedClient].chatManager asyncSendMessage:message
                                                 progress:nil
                                               completion:^(EMMessage *aMessage, EMError *aError) {
                                                   
                                                   /** 将信息更新到DB */
                                                   [[EMClient sharedClient].chatManager updateMessage:aMessage];
                                                   NSLog(@"聊天消息发送完成\n %@",aError);
                                               }];
    
}

/**
 *  添加消息模型到数据源
 *
 *  @param msg <#msg description#>
 */
- (void)addDataSourceWithMessage:(EMMessage *)message {
    NSString *timeStr = [JKTimeTool timeStr:message.timestamp];
    
    /** 添加 “时间字符串” 到数据源 */
    if (![self.lastTime isEqualToString:timeStr]) {
        [self.records addObject:timeStr];
        self.lastTime = timeStr;
    }
    /** 添加 "消息模型" */
    [self.records addObject:message];
    /** 设置消息为"已读" */
    if (!message.isRead && [message.from isEqualToString:self.title]) {
        [self.conversation markAllMessagesAsRead];
    }
}

#pragma mark - TableView DataSource&Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.records.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    id record = self.records[indexPath.row];
    /** 时间类型的Cell */
    if ([record isKindOfClass:[NSString class]]) {
        return [JKTimeCell timeCell:tableView time:record];
    }
    /** 聊天类型的cell */
    return [JKChatCell chatCell:tableView message:record];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    /** 时间返回20的固定高度 */
    if ([self.records[indexPath.row] isKindOfClass:[NSString class]]) {
        return 20;
    }
    /** 聊天cell返回计算后的高度 */
    self.chatCellTool.message = self.records[indexPath.row];
    return [self.chatCellTool cellHeight];
}

#pragma mark - UITextView Delegate Methods
/**
 *  文字内容发生改变
 *
 *  @param textView <#textView description#>
 */
-(void)textViewDidChange:(UITextView *)textView{
    /** 复位光标 */
    [textView setContentOffset:CGPointZero animated:YES];
    /** 计算 “输入工具条” 高度 */
    CGFloat minHeight = 33;
    CGFloat maxHeight = 68;
    CGFloat toHeight = 0;
    if (textView.contentSize.height < minHeight) {
        toHeight = minHeight;
    } else if (textView.contentSize.height > 68) {
        toHeight = maxHeight;
    } else {
        toHeight = textView.contentSize.height;
    }
    /** 发消息 */
    if ([textView.text hasSuffix:@"\n"]) {
        /**  去除尾部的换行符 */
        NSString *text = textView.text;
        text = [text substringToIndex:text.length - 1];
        // 发送文本
        [self sendWithText:text];
        // 清空文本
        textView.text = nil;
        
        toHeight = minHeight;
    }
    /** 更改高度 */
    self.inputViewHeihgt.constant = toHeight + 8 + 5;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
        /** 动画结束后，再滚动到可见区域 */
        [textView scrollRangeToVisible:textView.selectedRange];
    }];
}

/**
 *  scrollView开始拖动回调
 *
 *  @param scrollView <#scrollView description#>
 */
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    /** 准备滑动表格时，要停止播放语音 */
    [JKAudioPlayTool stop];
}

#pragma mark - EMChatManager Delegate Methods
/**
 *  接收消息回执
 *
 *  @param message <#message description#>
 */
- (void)didReceiveMessage:(EMMessage *)message {
    if ([message.from isEqualToString:self.title]) {
        /** 添加消息到数据源 */
        [self addDataSourceWithMessage:message];
        /** 刷新表格并滚动到底部 */
        [self refreshDataAndScroll];
    }
}

#pragma mark - Button Clicked Events

- (IBAction)displayEmojView:(UIButton *)sender {
    NSLog(@"发送表情功能以后添加");
}

/**
 *  显示录音按钮
 *
 *  @param btn <#btn description#>
 */
- (IBAction)voiceAction:(UIButton *)btn {
    [self.view endEditing:YES];
    self.recordBtn.hidden =  !self.recordBtn.hidden;
    self.textView.hidden = !self.textView.hidden;
    self.textBg.hidden = !self.textBg.hidden;
    if (self.textView.hidden == YES) {
        [btn setImage:[UIImage imageNamed:@"chatBar_keyboard"] forState:UIControlStateNormal];
        self.inputViewHeihgt.constant = 46;
    }else{
        [btn setImage:[UIImage imageNamed:@"chatBar_record"] forState:UIControlStateNormal];
        [self textViewDidChange:self.textView];
        [self.textView becomeFirstResponder];
    }
}

/**
 *  开始录音
 *
 *  @return <#return value description#>
 */
- (IBAction)beginRecordAction:(id)sender {
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
    [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error) {
        if (error) {
            NSLog(@"开始录音");
        } else {
            NSLog(@"开始录音失败\n 错误提示:%@",error);
        }
    }];
}

/**
 *  结束录音
 *
 *  @param sender <#sender description#>
 */
- (IBAction)endRecordAction:(id)sender {
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            NSLog(@"结束录音 本地路径 %@",recordPath);
            [self sendWithRecordFile:recordPath duration:aDuration];
        } else {
            NSLog(@"结束录音失败\n 错误提示%@",error);
        }
    }];
}

/**
 *  取消录音
 *
 *  @param sender <#sender description#>
 */
- (IBAction)cancelRecordAction:(id)sender {
    NSLog(@"取消录音");
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
}

#pragma mark - Helpers
/**
 *  刷新界面
 */
- (void)refreshDataAndScroll {
    if (self.records.count == 0) {
        return;
    }
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.records.count - 1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
}

#pragma mark - KeyBoard Handlers
/**
 *  监控键盘弹出和隐藏通知
 */
- (void)setupKeyboardObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGFloat kbHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.bottomConstraint.constant = kbHeight;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.bottomConstraint.constant = 0;
}

#pragma mark - Getters
- (NSMutableArray *)records {
    if (!_records) {
        _records = [NSMutableArray array];
    }
    return _records;
}

- (JKChatCell *)chatCellTool {
    if (!_chatCellTool) {
        _chatCellTool = [self.tableView dequeueReusableCellWithIdentifier:ReceiverCell];
    }
    return _chatCellTool;
}

@end
