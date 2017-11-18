//
//  FileModelEntity.h
//  MultiMedia
//
//  Created by zorro on 14-12-5.
//  Copyright (c) 2014年 zorro. All rights reserved.
//

#define FileModelEntity_UpgradePatchURL @"http://lovesports.qiniudn.com/update_PC.bin"
#define FileModelEntity_UpgradePatchFolder @"upgrade"
#define FileModelEntity_UpgradePatchBin @"upgrade.bin"

#import "BaseModelEntity.h"
#import "Header.h"
#import "WareInfoModel.h"

typedef enum {
    FileModelEntityRequestFirmware = 0
} FileModelEntityRequest;

@interface FileModelEntity : BaseModelEntity

@property (nonatomic, strong) DownloadHelper *downloadEngine;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) WareInfoModel *wareInfo;
@property (nonatomic, strong) NSArray *wareInfoArray;

AS_SINGLETON(FileModelEntity)

// 开始更新固件信息.
- (void)startUpdateFirmwareInfo;

// 为当前固件配置固件信息模型.
- (void)configureFirmwareInfoModel;

@end
