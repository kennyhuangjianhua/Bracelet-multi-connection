//
//  BLTAcceptModel.h
//  PlaneCup
//
//  Created by zorro on 15/3/19.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLTManager.h"

@protocol BLTControlTypeDelegate <NSObject>

- (void)bltControlTakePhoto;

@end

typedef enum {                                   // 详细的看接口参数。
    
    BLTAcceptModelTypeUnKnown = 0,               // 无状态
    BLTAcceptModelTypeBindingSuccess,            // 绑定成功
    BLTAcceptModelTypeBindingTimeout,            // 绑定超时
    BLTAcceptModelTypeBindingError,              // 绑定错误
    BLTAcceptModelTypeUnBindingSuccess,          // 解绑成功
    BLTAcceptModelTypeUnBindingFail,             // 解绑失败
    
    BLTAcceptModelTypeStateControl,              // 状态控制
    BLTAcceptModelTypeStateRequest,              // 状态请求
    BLTAcceptModelTypeFrequencyControl,          // 频率控制
    BLTAcceptModelTypeMovementMode,              // 运动模式
    BLTAcceptModelTypeBuzzerMode,                // 蜂鸣器模式
    
    BLTAcceptModelTypeDevideInfo,                // 设备信息
    BLTAcceptModelTypeSetDateInfo,               // 时间信息
    BLTAcceptModelTypeSetUserInfo,               // 用户信息
    BLTAcceptModelTypeUpdateWare,                // 升级固件
    BLTAcceptModelTypeResetFinish,               // 重启成功
    
    //GETFIT 3.0 最新新增加协议
    BLTAcceptModelTypeSetAlarmClock,             // 设置闹钟
    BLTAcceptModelTypeSetSchedule,               // 设置日程
    BLTAcceptModelTypeSetRemind,                 // 设置久坐提醒
    BLTAcceptModelTypeSetDrink,                  // 设置喝水提醒
    BLTAcceptModelTypeSetPhysicalExamination,    // 设置定时体检提醒
    BLTAcceptModelTypeSetNotice,                 // 设置提醒开关
    BLTAcceptModelTypeSetLow,                    // 设置低电量
    BLTAcceptModelTypeSetFindBLE,                // 寻找手环
    
    BLTAcceptModelTypeSetSportTarget,            // 设置运动目标
    BLTAcceptModelTypeSetSleepTarget,            // 设置睡眠目标
    
    BLTAcceptModelTypeDataRequestSuccess,        // 数据请求成功
    BLTAcceptModelTypeDataTodaySport,            // 今天运动数据
    BLTAcceptModelTypeDataTodayCal,
    BLTAcceptModelTypeDataTodayDistance,
    BLTAcceptModelTypeDataTodaySleep,            // 今天睡眠数据
    BLTAcceptModelTypeDataHistorySport,          // 历史运动数据
    BLTAcceptModelTypeDataHistorySleep,          // 历史睡眠数据.
    
    BLTAcceptModelTypeDataRequestEnd,               // 数据请求结束
    BLTAcceptModelTypeDataTodaySportEnd,            // 今天运动数据请求结束
    
    BLTAcceptModelTypeDataTodayCalEnd,              // 今天卡路里数据请求结束
    BLTAcceptModelTypeDataTodayDistanceEnd,         // 今天距离数据请求结束
    
    BLTAcceptModelTypeDataTodaySleepEnd,            // 今天睡眠数据请求结束
    
    BLTAcceptModelTypeDataHistorySportEnd,          // 历史运动数据请求结束
    BLTAcceptModelTypeDataHistorySleepEnd,          // 历史睡眠数据请求结束.
    
    BLTAcceptModelTypeRestoreData,                  // 恢复数据
    
    BLTAcceptModelTypeSetLostModel,              // 丢失报警方式
    BLTAcceptModelTypeSetAlertModel,             // 寻找报警方式
    BLTAcceptModelTypeFindDevice,                // 寻找设备
    BLTAcceptModelTypeLostEvent,                 // 防丢事件
    BLTAcceptModelTypeKeyEvent,                  // 按键事件
    BLTAcceptModelTypeNoMuchElec,                // 没有足够的电量
    BLTAcceptModelTypeNoSupport,                 // 不支持
    BLTAcceptModelTypeSuccess,                   // 通讯成功
    BLTAcceptModelTypeError                      // 通讯错误
    
} BLTAcceptModelType;

typedef enum {
    BLTAcceptModelDataTypeUnKnown = 0,
    BLTAcceptModelDataTypeTodaySport = 1,
    BLTAcceptModelDataTypeTodaySleep = 2,
    BLTAcceptModelDataTypeHistorySport = 3,
    BLTAcceptModelDataTypeHistorySleep = 4,
} BLTAcceptModelDataType;

// 发送蓝牙指令后进行更新
typedef void(^BLTAcceptModelUpdateValue)(id object, BLTAcceptModelType type);

@protocol BLTAcceptModelDeleagte;

@interface BLTAcceptModel : NSObject

@property (nonatomic, assign) BLTAcceptModelType type;
@property (nonatomic, assign) BLTAcceptModelDataType dataType;

@property (nonatomic, strong) BLTAcceptModelUpdateValue updateValue;

///设备基本信息
@property (nonatomic, strong) BLTAcceptModelUpdateValue DeviceBasicInfo;

///实时记步
@property (nonatomic, strong) BLTAcceptModelUpdateValue RealStepInfo;
///实时心率
@property (nonatomic, strong) BLTAcceptModelUpdateValue RealHeartRateInfo;

@property (nonatomic, strong) BLTAcceptModelUpdateValue SaveRealHeartRateInfo;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, assign) NSInteger dataLength;

@property (nonatomic, assign) id <BLTAcceptModelDeleagte> delegate;
@property (nonatomic,assign) BOOL sleepEnd;

// 3.0 新的BLOCK回调
@property (nonatomic, strong) BLTAcceptModelUpdateValue saveStepInfo;   // 步数

@property (nonatomic, strong) BLTAcceptModelUpdateValue saveSleepInfo;  // 睡眠

@property (nonatomic, strong) BLTAcceptModelUpdateValue saveuserInfo;   // 用户信息

@property (nonatomic, strong) BLTAcceptModelUpdateValue saveOtherInfo;  // 其他设置

@property (nonatomic, strong) BLTAcceptModelUpdateValue saveUpateModel; // 更新数据

// 拍照
@property (nonatomic, strong) id <BLTControlTypeDelegate> BLTControlTDelegate;

@property (nonatomic, assign)NSInteger adjustSleep;

AS_SINGLETON(BLTAcceptModel)


@end



