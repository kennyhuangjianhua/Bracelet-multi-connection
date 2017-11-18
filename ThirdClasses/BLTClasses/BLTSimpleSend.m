//
//  BLTSimpleSend.m
//  BopLost
//
//  Created by zorro on 15/4/9.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import "BLTSimpleSend.h"

#define WAITDELAYTIME 0.2
@implementation BLTSimpleSend

DEF_SINGLETON(BLTSimpleSend)

/**
 *   ---------------------------------   外部调用的命令   --------------------------------------
 */
#pragma mark --- 蓝牙连接后发送连续的指令 ---
- (void)sendContinuousInstruction
{
    // 纪录最后一次连的设备的uuid。
    
//    if ([BLTManager sharedInstance].model.bltUUID.length > 0)
//    {
//        [AJ_LastWareUUID setObjectValue:[BLTManager sharedInstance].model.bltUUID];
//    }
//
//    [BLTManager sharedInstance].model.isBinding = YES;
//
//    NSLog(@"AJ_LastWareUUID = ..%@", [AJ_LastWareUUID getObjectValue]);
//
    // 重连时将相关信息重置.
    _synState = BLTSimpleSendSynWait;
    [BLTAcceptModel sharedInstance].updateValue = nil;
    [self resetAll];
    
     [self performSelector:@selector(setting1) withObject:nil afterDelay:1.0];
}

- (void)resetAll
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setting1) object:nil];
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setting2) object:nil];
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setting3) object:nil];
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setting4) object:nil];
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setting5) object:nil];
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setting6) object:nil];
}

- (void)setting1
{
    [KK_BLTSend sendSetTimeforDeviceWithUpdate:^(id object, BLTAcceptModelType type)
     {
         if (type == BLTAcceptModelTypeDevideInfo)
         {
             
         }
     }];
    
//    [self performSelector:@selector(setting2) withObject:nil afterDelay:WAITDELAYTIME];
}

- (void)setting2
{
    [KK_BLTSend sendGetDeviceBasicInfoWithUpdate:^(id object, BLTAcceptModelType type)
     {
         
     }];
    [self performSelector:@selector(setting3) withObject:nil afterDelay:WAITDELAYTIME];
}

- (void)setting3
{
    [self performSelector:@selector(setting4) withObject:nil afterDelay:WAITDELAYTIME];
}

- (void)setting4
{
    [self performSelector:@selector(setting5) withObject:nil afterDelay:WAITDELAYTIME];
}

- (void)setting5
{
    [self performSelector:@selector(setting6) withObject:nil afterDelay:WAITDELAYTIME];
}

- (void)setting6
{
    
    [self performSelector:@selector(settinglast) withObject:nil afterDelay:WAITDELAYTIME];
}

- (void)settinglast
{
    
}

@end
