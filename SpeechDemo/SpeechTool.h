//
//  SpeechTool.h
//  cn.wecool.card1
//
//  Created by 海鑫 on 2017/7/6.
//  Copyright © 2017年 X. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface SpeechTool : NSObject

typedef void(^syntheticComplete)(NSString * audioPath);

/**
 //传入字符串
 例:1351.42
 返回 (@"1",@"千",@"3",@"百",@"5",@"十",@"1",@"点",@"4",@"2",@"元")
 该方法会合成字符串数组，用来组装语音
 如果到了10W元就返回空
 **/
+ (NSMutableArray *)combinationString:(NSString *)string;
/**
 //传入字符串数组
 例:
 1351.42
 (@"1",@"千",@"3",@"百",@"5",@"十",@"1",@"点",@"4",@"2",@"元")
 然后该方法会合成一段语音文件保存在 Documents/Audio 里面
 块里面是合成后的音频文件,如果失败返回空
 **/
+ (void)combinationAudio:(NSArray *)stringArr syntheticComplete:(syntheticComplete)complete;
@end
