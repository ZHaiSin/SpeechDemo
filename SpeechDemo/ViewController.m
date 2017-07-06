//
//  ViewController.m
//  SpeechDemo
//
//  Created by 海鑫 on 2017/7/6.
//  Copyright © 2017年 X. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "SpeechTool.h"
@interface ViewController ()<AVAudioPlayerDelegate>
@property (nonatomic,strong) AVAudioPlayer * movePlayer ;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //本地推送不走IOS10 的新的拓展 不知道为什么 所以在这里面写了一份 推送哪里也是有的远程推送会触发效果， 包括在后台 和 被杀死的情况
    UIButton * sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(0, 0, 120, 20);
    sendButton.center = self.view.center;
    [sendButton setTitle:@"发送一条推送(本地推送无效)" forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont systemFontOfSize:12];
    sendButton.backgroundColor = [UIColor blueColor];
    
    [sendButton addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendButton];
}

- (void)send{
    /**
    UNMutableNotificationContent * content = [[UNMutableNotificationContent alloc] init];
    content.title = @"收款!";
    content.body = @"12.8元";
    content.sound = [UNNotificationSound defaultSound];
    //延迟发送
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
    NSString *identifier = @"push";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        //发送成功
        if (!error) {
            NSLog(@"发送推送成功");
        }
    }];
     */
    NSMutableArray * amoutArr = [SpeechTool combinationString:[NSString stringWithFormat:@"%@",@(10.99f)]];
    [SpeechTool combinationAudio:amoutArr syntheticComplete:^(NSString *audioPath) {
        //播放出来,AVAudioPlayer 必须要设置成为属性
        NSLog(@"%@",audioPath);
        _movePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioPath] error:nil];
        _movePlayer.delegate = self;
        [_movePlayer prepareToPlay];
        [_movePlayer play];
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
