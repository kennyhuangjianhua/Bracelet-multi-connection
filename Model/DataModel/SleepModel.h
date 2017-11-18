//
//  SleepModel.h
//  GetFit3.0
//
//  Created by zorro on 2017/7/22.
//  Copyright © 2017年 lxc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SleepSubModel : NSObject

@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *mac;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;
@property (nonatomic, assign) NSInteger deep;
@property (nonatomic, assign) NSInteger light;
@property (nonatomic, assign) NSInteger sober;
@property (nonatomic, assign) NSInteger duration;

@property (nonatomic, strong) NSArray *sleepData;
@property (nonatomic, strong) NSString *sleepDataStr;

- (void)cleanData;

@end

@interface SleepModel : NSObject

@property (nonatomic, strong) NSString *user_id;
@property (nonatomic, strong) NSString *mac;
@property (nonatomic, strong) NSString *date;

@property (nonatomic, assign) NSInteger sleepTarget;
@property (nonatomic, assign) NSInteger deep;
@property (nonatomic, assign) NSInteger light;
@property (nonatomic, assign) NSInteger sober;
@property (nonatomic, assign) NSInteger duration;

@property (nonatomic, strong) NSString *month;
@property (nonatomic, strong) NSString *data;
@property (nonatomic, strong) NSMutableArray *subArray;

// 周和月的时候的数组
@property (nonatomic, strong) NSArray *durationArr;   // 总睡眠时间
@property (nonatomic, strong) NSArray *deepArr;
@property (nonatomic, strong) NSArray *lightArr;
@property (nonatomic, strong) NSArray *soberArr;
@property (nonatomic, strong) NSArray *monthArr;
@property (nonatomic, strong) NSArray *dateArr;

+ (SleepModel *)initWithDate:(NSDate *)date;
+ (SleepModel *)getSleepModelFromDBWith:(NSDate *)date;
- (void)updateToDBSafely;

+ (SleepSubModel *)getSubModelWithEndTime:(NSString *)startTime;
+ (void)updateSleepData:(NSData *)data;
+ (SleepModel *)getSleepModelFromDB; // 获取今天的本地睡眠
// 睡眠传输结束
+ (void)sleepTransEnd;
- (void)cleanData;

//  从服务器获取数据
// 天的返回sleep对象 周月年返回的sleep数组


+ (void)testSleepData;

@end
