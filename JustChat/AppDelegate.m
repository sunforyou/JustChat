//
//  AppDelegate.m
//  JustChat
//
//  Created by 宋旭 on 16/6/26.
//  Copyright © 2016年 sky. All rights reserved.
//

#import "AppDelegate.h"
#import "EMSDK.h"

@interface AppDelegate () <EMChatManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    /** 环信的初始化 并隐藏日志输出 */
    [[EMClient sharedClient] initializeSDKWithOptions:[EMOptions optionsWithAppkey:@"skysx#easemobsdklearning"]];
    
    /** 自动接收好友申请*/
    [[EMClient sharedClient].options setIsAutoAcceptFriendInvitation:YES];

    /** 设置自动登录主界面 */
    if ([[EMClient sharedClient] isAutoLogin]) {
        NSLog(@"自动登录成功-------->%@,欢迎回来!",[[EMClient sharedClient] currentUsername]);
        
        self.window.rootViewController = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController;
    } else {
        NSLog(@"未登录");
    }
    
    /** 添加badge权限 */
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
    [application registerUserNotificationSettings:settings];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
