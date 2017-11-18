//
//  BLTSendModel.m
//  PlaneCup
//
//  Created by zorro on 15/3/19.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import "BLTSendModel.h"

@implementation BLTSendModel

#pragma mark --- 命令转发中心 ---
- (void)sendDataToWare:(UInt8 *)val
            withLength:(NSInteger)length
            withUpdate:(BLTAcceptModelUpdateValue)block
{
    usleep(50000);
    [BLTPeripheral sharedInstance].lastInfo = val;
    [BLTAcceptModel sharedInstance].updateValue = block;
    [BLTAcceptModel sharedInstance].type = BLTAcceptModelTypeUnKnown;
    [BLTAcceptModel sharedInstance].dataType = BLTAcceptModelDataTypeUnKnown;
    
    NSData *sData = [[NSData alloc] initWithBytes:val length:length];
    //    NSLog(@"sData>>>>>>>>%@",sData);
    
    [[BLTPeripheral sharedInstance] senderDataToPeripheral:sData];
}

#pragma mark --- 命令转发中心 ---
- (void)sendDataToWare:(UInt8 *)val
            withLength:(NSInteger)length
            withUpdate:(BLTAcceptModelUpdateValue)block withBleModel:(BLTModel *)model
{
    usleep(50000);
    [BLTPeripheral sharedInstance].lastInfo = val;
    [BLTAcceptModel sharedInstance].updateValue = block;
    [BLTAcceptModel sharedInstance].type = BLTAcceptModelTypeUnKnown;
    [BLTAcceptModel sharedInstance].dataType = BLTAcceptModelDataTypeUnKnown;
    
    NSData *sData = [[NSData alloc] initWithBytes:val length:length];

    [[BLTPeripheral sharedInstance] senderDataToPeripheral:sData withPeripheral:model.peripheral];
}

///设置时间
- (void)sendSetTimeforDeviceWithUpdate:(BLTAcceptModelUpdateValue)block
{
    NSDate *date = [NSDate date];
    int i = date.year;
    int yearHeight = 0;
    int yearLow = 0;
    yearHeight = i / 256;
    yearLow = i - yearHeight *256;
    
    UInt8 val[10] = {0x05,0x02, 0x01, yearHeight, yearLow,date.month,date.day,date.hour,date.minute,date.second};
    [self sendDataToWare:val withLength:10 withUpdate:block];
}

///获取设备基本信息
- (void)sendGetDeviceBasicInfoWithUpdate:(BLTAcceptModelUpdateValue)block
{
    UInt8 val[3] = {0x05,0x01,0x02};
    [self sendDataToWare:val withLength:3 withUpdate:block];
}

//写入数据
- (void)sendSendValue:(BLTAcceptModelUpdateValue)block withString:(NSString *)writeString
{
    UInt8 val[20] = {0};
    
    if (writeString.length %2 ==0)
    {
        for (int i = 0; i <writeString.length ; i +=2)
        {
             NSString * stringValue = [writeString substringWithRange:NSMakeRange(i, 2)];
            int num = stringValue.intValue;
            val[i/2] = num;
//            NSLog(@"val>>>>>>>>%d  序号>>>>%d",val[i/2],i/2);
        }
    }
     [self sendDataToWare:val withLength:10 withUpdate:block];
}

// 屏幕测试
- (void)screenTest:(BLTAcceptModelUpdateValue)block
{
    UInt8 val[4] = {0};
    val[0] = 0x54;
    val[1] = 0x01;
    [self sendDataToWare:val withLength:2 withUpdate:block];
}

//马达测试
- (void)motorTest:(BLTAcceptModelUpdateValue)block
{
    UInt8 val[4] = {0};
    val[0] = 0x54;
    val[1] = 0x02;
    [self sendDataToWare:val withLength:2 withUpdate:block];
}

//三轴测试
- (void)threeaxisTest:(BLTAcceptModelUpdateValue)block
{
    UInt8 val[4] = {0};
    val[0] = 0x54;
    val[1] = 0x03;
    [self sendDataToWare:val withLength:2 withUpdate:block];
}

//字库测试
- (void)fontTest:(BLTAcceptModelUpdateValue)block
{
    UInt8 val[4] = {0};
    val[0] = 0x54;
    val[1] = 0x04;
    [self sendDataToWare:val withLength:2 withUpdate:block];
}

// 找手环
- (void)sendSetFindBle:(BOOL)Find withUpdateBlock:(BLTAcceptModelUpdateValue)block
{
    UInt8 val[4] = {0};
    val[0] = 0x05;
    val[1] = 0x05;
    val[2] = 0x03;
    val[3] = Find;
    [self sendDataToWare:val withLength:4 withUpdate:block];
}

// 拍照控制
- (void)sendControlTakePhotoState:(BOOL)type WithUpdateBlock:(BLTAcceptModelUpdateValue)block
{
    UInt8 val[4] = {0x05, 0x05, 0x02, type};
    [self sendDataToWare:val
              withLength:4
              withUpdate:block];
}

//心率测试
- (void)heartTest:(BLTAcceptModelUpdateValue)block type:(BOOL)open
{
    NSInteger send = 0;
    if (open)
    {
        send = 1;
    }
    UInt8 val[4] = {0};
    val[0] = 0x05;
    val[1] = 0x05;
    val[2] = 0x01;
    val[3] = send;
    [self sendDataToWare:val withLength:4 withUpdate:block];
}

//血氧测试
- (void)oxTest:(BLTAcceptModelUpdateValue)block type:(BOOL)open
{
    NSInteger send = 0;
    if (open)
    {
        send = 1;
    }
    UInt8 val[4] = {0};
    val[0] = 0x05;
    val[1] = 0x05;
    val[2] = 0x04;
    val[3] = send;
    [self sendDataToWare:val withLength:4 withUpdate:block];
}

//血压测试
- (void)bpTest:(BLTAcceptModelUpdateValue)block type:(BOOL)open
{
    NSInteger send = 0;
    if (open)
    {
        send = 1;
    }
    UInt8 val[4] = {0};
    val[0] = 0x05;
    val[1] = 0x05;
    val[2] = 0x05;
    val[3] = send;
    [self sendDataToWare:val withLength:4 withUpdate:block];
}

// 用户信息
- (void)sendUserInfoSettingWithBlock:(BLTAcceptModelUpdateValue)block
{
    UInt8 val[11] = {0x05, 0x02, 0x02, 0, 25, KK_User.height,
        KK_User.weight, [self showcurrentlanguage].integerValue, 0, 0,0x00};
    
    [self sendDataToWare:val withLength:11 withUpdate:block];
}

- (NSString *)showcurrentlanguage
{
    NSString *languageValue = @"0";
    
    NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *languageName = [appLanguages objectAtIndex:0];
    NSLog(@"系统语言>>>%@",languageName);
    
    if ([languageName isEqualToString:@"zh-Hans-CN"])
    {
        languageValue = @"0";
    }
    else if ([languageName isEqualToString:@"en-CN"])
    {
        languageValue = @"1";
    }
    
    return languageValue;
}

//实时步数
-  (void)realStep:(BLTAcceptModelUpdateValue)block
{
    UInt8 val[3] = {0x05,0x07,0x01};
    [self sendDataToWare:val withLength:3 withUpdate:block];
}

- (void)sendTestWithBlock:(BLTAcceptModelUpdateValue)block
{
    
}

///记步大数据
- (void)sendBigStepWithUpdate:(BLTAcceptModelUpdateValue)block
{
    UInt8 val[3] = {0x05,0x07,0x03};
    [self sendDataToWare:val withLength:3 withUpdate:block];
}

///睡眠大数据
- (void)sendBigSleepWithUpdate:(BLTAcceptModelUpdateValue)block;
{
    UInt8 val[3] = {0x05,0x07,0x04};
    [self sendDataToWare:val withLength:3 withUpdate:block];
}

///心率大数据 2017 10 26
- (void)sendBigheartWithUpdate:(BLTAcceptModelUpdateValue)block;
{
    UInt8 val[3] = {0x05,0x07,0x07};
    [self sendDataToWare:val withLength:3 withUpdate:block];
}

// 喝水提醒设置
- (void)sendSetDeviceDrinkRemindWithUpdateBlock:(BLTAcceptModelUpdateValue)block;
{
    
}

// 久坐提醒设置
- (void)sendSetDeviceSedentaryRemindWithUpdateBlock:(BLTAcceptModelUpdateValue)block
{
    
}

//设置闹钟
- (void)sendSetDeviceAlarmClock_KK:(AlarmClockModel *)model
                   withUpdateBlock:(BLTAcceptModelUpdateValue)block
{
    
}

//多连接
- (void)sendTestWithBlock:(BLTAcceptModelUpdateValue)block withModel:(BLTModel *)model
{
     UInt8 val[3] = {0x05,0x07,0x01};
    [self sendDataToWare:val withLength:3 withUpdate:block withBleModel:model];
}

@end

