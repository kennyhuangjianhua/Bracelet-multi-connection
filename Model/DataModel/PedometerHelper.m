//
//  PedometerHelper.m
//  LoveSports
//
//  Created by zorro on 15/2/14.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import "PedometerHelper.h"
#import "DateTools.h"
#import "WeekModel.h"
#import "MonthModel.h"
#import "YearModel.h"
#import "DaysStepModel.h"

@implementation PedometerHelper

DEF_SINGLETON(PedometerHelper)

// 根据日期取出模型。
+ (PedometerModel *)getModelFromDBWithDate:(NSDate *)date
{
    NSString *dateString = [date dateToString];
    NSString *where = [NSString stringWithFormat:@"dateString = '%@' and wareUUID = '%@'",
                       [dateString componentsSeparatedByString:@" "][0], [AJ_LastWareUUID getObjectValue]];
    PedometerModel *model = [PedometerModel searchSingleWithWhere:where orderBy:nil];
    
    if (!model)
    {
        // 没有就进行完全创建.
        model = [PedometerHelper pedometerSaveEmptyModelToDBWithDate:date isSaveAllDay:NO];
    }
    
    return model;
}

// 取出今天的数据模型
+ (PedometerModel *)getModelFromDBWithToday
{
    PedometerModel *model = [PedometerHelper getModelFromDBWithDate:[NSDate date]];
    
    if (model)
    {
        return model;
    }
    else
    {
        model = [[PedometerModel alloc] init];
        
        return model;
    }
}

// 取出趋势图所需要的每天的模型.
+ (NSArray *)getEveryDayTrendDataWithDate:(NSDate *)date
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 7; i++)
    {
        NSDate *curDate = [date dateAfterDay:i];
        PedometerModel *model = [PedometerHelper getModelFromDBWithDate:curDate];
        if (model)
        {
            [array addObject:model];
        }
        else
        {
            [array addObject:[PedometerModel simpleInitWithDate:curDate]];
        }
    }
    
    return array;
}

+ (BOOL)queryWhetherCurrentDateDataSaveAllDay:(NSDate *)date
{
    NSString *dateString = [date dateToString];
    NSString *where = [NSString stringWithFormat:@"dateString = '%@' and wareUUID = '%@'",
                       [dateString componentsSeparatedByString:@" "][0], [AJ_LastWareUUID getObjectValue]];
    PedometerModel *model = [PedometerModel searchSingleWithWhere:where orderBy:nil];
    
    if (model && model.isSaveAllDay)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

// 为模型创建空值的对象
+ (void)creatEmptyDataArrayWithModel:(PedometerModel *)model
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 48; i++)
    {
        [array addObject:@(0)];
    }
   
    array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 288; i++)
    {
        // 4代表不是睡眠.而是运动
        [array addObject:@(4)];
    }
    
    /*
    // 测试
    for (int k = 100 + arc4random() % 30; k < 204 + arc4random() % 20; k++)
    {
        [array replaceObjectAtIndex:k withObject:@(arc4random() % 20 % 4)];
    }
     */
}

// 保存空模型到数据库.
+ (PedometerModel *)pedometerSaveEmptyModelToDBWithDate:(NSDate *)date isSaveAllDay:(BOOL)save
{
    PedometerModel *model = [PedometerModel simpleInitWithDate:date];
    
    [model addTargetForModelFromUserInfo];
    [PedometerHelper creatEmptyDataArrayWithModel:model];

    if (![date compareWithDate:[NSDate date]] &&
        [date timeIntervalSince1970] < [[NSDate date] timeIntervalSince1970])
    {
        // NSLog(@"model.isSaveAllDay = ..%@", date);
        if (save)
        {
            model.isSaveAllDay = YES;
        }
    }
    
    [model saveToDB];
    
    return model;
}

+ (void)updateTrendTableWithModel:(PedometerModel *)model
{
    NSDate *date = [NSDate dateByString:model.dateString];
    
    // 保存到周的模型.
    WeekModel *weekModel = [WeekModel getWeekModelFromDBWithDate:date isContinue:NO];
    [weekModel updateTotalWithModel:model];
    [weekModel updateToDB];
    
    //取到这一月的模型，没有就创建，更新至年模型中
    MonthModel *monthModel = [MonthModel getMonthModelFromModelWithYear:date.year withMonth:date.month];
    [monthModel updateTotalWithModel:model];
    [monthModel updateToDB];
    
    //取到这一年的模型，没有就创建，更新至年模型中
    YearModel *yearModel = [YearModel getYearModelFromDBWithYearIndex:date.year isContinue:NO];
    [yearModel updateTotalWithModel:model];
    [yearModel updateToDB];
    
    // 更新的每天的步数和睡眠到DaysStepModel
    [DaysStepModel updateDaysStepWithModel:model];
}

@end











