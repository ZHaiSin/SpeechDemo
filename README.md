# SpeechDemo
IOS推送播报金额
    1<br>
2<br> 
    IOS10中有新的推送`ServiceExtension`在推送来的时候可以进行语音播报.
    使用`AVSpeechUtterance`是肯定不行的。
    所以换了一种方法,在收到推送的时候进行语音文件的拼接,然后进行播放
    `本地推送是无效的`,只有在远程推送才会有效果,本地是点击Button后会合成文件并且播放
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
只能识别到10万元以下,目前来看应该不会超过10万元的。。
我的QQ897864841.如果不懂可以来问我(里面我有写的注释,应该不是很难理解)
