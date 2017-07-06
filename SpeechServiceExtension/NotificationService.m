//
//  NotificationService.m
//  SpeechServiceExtension
//
//  Created by 海鑫 on 2017/7/6.
//  Copyright © 2017年 X. All rights reserved.
//

#import "NotificationService.h"
#import "SpeechTool.h"
@interface NotificationService ()<AVAudioPlayerDelegate>

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;
@property (nonatomic,strong) AVAudioPlayer * movePlayer ;
@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    self.bestAttemptContent.sound = nil;
    NSLog(@"收到推送");
    //最多支持到99999.99元 估计也不会有这么多的。。。
    NSMutableArray * amoutArr = [SpeechTool combinationString:[NSString stringWithFormat:@"%@",@(10.99f)]];
    [amoutArr insertObject:@"卡券宝为您收款" atIndex:0];
    [amoutArr addObject:@"已优惠"];
    [amoutArr addObjectsFromArray:[SpeechTool combinationString:[NSString stringWithFormat:@"%@",@(9.9f)]]];
    [SpeechTool combinationAudio:amoutArr syntheticComplete:^(NSString *audioPath) {
        //播放出来,AVAudioPlayer 必须要设置成为属性
        NSLog(@"%@",audioPath);
        _movePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioPath] error:nil];
        _movePlayer.delegate = self;
        [_movePlayer prepareToPlay];
        [_movePlayer play];
    }];
}
// 音频播放完成时
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    // 音频播放完成时，调用该方法。
    // 参数flag：如果音频播放无法解码时，该参数为NO。
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

@end
