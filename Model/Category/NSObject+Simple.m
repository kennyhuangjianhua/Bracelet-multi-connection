//
//  NSObject+Simple.m
//  AJBracelet
//
//  Created by zorro on 15/5/27.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import "NSObject+Simple.h"
#import <objc/runtime.h>

@implementation NSObject (Simple)

@dynamic attributeList;

- (NSArray *)attributeList
{
    NSUInteger propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], (unsigned int *)&propertyCount);
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSUInteger i = 0; i < propertyCount; i++)
    {
        const char *name = property_getName(properties[i]);
        NSString *propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        
        // const char *attr = property_getAttributes(properties[i]);
        // NSLogD(@"%@, %s", propertyName, attr);
        [array addObject:propertyName];
    }
    
    free( properties );
    return array;
}

+ (BOOL)isHasAMPMTimeSystem
{
    // 获取系统是24小时制或者12小时制
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = (containsA.location != NSNotFound);
    
    // hasAMPM == TURE为12小时制，否则为24小时制
    
    return hasAMPM;
}

+ (UIViewController *)topMostController
{
    //Getting rootViewController
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    //Getting topMost ViewController
    while (topController.presentedViewController)
    {
        topController = topController.presentedViewController;
    }
    
    //Returning topMost ViewController
    return topController;
}

- (void)delayPerformBlock:(NSObjectSimpleBlock)block WithTime:(CGFloat)time
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // code to be executed on the main queue after delay
        
        if (block)
        {
            block(nil);
        }
        
    });
}

// 对完整的文件路径进行判断,isDirectory 如果是文件夹返回YES, 如果不是返回NO.
- (BOOL)completePathDetermineIsThere:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL existed = [fileManager fileExistsAtPath:path];
    
    return existed;
}

- (BOOL)testTimeIsOver:(NSString *)dateString
{
    NSDate *date = [NSDate dateByStringFormat:dateString];
    NSInteger dateTime = [[NSDate date] dateByDistanceDaysWithDate:date];
    
    if (dateTime <= 0)
    {
        // SHOWMBProgressHUD(@"测试时间已经结束", @"如有疑问请联系开发者", nil, NO, 3600 * 24);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"测试时间已经结束" message:@"如有疑问请联系供应商" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alert show];
        
        return NO;
    }
    else
    {
        return YES;
    }
}

@end
