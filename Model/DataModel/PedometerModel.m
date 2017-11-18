//
//  PedometerModel.m
//  AJBracelet
//
//  Created by zorro on 15/7/13.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import "PedometerModel.h"
#import "PedometerHelper.h"
#import "UserInfoHelper.h"
#import "BLTAcceptModel.h"

@implementation StateModel

@end

@implementation PedometerModel

// 简单初始化并赋值。
+ (PedometerModel *)simpleInitWithDate:(NSDate *)date
{
    PedometerModel *model = [[PedometerModel alloc] init];
    
    model.wareUUID = [AJ_LastWareUUID getObjectValue];
    model.dateString = [[date dateToString] componentsSeparatedByString:@" "][0];
    
    return model;
}

// 读取运动数据包 前面2个包的数据
- (void)saveSportInfoToModel:(UInt8 *)val
{
    self.timeOffset       = val[8] | (val[9] << 8);
    self.perMinutes       = val[10];
    self.sportItemCounts  = val[11];
    self.sportTotalBytes  = val[12];
    
    self.totalSteps       = val[24] | (val[25] << 8) | (val[26] << 16) | (val[27] << 24);
    self.totalCalories    = val[28] | (val[29] << 8) | (val[30] << 16) | (val[31] << 24);
    self.totalDistance    = val[32] | (val[33] << 8) | (val[34] << 16) | (val[35] << 24);
    self.totalSportTime   = val[36] | (val[37] << 8) | (val[38] << 16) | (val[39] << 24);

    NSLog(@"....%d..%d..%d..%d", self.totalSteps, self.totalCalories, self.totalDistance, self.totalSportTime);
}

// 读取睡眠数据包 前面2个包的数据
- (void)saveSleepInfoToModel:(UInt8 *)val
{
    self.sleepEndTime       = val[8] * 60 + val[9];
    self.sleepTotalTime     = val[10] | (val[11] << 8);
    
    if (self.sleepTotalTime > 24 * 60)
    {
        self.sleepTotalTime = 24 * 60;
    }
    
    self.sleepStartTime = self.sleepEndTime - self.sleepTotalTime;
    if (self.sleepStartTime < 0)
    {
        self.sleepStartTime = 24 * 60 + self.sleepStartTime;
    }
    
    self.sleepItemCounts    = val[12];
    self.sleepTotalBytes    = val[13];
    
    self.shallowSleepCounts = val[24];
    self.deepSleepCounts    = val[25];
    self.wakingCounts       = val[26];
    
    self.shallowSleepTime   = val[27] | (val[28] << 8);
    self.deepSleepTime      = val[29] | (val[30] << 8);
    
    NSLog(@"....%d..%d..%d..%d", self.sleepEndTime, self.sleepTotalTime, self.sleepItemCounts, self.sleepTotalBytes);
}

// 解析并保存数据。
+ (void)saveDataToModel:(NSArray *)array
                withEnd:(PedometerModelSyncEnd)endBlock
{
    NSData *data = array[0];
    UInt8 val[20 * 7 * 36] = {0};
    [data getBytes:&val length:data.length];

    // 取模型     // 从第一个包
    NSString *dateString = [NSString stringWithFormat:@"%04d-%02d-%02d", (val[4]) | (val[5] << 8), val[6], val[7]];
    NSDate *tmpDate = [NSDate dateByString:dateString];
    PedometerModel *totalModel = [PedometerHelper getModelFromDBWithDate:tmpDate];
    
    NSLog(@"当前数据的日期 = ..%@", dateString);

    totalModel.dateString = dateString;
    
    // 错误处理.
    if (!tmpDate || [tmpDate timeIntervalSince1970] < 0
        || ([tmpDate timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970]) > 3600 * 24)
    {
        NSLog(@"..日期有问题？ %@", tmpDate);
        // SHOWMBProgressHUD(@"数据出现问题.", nil, nil, NO, 2.0);
        if (endBlock)
        {
            endBlock([NSDate date], YES);
        }
        
        return;
    }
    
    NSDate *firstDate = [SAVEFIRSTUSERDATE getObjectValue];
    if ([firstDate timeIntervalSince1970] > [tmpDate timeIntervalSince1970])
    {
        if (tmpDate.year > 13)
        {
            [SAVEFIRSTUSERDATE setObjectValue:tmpDate];
        }
    }
    
    NSData *originalData = array[0];
    NSMutableData *detailData = [[NSMutableData alloc] init];
    // 此处需要判断收到得字节与存储得字节长度。看看是否发生丢包。
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    BLTAcceptModelType type = (BLTAcceptModelType)[array[1] integerValue];
    if (type == BLTAcceptModelTypeDataTodaySport ||
        type == BLTAcceptModelTypeDataHistorySport)
    {
        [totalModel saveSportInfoToModel:val];
        
        // 将每个数据包的第一个byte清除.
        for (int i = 40; i < originalData.length; i++)
        {
            if (!(i % 20 == 0)  &&
                !(i % 20 == 1)  &&
                !(i % 20 == 2)  &&
                !(i % 20 == 3)  &&
                !(i % 20 == 19))
            {
                [detailData appendBytes:&val[i] length:1];
            }
        }
        
        [detailData getBytes:&val length:detailData.length];
        
        /*
        totalModel.totalSteps = 0;
        totalModel.totalCalories = 0;
        totalModel.totalDistance = 0;
         */
        
        for (int i = 0; i < totalModel.sportItemCounts && i < 100; i++)
        {
            StateModel *model = [[StateModel alloc] init];
            
            model.currentOrder  = i + 1;
            model.sportState    = ((UInt8)(val[i * 5 + 0] << 6) >> 6);
            model.steps         = (val[i * 5 + 0] >> 2) | (((UInt8)(val[i * 5 + 1] << 2) >> 2) << 6);
            model.activeTime    = (val[i * 5 + 1] >> 6) | ((UInt8)(val[i * 5 + 2] << 6) >> 6);
            model.calories      = (val[i * 5 + 2] >> 2) | (((UInt8)(val[i * 5 + 3] << 4) >> 4) << 6);
            model.distance      = (val[i * 5 + 3] >> 4) | (val[i * 5 + 4] << 4);
            
            NSArray *modelData = @[@(model.currentOrder), @(model.sportState), @(model.steps),
                                   @(model.activeTime), @(model.calories), @(model.distance)];
            [items addObject:modelData];
            
            /*
            totalModel.totalSteps += model.steps;
            totalModel.totalCalories += model.calories;
            totalModel.totalDistance += model.distance;
             */
        }
        
        totalModel.sportsArray = items;
    }
    else if (type == BLTAcceptModelTypeDataTodaySleep ||
             type == BLTAcceptModelTypeDataHistorySleep)
    {
        [totalModel saveSleepInfoToModel:val];
        
        // 将每个数据包的第一个byte清除.
        for (int i = 40; i < originalData.length; i++)
        {
            if (!(i % 20 == 0)  &&
                !(i % 20 == 1)  &&
                !(i % 20 == 2)  &&
                !(i % 20 == 3))
            {
                [detailData appendBytes:&val[i] length:1];
            }
        }
        
        [detailData getBytes:&val length:detailData.length];
        
        for (int i = 0; i < totalModel.sleepItemCounts && i < 400; i++)
        {
            StateModel *model = [[StateModel alloc] init];
            
            model.currentOrder  = i + 1;
            model.sleepState    = (UInt8)val[i * 2 + 0];
            model.sleepDuration = val[i * 2 + 1];
            
            NSArray *modelData = @[@(model.currentOrder), @(model.sleepState), @(model.sleepDuration)];
            [items addObject:modelData];
            
            NSLog(@"当前序号: %d, 睡眠状态: %d, 睡眠持续时间: %d", model.currentOrder, model.sleepState, model.sleepDuration);
        }
        
        totalModel.sleepArray = items;
    }
    
    [PedometerModel saveModelToDB:totalModel withEndBlock:endBlock];
}

// 保存到数据库.
+ (void)saveModelToDB:(PedometerModel *)model withEndBlock:(PedometerModelSyncEnd)endBlock
{
    BOOL isToday = [[NSDate date] compareWithDate:[NSDate dateByString:model.dateString]];
    
    // 设置最新的目标
    [model addTargetForModelFromUserInfo];
    // 将数据保存到周－月－年表
    [model savePedometerModelToWeekModelAndMonthModel];
    
    // 这个暂时无用...
    if (isToday)
    {
        model.isSaveAllDay = NO;
    }
    else
    {
        model.isSaveAllDay = YES;
    }
    
    NSString *where = [NSString stringWithFormat:@"dateString = '%@' and wareUUID = '%@'",
                       model.dateString, model.wareUUID];
    PedometerModel *tmpModel = [PedometerModel searchSingleWithWhere:where orderBy:nil];
    
    if (tmpModel)
    {
        [PedometerModel updateToDB:model where:where];
    }
    else
    {
        [model saveToDB];
    }

    if (endBlock)
    {
        endBlock([NSDate dateByString:model.dateString], YES);
    }
}

// 从用户信息为模型添加各种目标.
- (void)addTargetForModelFromUserInfo
{
    _targetStep = [UserInfoHelper sharedInstance].userModel.targetSteps;
    _targetCalories = [UserInfoHelper sharedInstance].userModel.targetCalories;
    _targetDistance = [UserInfoHelper sharedInstance].userModel.targetDistance;
    _targetSleep = [UserInfoHelper sharedInstance].userModel.targetSleep;
}

// 详细运动步数显示.
- (NSArray *)showDetailSports
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < _sportsArray.count; i++)
    {
        NSArray *data = _sportsArray[i];
        
        [array addObject:data[2]];
    }
    
    // 补满方便显示
    for (int i = array.count; i < 96; i++)
    {
        [array addObject:@(0)];
    }
    
    return array;
}

// 详细睡眠显示.
- (NSArray *)showDetailSleep
{
    return _sleepArray;
}

/*
- (NSInteger)deepSleepTime
{
    NSInteger time = 0;
    for (int i = 0; i < _sleepArray.count; i++)
    {
        NSArray *data = _sleepArray[i];
        
        if ([data[1] integerValue] == 3)
        {
            time += [data[2] integerValue];
        }
    }
    
    return time;
}

- (NSInteger)shallowSleepTime
{
    NSInteger time = 0;
    for (int i = 0; i < _sleepArray.count; i++)
    {
        NSArray *data = _sleepArray[i];
        
        if ([data[1] integerValue] == 2)
        {
            time += [data[2] integerValue];
        }
    }
    
    return time;
}
 */

- (NSInteger)wakingTime
{
    NSInteger time = 0;
    for (int i = 0; i < _sleepArray.count; i++)
    {
        NSArray *data = _sleepArray[i];
        
        if ([data[1] integerValue] == 1)
        {
            time += [data[2] integerValue];
        }
    }
    
    return time;
}

- (NSArray *)showSleepTimeArray
{
    if (!_sleepArray || _sleepArray.count == 0)
    {
        return nil;
    }
    
    CGFloat average = _sleepTotalTime / 3.0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (int i = 3; i >= 0; i--)
    {
        NSInteger time = _sleepEndTime - (NSInteger)(i * average + 0.5);
        if (time < 0)
        {
            time = (24 * 60 + time);
        }
        
        NSString *timeString = [NSString stringWithFormat:@"%02d:%02d", time / 60, time % 60];
        
        [array addObject:timeString];
    }
    
    return array;
}

- (void)savePedometerModelToWeekModelAndMonthModel
{
    [PedometerHelper updateTrendTableWithModel:self];
}

// 表名
+ (NSString *)getTableName
{
    return @"PedometerTable";
}

// 复合主键
+ (NSArray *)getPrimaryKeyUnionArray
{
    return @[@"userName", @"dateString", @"wareUUID"];
}

// 表版本
+ (int)getTableVersion
{
    return 1;
}

+ (void)initialize
{
    //remove unwant property
    //比如 getTableMapping 返回nil 的时候   会取全部属性  这时候 就可以 用这个方法  移除掉 不要的属性
    
    [self removePropertyWithColumnName:@"showDetailSports"];
    [self removePropertyWithColumnName:@"showDetailSleep"];
    [self removePropertyWithColumnName:@"showSleepTime"];
}

@end
