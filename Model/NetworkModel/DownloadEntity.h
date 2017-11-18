//
//  DownloadEntity.h
//  AJBracelet
//
//  Created by zorro on 15/7/22.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import "BaseModelEntity.h"
#import "BLTDFUHelper.h"

typedef enum {
    DownloadEntityRequestUnknow = 0,
    DownloadEntityRequestFirmware = 1
} DownloadEntityRequest;

@interface DownloadEntity : BaseModelEntity

@property (nonatomic, strong) DownloadHelper *downloadEngine;
@property (nonatomic, strong) NSArray *pathArray;
@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, strong) BLTDFUHelperUpdate updateWareInfoBlock;

AS_SINGLETON(DownloadEntity)

// 开始下载升级文件.
- (void)startDownloadUpdateFileWithUpdateBlcok:(BLTDFUHelperUpdate)block;
- (void)downloadFileWithWebsite:(NSString *)website withRequestType:(DownloadEntityRequest)requestType;

@end
