//
//  AppDelegate.h
//  SMOOT
//
//  Created by zorro on 15/10/14.
//  Copyright © 2015年 zorro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign) CGFloat volume;

- (void)startMotion;
- (void)playVoice;
- (void)stopMotion;
- (void)stopPlayer;

@end

