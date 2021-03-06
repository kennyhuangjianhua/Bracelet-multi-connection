//
//  WareInfoModel.m
//  AJBracelet
//
//  Created by zorro on 15/7/22.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import "WareInfoModel.h"
#import "DownloadEntity.h"

@implementation WareInfoModel

- (BOOL)isDownload
{
    NSString *fileName = [[_file componentsSeparatedByString:@"/"] lastObject];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [DownloadEntity sharedInstance].pathArray[DownloadEntityRequestFirmware], fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL existed = [fileManager fileExistsAtPath:filePath];
    
    return existed;
}

@end
