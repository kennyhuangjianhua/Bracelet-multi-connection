 //
//  SportModel.m
//  GetFit3.0
//
//  Created by zorro on 2017/7/21.
//  Copyright © 2017年 lxc. All rights reserved.
//

#import "SportModel.h"
#import "YYJSONHelper.h"
#import "ShareData.h"

// http://apidoc.sty028.com/#api-sportsleep-uploadGfUserSport
// PHP http://119.23.8.182:8081/doc/
// http://119.23.8.182:8082/appversion/index

@implementation SportModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _user_id = KK_User.userName;
        _date = [[NSDate date] dateToDayString];
        _duration = @"0";
        _step = 0;
        _distance = 0;
        _calory = 0;
        NSMutableArray *stepArr = [NSMutableArray array];
        NSMutableArray *distanceArr = [NSMutableArray array];
        NSMutableArray *calArr = [NSMutableArray array];
        for (int i = 0; i < 48; i++) {
            [stepArr addObject:StrByInt(0)];
            [distanceArr addObject:StrByInt(0)];
            [calArr addObject:StrByInt(0)];
        }
        _stepArr = [NSArray arrayWithArray:stepArr];
        _distanceArr = [NSArray arrayWithArray:distanceArr];
        _calArr = [NSArray arrayWithArray:calArr];
    }
    
    return self;
}

+ (SportModel *)initWithDate:(NSDate *)date
{
    SportModel *model = [[SportModel alloc] init];
    model.date = [date dateToDayString];
    
    return model;
}

// 实时数据
- (void)updateRealTimeData:(NSData *)data
{
    UInt8 val[20] = {0};
    [data getBytes:&val length:data.length];
   
    NSInteger tmpStep = 0;
    NSInteger tmpDistance = 0;
    NSInteger tmpCalory = 0;
    NSString *tmpDuration = @"";

       tmpStep = val[3] * 256 * 256 * 256 + val[4] * 256 * 256 + val[5] * 256 + val[6];
       tmpDistance = val[7] * 256 * 256 * 256 + val[8] * 256 * 256 + val[9] * 256 + val[10];
       tmpCalory = val[11] * 256 * 256 * 256 + val[12] * 256 * 256 + val[13] * 256 + val[14];
       tmpDuration = [NSString stringWithFormat:@"%d",val[15] * 256 + val[16]];
    
    if (_stepArr.count == 48 && _distanceArr.count == 48 && _calArr.count == 48) {
        NSDate *date = [NSDate date];
        NSInteger order = (date.hour * 60 + date.minute) / 30;
        NSMutableArray *stepsArray = [NSMutableArray arrayWithArray:_stepArr];
        NSInteger orderStep = [stepsArray[order] integerValue];
        
        if (tmpStep > _step)
        {
            orderStep += tmpStep - _step;
            stepsArray[order] =  StrByInt(orderStep);
            _stepArr = [NSArray arrayWithArray:stepsArray];
                NSMutableArray *distanceArray = [NSMutableArray arrayWithArray:_distanceArr];
                NSInteger orderDistance = [distanceArray[order] integerValue];
                NSInteger historyDis = 0;
                NSInteger historyCal = 0;
                for (int i = 0; i<order; i++) {
                    historyDis += [distanceArray[i] integerValue];
                }
                //orderDistance += tmpDistance - _distance;
                orderDistance = tmpDistance-historyDis;
                distanceArray[order] = StrByInt(orderDistance);
                _distanceArr = [NSArray arrayWithArray:distanceArray];
                
                NSMutableArray *calArray = [NSMutableArray arrayWithArray:_calArr];
                NSInteger orderCal = [calArray[order] integerValue];
                for (int i = 0; i<order; i++) {
                    historyCal += [calArray[i] integerValue];
                }
                //orderCal += tmpCalory - _calory;
                orderCal = tmpCalory - historyCal;
                calArray[order] = StrByInt(orderCal);
                _calArr = [NSArray arrayWithArray:calArray];

        }
    }
    
    _step = tmpStep;
    _distance = tmpDistance;
    _calory = tmpCalory;
    _duration = tmpDuration;
}

+ (void)updateSportData:(NSData *)sportData
{
    UInt8 val[20] = {0};
    [sportData getBytes:&val length:sportData.length];
    
    // 开始
    if (val[3] == 0 || val[3] == 6) {
        [KK_ShareData.sportDetailArr removeAllObjects];
        KK_ShareData.sportTotal = 0;
    }
    
    for (int i = 4; i < 19; i += 2) {
        NSInteger number = val[i] * 256 + val[i + 1];
        NSLog(@"步数>>>>>>%d",number);
        [KK_ShareData.sportDetailArr addObject:StrByInt(number)];
        KK_ShareData.sportTotal += number;
    }
    
    // 结束 封装数据
    SportModel *model;
    if (val[3] == 5) {
        model = KK_ShareData.todaySport;
        [model updateSportDataWithType:val[2]];
        [model updateToDBSafely];
    } else if (val[3] == 11) {
        model = KK_ShareData.yesSport;
        [model updateSportDataWithType:val[2]];
        [model updateToDBSafely];
    }
}

- (void)updateSportDataWithType:(NSInteger)type
{
    if (type == 3) {            // 计步
        _step =  KK_ShareData.sportTotal;
        _stepArr = [NSArray arrayWithArray:KK_ShareData.sportDetailArr];
    } else if (type == 5) {     // 距离
        _distance = KK_ShareData.sportTotal;
        _distanceArr = [NSArray arrayWithArray:KK_ShareData.sportDetailArr];
    } else if (type == 6) {     // 卡路里
        _calory = KK_ShareData.sportTotal;
        _calArr = [NSArray arrayWithArray:KK_ShareData.sportDetailArr];
    }
}

// 传输完毕 上传数据
+ (void)sportTransEnd
{
    NSLog(@"model step >>>%@",KK_ShareData.todaySport.stepArr);
    
    NSMutableString *sss = [NSMutableString string];
    [sss appendString:@"今天:"];
    for(NSString *string in KK_ShareData.todaySport.stepArr)
    {
        [sss appendString:string];
        [sss appendString:@"-"];
    }
    [sss appendString:@"\n"];

    [sss appendString:@"昨天:"];
    for(NSString *string in KK_ShareData.yesSport.stepArr)
    {
        [sss appendString:string];
        [sss appendString:@"-"];
    }
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"步数详情" message:sss delegate:self cancelButtonTitle:nil otherButtonTitles:@"关闭", nil];
    [alert show];
}

+ (SportModel *)getSportModelFromDBWith:(NSDate *)date
{
    NSString *where = [NSString stringWithFormat:@"user_id = '%@' and date = '%@'",
                       KK_User.user_id, [date dateToDayString]];
    SportModel *model = [SportModel searchSingleWithWhere:where orderBy:nil];
    if (!model) {
        model = [SportModel initWithDate:date];
        model.date = [date dateToDayString];
        [model saveToDB];
    }
    
    return model;
}

+ (SportModel *)getSportModelFromDB
{
    NSString *where = [NSString stringWithFormat:@"user_id = '%@' and date = '%@'",
                       KK_User.user_id, [[NSDate date] dateToDayString]];
    SportModel *model = [SportModel searchSingleWithWhere:where orderBy:nil];
    if (!model) {
        model = [[SportModel alloc] init];
        [model saveToDB];
    }
    
    return model;
}

- (void)updateToDBSafely
{
    NSString *where = [NSString stringWithFormat:@"user_id = '%@' and date = '%@'",
                       KK_User.user_id, self.date];
    SportModel *model = [SportModel searchSingleWithWhere:where orderBy:nil];
    if (!model) {
        [self saveToDB];
    } else {
        [SportModel updateToDB:self where:nil];
    }
}

+ (SportModel *)editModels:(NSArray *)models date:(NSDate *)date count:(NSInteger)count
{
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        SportModel *model = [SportModel initWithDate:[date dateAfterDay:i]];
        [array addObject:model];
    }
    
    for (int i = 0; i < models.count; i++) {
        SportModel *model = models[i];
        NSDate *tmpDate = [NSDate dateByString:model.date];
        NSInteger index = ABS([tmpDate dateByDistanceDaysWithDate:date]);
        // NSLog(@"%d, %@, %@", index, tmpDate, date);
        [array replaceObjectAtIndex:index withObject:model];
    }
    
    SportModel *result = [[SportModel alloc] init];
    NSMutableArray *stepArr = [NSMutableArray array];
    NSMutableArray *distanceArr = [NSMutableArray array];
    NSMutableArray *calArr = [NSMutableArray array];
    NSMutableArray *dateArr = [NSMutableArray array];
    for (int i = 0; i < array.count; i++) {
        SportModel *model = array[i];
        [stepArr addObject:StrByInt(model.step)];
        [distanceArr addObject:StrByInt(model.distance)];
        [calArr addObject:StrByInt(model.calory)];
        [dateArr addObject:model.date];
        result.step += model.step;
        result.distance += model.distance;
        result.calory += model.calory;
    }
    result.stepArr = [NSArray arrayWithArray:stepArr];
    result.distanceArr = [NSArray arrayWithArray:distanceArr];
    result.calArr = [NSArray arrayWithArray:calArr];
    result.dateArr = [NSArray arrayWithArray:dateArr];

    return result;
}

+ (SportModel *)parseDataWithYear:(NSString *)data date:(NSDate *)date
{
    NSArray *models = [data toModels:[SportModel class] forKey:@"data"];
    NSMutableArray *array = [NSMutableArray array];
    NSInteger year = date.year;
    for (int i = 0; i < 12; i++) {
        SportModel *model = [[SportModel alloc] init];
    
        model.month = [NSString stringWithFormat:@"%04d-%02d", year, i+1];
        
        [array addObject:model];
    }
    
    for (int i = 0; i < models.count; i++) {
        SportModel *model = models[i];
        for (int j = 0; j < array.count; j++) {
            SportModel *tmpModel = array[j];
            if ([model.month isEqualToString:tmpModel.month]) {
                [array replaceObjectAtIndex:j withObject:model];
                break;
            }
        }
    }
    
    SportModel *result = [[SportModel alloc] init];
    NSMutableArray *stepArr = [NSMutableArray array];
    NSMutableArray *distanceArr = [NSMutableArray array];
    NSMutableArray *calArr = [NSMutableArray array];
    NSMutableArray *monthArr = [NSMutableArray array];
    for (int i = 0; i < array.count; i++) {
        SportModel *model = array[i];
        [stepArr addObject:StrByInt(model.step)];
        [distanceArr addObject:StrByInt(model.distance)];
        [calArr addObject:StrByInt(model.calory)];
        [monthArr addObject:model.month];
        result.step += model.step;
        result.distance += model.distance;
        result.calory += model.calory;
    }
    result.stepArr = [NSArray arrayWithArray:stepArr];
    result.distanceArr = [NSArray arrayWithArray:distanceArr];
    result.calArr = [NSArray arrayWithArray:calArr];
    result.monthArr = [NSArray arrayWithArray:monthArr];

    return result;
}

// 表名
+ (NSString *)getTableName
{
    return @"SportModel";
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

+ (void)initialize
{
    [super initialize];
}

@end
