//
//  DownloadEntity.m
//  AJBracelet
//
//  Created by zorro on 15/7/22.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import "DownloadEntity.h"
#import "XYSandbox.h"
#import "FileModelEntity.h"
#import "BLTManager.h"

@implementation DownloadEntity

DEF_SINGLETON(DownloadEntity)

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.downloadEngine = [DownloadHelper defaultSettings];
        
        self.downloadEngine.freezable = NO;
        self.downloadEngine.forceReload = NO;
        
        self.pathArray = @[@"", [[XYSandbox libCachePath] stringByAppendingPathComponent:AJ_FileCache_Firmware]];
        
        [BLTDFUHelper sharedInstance].updateBlock = ^ (BLTDFUHelperUpdateState state, NSInteger number) {
            [self requestFailWithDFUState:state withProgress:number withRequestType:DownloadEntityRequestUnknow];
        };
    }
    
    return self;
}

- (void)downloadFileWithWebsite:(NSString *)website withRequestType:(DownloadEntityRequest)requestType
{
    if (website && website.length > 6)
    {
        SHOWMBProgressHUDIndeterminate(@"下载升级程序", nil, NO);
        [self removeLastUpdateWarePatchFile];
        [self.downloadEngine cancelDownloadWithString:website];

        NSString *fileName = [[website componentsSeparatedByString:@"/"] lastObject];
        _filePath = [NSString stringWithFormat:@"%@/%@", self.pathArray[requestType], fileName];
        Downloader *down = [self.downloadEngine downLoad:website to:_filePath params:nil breakpointResume:NO];
        
        NSLog(@"....down = %@", down);
        [down succeed:^(MKNetworkOperation *op) {
            // [self unzipWithZipPath:filePath withRequest:requestType];
            
            HIDDENMBProgressHUD;
            NSLog(@"下载bin成功...");
            if (requestType == DownloadEntityRequestFirmware)
            {
                [FileModelEntity sharedInstance].wareInfo.isDownload = YES;
                
                [AJ_LastWareVersion setIntValue:[FileModelEntity sharedInstance].wareInfo.version.intValue];
                [[BLTManager sharedInstance] checkIsAllownUpdateFirmWare];
            }
            
        } failed:^(MKNetworkOperation *op, NSError *err) {
            HIDDENMBProgressHUD;
            
            [self requestFailWithDFUState:BLTDFUHelperUpdateFail withProgress:0 withRequestType:requestType];
        }];
        
        [self.downloadEngine submit:down];
    }
}

// 开始下载升级文件.
- (void)startDownloadUpdateFileWithUpdateBlcok:(BLTDFUHelperUpdate)block
{
    _updateWareInfoBlock = block;

    [[FileModelEntity sharedInstance] configureFirmwareInfoModel];
    
    if ([FileModelEntity sharedInstance].wareInfo)
    {
        // 在线版本是否高于现在的版本.
        if ([BLTManager sharedInstance].model.bltOnlineVersion > [BLTManager sharedInstance].model.bltVersion)
        {
            // 是否已经下载并进行了文件缓存.
            if ([FileModelEntity sharedInstance].wareInfo.isDownload)
            {
                NSString *fileName = [[[FileModelEntity sharedInstance].wareInfo.file componentsSeparatedByString:@"/"] lastObject];
                _filePath = [NSString stringWithFormat:@"%@/%@", self.pathArray[DownloadEntityRequestFirmware], fileName];
                
                [[BLTManager sharedInstance] checkIsAllownUpdateFirmWare];
            }
            else
            {
                // 没有下载就开始下载.
                [[DownloadEntity sharedInstance] downloadFileWithWebsite:[FileModelEntity sharedInstance].wareInfo.file
                                                         withRequestType:DownloadEntityRequestFirmware];
            }
        }
        else
        {
            SHOWMBProgressHUD(@"已经是最新版本", nil, nil, NO, 2.0);
        }
    }
    else
    {
        SHOWMBProgressHUD(@"服务器维护中", nil, nil, NO, 2.0);
    }
}

- (void)requestFailWithDFUState:(BLTDFUHelperUpdateState)state withProgress:(NSInteger)number withRequestType:(DownloadEntityRequest)requestType
{
    // 通知界面进行进度更新
    if (_updateWareInfoBlock)
    {
        _updateWareInfoBlock(state, number);
    }
}

@end
