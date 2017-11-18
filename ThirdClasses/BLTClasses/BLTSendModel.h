//
//  BLTSendModel.h
//  PlaneCup
//
//  Created by zorro on 15/3/19.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#define BLT_Binding @"BLT_Binding"
#define BLT_InfoDelayTime 0.4 // 蓝牙通信间隔 避免造成堵塞.

#import <Foundation/Foundation.h>
#import "BLTAcceptModel.h"

//#import "AlarmClockModel.h"
//#import "CalendarModel.h"

//#import "DrinkModel.h"
//#import "PhysicalModel.h"
//#import "SedentaryModel.h"

typedef enum {
    BLTDeviceBaseInfo = 0,          // 基本信息
    BLTDeviceFunctionList = 1,      // 功能列表
    BLTDeviceTime = 2,              // 设备时间
    BLTDeviceMACAddress = 3,        // mac地址
    BLTDeviceElectricityInfo = 4    // 电池信息.
} BLTDeviceKeyList;

typedef enum {
    BLTRequestDataTypeByHand = 0,   // 手动同步
    BLTRequestDataTypeAuto = 1,     // 自动同步
} BLTRequestDataType;

typedef enum {
    BLTDeviceUnbundling = 0,        // 解绑
    BLTDeviceBinding = 1,           // 绑定
} BLTDeviceBindCMD;

typedef enum {
    BLTDeviceFuncLogOpen = 0,
    BLTDeviceFuncLogClose = 1,
    BLTDeviceFuncDebugOpen = 2,
    BLTDeviceFuncDebugClose = 3,
} BLTDeviceFunc;

@interface BLTSendModel : NSObject

typedef void(^BLTSendDataBackUpdate)(NSDate *date);

// 同步数据后通知界面回调更新. 这个只需要在需要显示同步数据的界面进行回调
@property (nonatomic, strong) BLTSendDataBackUpdate backBlock;

///设置时间
- (void)sendSetTimeforDeviceWithUpdate:(BLTAcceptModelUpdateValue)block;

///获取设备基本信息
- (void)sendGetDeviceBasicInfoWithUpdate:(BLTAcceptModelUpdateValue)block;

//写入数据
- (void)sendSendValue:(BLTAcceptModelUpdateValue)block withString:(NSString *)writeString;

//屏幕测试
- (void)screenTest:(BLTAcceptModelUpdateValue)block;

//马达测试
- (void)motorTest:(BLTAcceptModelUpdateValue)block;

//三轴测试
- (void)threeaxisTest:(BLTAcceptModelUpdateValue)block;

//字库测试
- (void)fontTest:(BLTAcceptModelUpdateValue)block;

// 找手环
- (void)sendSetFindBle:(BOOL)Find withUpdateBlock:(BLTAcceptModelUpdateValue)block;

// 拍照控制
- (void)sendControlTakePhotoState:(BOOL)type WithUpdateBlock:(BLTAcceptModelUpdateValue)block;

//心率测试
- (void)heartTest:(BLTAcceptModelUpdateValue)block type:(BOOL)open;

//血氧测试
- (void)oxTest:(BLTAcceptModelUpdateValue)block type:(BOOL)open;

//血压测试
- (void)bpTest:(BLTAcceptModelUpdateValue)block type:(BOOL)open;

// 用户信息
- (void)sendUserInfoSettingWithBlock:(BLTAcceptModelUpdateValue)block;

//实时步数
-  (void)realStep:(BLTAcceptModelUpdateValue)block;

///记步大数据
- (void)sendBigStepWithUpdate:(BLTAcceptModelUpdateValue)block;

///睡眠大数据
- (void)sendBigSleepWithUpdate:(BLTAcceptModelUpdateValue)block;

///心率大数据 2017 10 26
- (void)sendBigheartWithUpdate:(BLTAcceptModelUpdateValue)block;

// 喝水提醒设置
- (void)sendSetDeviceDrinkRemindWithUpdateBlock:(BLTAcceptModelUpdateValue)block;

// 久坐提醒设置
- (void)sendSetDeviceSedentaryRemindWithUpdateBlock:(BLTAcceptModelUpdateValue)block;

//设置闹钟
- (void)sendSetDeviceAlarmClock_KK:(AlarmClockModel *)model
                   withUpdateBlock:(BLTAcceptModelUpdateValue)block;

//重启设备
- (void)sendDeviceRebootWithUpdate:(BLTAcceptModelUpdateValue)block;

- (void)sendTestWithBlock:(BLTAcceptModelUpdateValue)block withModel:(BLTModel *)model;


@end

