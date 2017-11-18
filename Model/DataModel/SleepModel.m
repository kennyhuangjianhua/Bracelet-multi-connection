//
//  SleepModel.m
//  GetFit3.0
//
//  Created by zorro on 2017/7/22.
//  Copyright © 2017年 lxc. All rights reserved.
//

#import "SleepModel.h"
#import "ShareData.h"

@implementation SleepSubModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _user_id = KK_User.user_id;
        _date = [[NSDate date] dateToDayString];
        _duration = 0;
        _deep = 0;
        _light = 0;
        _sober = 0;
    }
    return self;
}

- (void)cleanData
{
    _duration = 0;
    _deep = 0;
    _light = 0;
    _sober = 0;
}

- (NSArray *)sleepData
{
    return _sleepData ? _sleepData : @[];
}

// 表名
+ (NSString *)getTableName
{
    return @"SleepSubModel";
}

// 复合主键
+ (NSArray *)getPrimaryKeyUnionArray
{
    return @[@"user_id", @"date", @"endTime"];
}

// 表版本
+ (int)getTableVersion
{
    return 1;
}

+ (void)initialize
{
    [super initialize];
}

@end

@implementation SleepModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _subArray = [NSMutableArray array];
        
        _user_id = KK_User.user_id;
        _date = [[NSDate date] dateToDayString];
    }
    return self;
}

+ (SleepModel *)initWithDate:(NSDate *)date
{
    SleepModel *model = [[SleepModel alloc] init];
    model.date = [date dateToDayString];
    
    return model;
}

- (void)cleanData
{
    _duration = 0;
    _deep = 0;
    _light = 0;
    _sober = 0;
}

+ (void)updateSleepData:(NSData *)data
{
    UInt8 val[20] = {0};
    [data getBytes:&val length:data.length];
    
    BOOL isBagHead = !(val[3] % 4);
    
    if (val[3] == 0)
    {
        KK_ShareData.todaySleep.subArray = [NSMutableArray array];
        KK_ShareData.yesSleep.subArray = [NSMutableArray array];
    }
    
    if (isBagHead)
    {
        NSString *startTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:00", val[4] + 2000,
                               val[5], val[6], val[7], val[8]];
        NSString *endTime = [NSString stringWithFormat:@"%04d-%02d-%02d %02d:%02d:00", val[9] + 2000,
                             val[10], val[11], val[12], val[13]];
        KK_ShareData.subSleep = [[SleepSubModel alloc] init];
        KK_ShareData.subSleep.date = [endTime componentsSeparatedByString:@" "][0];
        KK_ShareData.subSleep.startTime = startTime;
        KK_ShareData.subSleep.endTime = endTime;
        [KK_ShareData.sleepDetailArr removeAllObjects];
        
        if ([KK_ShareData.subSleep.date isEqualToString:KK_ShareData.todaySleep.date])
        {
            [KK_ShareData.todaySleep.subArray addObject:KK_ShareData.subSleep];
        } else if ([KK_ShareData.subSleep.date isEqualToString:KK_ShareData.yesSleep.date])
        {
            [KK_ShareData.yesSleep.subArray addObject:KK_ShareData.subSleep];
        }
    }
    else
    {
        for (int i = 4; i < 19; i += 2)
        {
            NSInteger number = val[i] * 256 + val[i + 1];
            NSInteger sleepStatus = (UInt8)(number >> 14);
            NSInteger sleepTime = (UInt16)number & 0x3FFF;
            if (sleepStatus == 0) {
                KK_ShareData.subSleep.light += sleepTime;
            } else if (sleepStatus == 1) {
                KK_ShareData.subSleep.deep += sleepTime;
            } else if (sleepStatus == 2) {
                KK_ShareData.subSleep.sober += sleepTime;
            }
            KK_ShareData.subSleep.duration += sleepTime;
            [KK_ShareData.sleepDetailArr addObject:StrByInt(number)];
            KK_ShareData.subSleep.sleepData = [NSArray arrayWithArray:KK_ShareData.sleepDetailArr];
        }
    }
}

// 睡眠运动结束
+ (void)sleepTransEnd
{
    // 存储到数据库
    [KK_ShareData.todaySleep updateToDB];
    [KK_ShareData.yesSleep updateToDB];

    [KK_ShareData.todaySleep cleanData];
    for (int i = 0; i < KK_ShareData.todaySleep.subArray.count; i++) {
        SleepSubModel *model = KK_ShareData.todaySleep.subArray[i];
        KK_ShareData.todaySleep.duration += model.duration;
        KK_ShareData.todaySleep.deep += model.deep;
        KK_ShareData.todaySleep.light += model.light;
        KK_ShareData.todaySleep.sober += model.sober;
    }
    
    [KK_ShareData.yesSleep cleanData];
    for (int i = 0; i < KK_ShareData.yesSleep.subArray.count; i++) {
        SleepSubModel *model = KK_ShareData.yesSleep.subArray[i];
        KK_ShareData.yesSleep.duration += model.duration;
        KK_ShareData.yesSleep.deep += model.deep;
        KK_ShareData.yesSleep.light += model.light;
        KK_ShareData.yesSleep.sober += model.sober;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sleepDataEnd" object:nil];
}

+ (SleepModel *)getSleepModelFromDBWith:(NSDate *)date
{
    NSString *where = [NSString stringWithFormat:@"user_id = '%@' and date = '%@'",
                       KK_User.user_id, [date dateToDayString]];
    SleepModel *model = [SleepModel searchSingleWithWhere:where orderBy:nil];
    if (!model) {
        model = [SleepModel initWithDate:date];
        [model saveToDB];
    }
    
    return model;
}

+ (SleepModel *)getSleepModelFromDB
{
    NSString *where = [NSString stringWithFormat:@"user_id = '%@' and date = '%@'",
                       KK_User.user_id, [[NSDate date] dateToDayString]];
    SleepModel *model = [SleepModel searchSingleWithWhere:where orderBy:nil];
    if (!model) {
        model = [[SleepModel alloc] init];
        [model saveToDB];
    }
    
    return model;
}

- (void)updateToDBSafely
{
    NSString *where = [NSString stringWithFormat:@"user_id = '%@' and date = '%@'",
                       KK_User.user_id, self.date];
    SleepModel *model = [SleepModel searchSingleWithWhere:where orderBy:nil];
    if (!model) {
        [self saveToDB];
    } else {
        [SleepModel updateToDB:self where:nil];
    }
}


// 表名
+ (NSString *)getTableName
{
    return @"SleepModel";
}

// 复合主键
+ (NSArray *)getPrimaryKeyUnionArray
{
    return @[@"user_id", @"date"];
}

// 表版本
+ (int)getTableVersion
{
    return 1;
}

@end
