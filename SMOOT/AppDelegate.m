//
//  AppDelegate.m
//  SMOOT
//
//  Created by zorro on 15/10/14.
//  Copyright © 2015年 zorro. All rights reserved.
//

#import "AppDelegate.h"
#import "ZKKNavigationController.h"

#import "BLTManager.h"
#import "BLTSimpleSend.h"
#import "XYSandbox.h"

#import <AudioToolbox/AudioToolbox.h>
#import <CoreMotion/CoreMotion.h>

#import "ViewController.h"

#import "FileModelEntity.h"
#import "DeviceViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) ViewController *vc;

@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, assign) CGFloat offsetX;

@end

@implementation AppDelegate

@synthesize volume = _volume;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    [[ShareData sharedInstance]checkDeviceModel];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent; // 状态栏设置为白色文字
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    //        [self loadSpeakSdk];
    
//    ViewController *vc = [[ViewController alloc] init];
    DeviceViewController *vc = [[DeviceViewController alloc] init];
    UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:vc];
    nv.navigationBar.hidden = YES;
    self.window.rootViewController = nv;
    
    return YES;
}

//- (void)loadDeviceVc
//{
//    DeviceShowVC *showVC = [[DeviceShowVC alloc] init];
//    
//    [self.navigationController pushViewController:showVC animated:YES];
//
//}

- (void)createVideoFloders
{
    [XYSandbox createDirectoryAtPath:[[XYSandbox docPath] stringByAppendingPathComponent:@"/db/"]];
    [XYSandbox createDirectoryAtPath:[[XYSandbox docPath] stringByAppendingPathComponent:@"/dbimg/"]];
    
    // 通知不用上传备份
    [[[XYSandbox docPath] stringByAppendingPathComponent:@"/db/"] addSkipBackupAttributeToItem];
    [[[XYSandbox docPath] stringByAppendingPathComponent:@"/dbimg/"] addSkipBackupAttributeToItem];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    NSLog(@"执行");
}

- (void)startMotion
{
    if (_motionManager)
    {
        [_motionManager stopAccelerometerUpdates];
    }
    
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.accelerometerUpdateInterval = 1.0;
    [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue]
                                         withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
                                             
                                             double accelerationX = accelerometerData.acceleration.x;

                                             NSLog(@"移动检测..%f..%f..%f", accelerometerData.acceleration.x,
                                                   accelerometerData.acceleration.y, accelerometerData.acceleration.z);

                                             if (fabs(accelerationX) + fabsf(accelerometerData.acceleration.y) > 2.0)
                                             {
                                                 // NSLog(@"来了。。");
                                                 if (_player.volume < 0.1)
                                                 {
                                                     _player.volume = 1.0;
                                                 }
                                                 else if (_player.volume > 0.5)
                                                 {
                                                     _player.volume = 0.0;
                                                 }
                                             }
                                          
                                             _offsetX = accelerationX;
                                         }
     ];

}

- (void)playVoice
{
    [self stopPlayer];
    
    // 获取文件所在的路径
    NSString *path = [[NSBundle mainBundle] pathForResource:@"A2_3S" ofType:@"mp3"];
    // [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"静音1.mp3"];
    // 定义一个系统SystemSoundID的对象
    // 获取文件URL
    NSURL *filePath = [NSURL fileURLWithPath:path];
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:nil];
    [_player prepareToPlay];
    [_player setVolume:0];
    
    _player.numberOfLoops = -1; //设置音乐播放次数  -1为一直循环
    [_player play];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)stopMotion
{
    if (_motionManager)
    {
        [_motionManager stopAccelerometerUpdates];
    }
}

- (void)stopPlayer
{
    if (_player)
    {
        [_player stop];
        _player = nil;
    }
}

- (CGFloat)volume
{
    return _player.volume;
}

- (void)setVolume:(CGFloat)volume
{
    _player.volume = volume;
}

@end
