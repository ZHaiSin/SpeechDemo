# SpeechDemo
IOS推送播报金额<br>
IOS10中有新的推送`ServiceExtension`在推送来的时候可以进行语音播报.<br>
使用`AVSpeechUtterance`是肯定不行的。<br>
所以换了一种方法,在收到推送的时候进行语音文件的拼接,然后进行播放<br>
`本地推送是无效的`,只有在远程推送才会有效果,安利一个推送测试的工具[Easy APNs Provider](https://itunes.apple.com/cn/app/easy-apns-provider-tui-song/id989622350?mt=12),效果非常棒,再也不用求后台给发推送了,具体使用说明网上很多,自行百度吧.
本地发送推送是点击Button后会合成文件并且播放<br>
如果项目无法运行请更换开发者账号,并且更换`Bundle identifier`和`ServiceExtension`的前缀即可
 ```Objective-C
/**
 //传入字符串
 例:1351.42
 返回 (@"1",@"千",@"3",@"百",@"5",@"十",@"1",@"点",@"4",@"2",@"元")
 该方法会合成字符串数组，用来组装语音
 如果到了10W元就返回空
 **/
+ (NSMutableArray *)combinationString:(NSString *)string;
 ```
 ```Objective-C
/**
 //传入字符串数组
 例:
 1351.42
 (@"1",@"千",@"3",@"百",@"5",@"十",@"1",@"点",@"4",@"2",@"元")
 然后该方法会合成一段语音文件保存在 Documents/Audio 里面
 块里面是合成后的音频文件,如果失败返回空
 **/
+ (void)combinationAudio:(NSArray *)stringArr syntheticComplete:(syntheticComplete)complete;
 ```
 ### 使用例子
 ```Objective-C
 NSMutableArray * amoutArr = [SpeechTool combinationString:[NSString stringWithFormat:@"%@",@(10.99f)]];
    [SpeechTool combinationAudio:amoutArr syntheticComplete:^(NSString *audioPath) {
        //播放出来,AVAudioPlayer 必须要设置成为属性
        NSLog(@"%@",audioPath);
        _movePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioPath] error:nil];
        _movePlayer.delegate = self;
        [_movePlayer prepareToPlay];
        [_movePlayer play];
    }];
 ```
 
只能识别到10万元以下,目前来看应该不会超过10万元的。。<br>
我的QQ897864841.如果不懂可以来问我(里面我有写的注释,应该不是很难理解)
