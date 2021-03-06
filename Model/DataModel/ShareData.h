//
//  ShareData.h
//  MultiMedia
//
//  Created by zorro on 15/3/13.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#define KK_PadDevice ([ShareData sharedInstance].isPad)
#define KK_IpFourDevice ([ShareData sharedInstance].isIp4s)
#define KK_IpFiveDevice ([ShareData sharedInstance].isIp5)
#define KK_IpSixDevice ([ShareData sharedInstance].isIp6)
#define KK_IpSixPDevice ([ShareData sharedInstance].isIp6P)

#define BL_CountScale (10000)
#define KK_ShareData ([ShareData sharedInstance])
typedef enum {
    ShareDataImageSourceDisConnect = 0,             // 未连接
    ShareDataImageSourceDidConnect = 1,             // 非未连接
    ShareDataImageSourceAdd,                        // 添加
} ShareDataImageType;

typedef enum {
    BackgroundModeUnknown,
    BackgroundModeBLT,
    BackgroundModeMusic,
    BackgroundModeMusicAndMotion,
} BackgroundMode;

#import <Foundation/Foundation.h>
#import "SportModel.h"
#import "SleepModel.h"

@interface ShareData : NSObject

@property (nonatomic, assign) BOOL isPad;
@property (nonatomic, assign) BOOL isIp4s;
@property (nonatomic, assign) BOOL isIp5;
@property (nonatomic, assign) BOOL isIp6;
@property (nonatomic, assign) BOOL isIp6P;

@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *recordPath;

@property (nonatomic, assign) BOOL isDisturb; // 是否打扰. YES为打扰...
@property (nonatomic, assign) BOOL isBackGround;
@property (nonatomic, assign) BOOL isDeviceList;

@property (nonatomic, strong) NSMutableArray *postionArray;
@property (nonatomic, strong) NSMutableArray *loseArray;

@property (nonatomic, assign) BOOL isAuthor;

// 数据库是否允许用户信息开始保存.
@property (nonatomic, assign) BOOL isAllowUserInfoSave;
// 数据库是否允许手环开始保存.
@property (nonatomic, assign) BOOL isAllowBLTSave;

// 当前拍照设置
@property (nonatomic, assign) NSInteger sheetNumber;
@property (nonatomic, assign) NSInteger intervalTime;

// 模式
@property (nonatomic, assign) NSInteger mode;

@property (nonatomic, assign) BackgroundMode backgroundMode;

- (void)checkDeviceModel;

+ (BOOL)isPad;
+ (BOOL)isIpFour;
+ (BOOL)isIpFive;
+ (BOOL)isIpSix;
+ (BOOL)isIpSixP;

AS_SINGLETON(ShareData)

- (NSString *)getCurrentRecordFilePath:(NSString *)name;

// 对完整的文件路径进行判断,isDirectory 如果是文件夹返回YES, 如果不是返回NO.
- (BOOL)completePathDetermineIsThere:(NSString *)path;

// 删除文件夹和文件都可以用这个方法
- (void)removeFileName:(NSString *)file withFolderPath:(NSString *)path;
- (UIImage *)getImageFromFileCache:(NSString *)imageName;
- (UIImage *)getImageFromFileCache:(NSString *)imageName withType:(ShareDataImageType)type;

- (UIImage *)imageScale:(UIImage *)image
               withSize:(CGSize)size
              withScale:(CGFloat)scale;


// 获取铃声的时间长度。
- (NSInteger)getTimeOfBellWithMp3String:(NSString *)mp3String;

// 今日与昨天的运动参数
@property (nonatomic, strong) SportModel *todaySport;
@property (nonatomic, strong) SportModel *yesSport;
@property (nonatomic, strong) NSMutableArray *sportDetailArr;
@property (nonatomic, assign) NSInteger sportTotal;

// 睡眠参数
@property (nonatomic, strong) SleepModel *todaySleep;               // 睡眠模型 蓝牙获取的所有数据
@property (nonatomic, strong) SleepModel *yesSleep;                 // 睡眠模型 蓝牙获取的所有数据
@property (nonatomic, strong) SleepSubModel *subSleep;              // 一次的睡眠数据
@property (nonatomic, assign) NSInteger sleepOrderIndex;            // 睡眠序号
@property (nonatomic, strong) NSMutableArray *sleepDetailArr;       // 睡眠详情


@end
