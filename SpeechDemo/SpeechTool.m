//
//  SpeechTool.m
//  cn.wecool.card1
//
//  Created by 海鑫 on 2017/7/6.
//  Copyright © 2017年 X. All rights reserved.
//

#import "SpeechTool.h"
#define MP3BundleFileStringPath(string) [[NSBundle mainBundle] pathForResource:string ofType:@"mp3"]
@implementation SpeechTool
/**
 //传入字符串
 例:1351.42
 返回 (@"1",@"千",@"3",@"百",@"5",@"十",@"1",@"点",@"4",@"2",@"元")
 该方法会合成字符串数组，用来组装语音
 **/
+ (NSMutableArray *)combinationString:(NSString *)string{
    if ([string floatValue] > 99999.99) {//如果到了10W元就返回空。
        return [@[] mutableCopy];
    }
    NSMutableArray * amountArr = [NSMutableArray array];//最后生成的数组
    if ([string isEqualToString:@"2"]) {//如果整好等于2 特殊 变成两元
        [amountArr addObject:@"两"];
        [amountArr addObject:@"元"];
        return amountArr;
    }
    NSArray * yuanArr = [string componentsSeparatedByString:@"."];
    NSMutableArray * stringArr = [NSMutableArray array];
    NSString * yuanString = yuanArr[0];
    
    for (int i = 0; i < yuanString.length; i++) {//把元 拆分成一个一个的字符串
        [stringArr addObject:[yuanString substringWithRange:NSMakeRange(i, 1)]];
    }
    for (int i = 0; i<stringArr.count; i++) {
        NSString * string = @"";
        string = stringArr[i];//设置数字金额
        if (i == 0 && stringArr.count == 2 && [stringArr[0] isEqualToString:@"1"]) {//如果是10元 特殊 把1换成10 在循环最后一次会加上元
            string = @"十";
            [amountArr addObject:string];
            continue;
        }
        if ([stringArr[i] isEqualToString:@"0"]) {
            if (stringArr.count - 1 == i) {//如果最后一位是0 ,10.XX元
                if (stringArr.count == 1) {//如果只有1位数并且是0，  例子 0.XX 元
                    [amountArr addObject:@"0"];
                }
                [amountArr addObject:@"元"];//后面加上一个元,后面会替换成点
            }else if (![[amountArr lastObject] isEqualToString:@"0"] && ![[stringArr lastObject] isEqualToString:@"0"]) {//如果是 102的情况 需要一个 一百 “零“ 二元 (如果上一位也是零则不再加零 1002) 如果是100的话,判断最后一位是否是0,如果是0的话 则是百最后一位不加0
                    [amountArr addObject:@"0"];
            }
            continue;
        }
        [amountArr addObject:string];
        string = [self unit:stringArr.count - i];//设置单位
        [amountArr addObject:string];
    }
    
    if (yuanArr.count == 1) {//如果只有一位数 就是整数10元以下 直接返回
        return amountArr;
    }
    NSString * decimalString = yuanArr[1];
    if (![decimalString isEqualToString:@"00"]) {//如果后面带小数金额
        [amountArr replaceObjectAtIndex:amountArr.count - 1 withObject:@"点"];
        for (int i = 0; i < decimalString.length; i++) {
            [amountArr addObject:[decimalString substringWithRange:NSMakeRange(i, 1)]];
        }
        [amountArr addObject:@"元"];
    }
    return amountArr;
}

+ (NSString *)unit:(NSInteger)number{
    return @[@"元",@"十",@"百",@"千",@"万"][number - 1];
}
/**
 //传入字符串数组
 例:
 1351.42
 (@"1",@"千",@"3",@"百",@"5",@"十",@"1",@"点",@"4",@"2",@"元")
 然后该方法会合成一段语音文件保存在 Documents/Audio 里面
 **/
+ (void)combinationAudio:(NSArray *)stringArr syntheticComplete:(syntheticComplete)complete{
    //创建合成器
    AVMutableComposition *composition = [AVMutableComposition composition];
    //创建音频轨道
    AVMutableCompositionTrack *audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:0];
    //把传进来的 数组 进行拼接
    [stringArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //根据URL 获取音频素材素材  audioString:  方法用来转换URL 由于直接写循环 获取上一个duration麻烦所以直接反顺拼接 全部拼接到最前面
        /**
         一百元
         如果不反顺序就会变成
         第一个拼接的是"一"
         第二个拼接的是"百" 就变成 "百一"
         第三个是"元" 就变成 "元百一"
         反顺序的话就是
         第一个拼接的是"百"
         第二个拼接的是"一" 就变成 "一百"
         第三个是"元" 就变成 "一百元"
         */
        AVURLAsset * tempAudioAsset = [AVURLAsset assetWithURL:[SpeechTool audioString:stringArr[stringArr.count - idx - 1]]];
        //获取素材的轨道
        AVAssetTrack * tempAudioAssetTrack = [[tempAudioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
        //进行拼接
        [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, tempAudioAsset.duration) ofTrack:tempAudioAssetTrack atTime:kCMTimeZero error:nil];
    }];
    //检测是否有文件夹 没有就创建
    NSString * path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"Audio"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if(!(isDirExist && isDir)){
        BOOL bCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建文件夹失败！");
        }
        NSLog(@"创建文件夹成功，文件路径%@",path);
    }
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetAppleM4A];
    //设置合成音频文件路径
    NSString * outPutFilePath = [path stringByAppendingString:@"/image4.m4a"];
    //防止音频文件存在,先把文件删除
    [fileManager removeItemAtPath:outPutFilePath error:nil];
    
    session.outputURL = [NSURL fileURLWithPath:outPutFilePath];
    session.outputFileType = AVFileTypeAppleM4A;
    [session exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"合并完成输出路径----%@", outPutFilePath);
        complete(outPutFilePath);
    }];
}
//传入 字符串 返回对应的音频URL
+ (NSURL *)audioString:(NSString *)string{
    NSString * audioString = @"";
    if ([string isEqualToString:@"0"]) {
        audioString = MP3BundleFileStringPath(@"zero");
    }else if ([string isEqualToString:@"1"]){
        audioString = MP3BundleFileStringPath(@"one");
    }else if ([string isEqualToString:@"2"]){
        audioString = MP3BundleFileStringPath(@"two");
    }else if ([string isEqualToString:@"3"]){
        audioString = MP3BundleFileStringPath(@"three");
    }else if ([string isEqualToString:@"4"]){
        audioString = MP3BundleFileStringPath(@"four");
    }else if ([string isEqualToString:@"5"]){
        audioString = MP3BundleFileStringPath(@"five");
    }else if ([string isEqualToString:@"6"]){
        audioString = MP3BundleFileStringPath(@"six");
    }else if ([string isEqualToString:@"7"]){
        audioString = MP3BundleFileStringPath(@"seven");
    }else if ([string isEqualToString:@"8"]){
        audioString = MP3BundleFileStringPath(@"eight");
    }else if ([string isEqualToString:@"9"]){
        audioString = MP3BundleFileStringPath(@"nine");
    }else if ([string isEqualToString:@"点"]){
        audioString = MP3BundleFileStringPath(@"dian");
    }else if ([string isEqualToString:@"元"]){
        audioString = MP3BundleFileStringPath(@"yuan");
    }else if ([string isEqualToString:@"十"]){
        audioString = MP3BundleFileStringPath(@"ten");
    }else if ([string isEqualToString:@"百"]){
        audioString = MP3BundleFileStringPath(@"hundred");
    }else if ([string isEqualToString:@"千"]){
        audioString = MP3BundleFileStringPath(@"thousand");
    }else if ([string isEqualToString:@"万"]){
        audioString = MP3BundleFileStringPath(@"million");
    }else if ([string isEqualToString:@"两"]){
        audioString = MP3BundleFileStringPath(@"两");
    }
    return [NSURL fileURLWithPath:audioString];
}
@end
