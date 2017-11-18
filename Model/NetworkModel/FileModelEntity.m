//
//  FileModelEntity.m
//  MultiMedia
//
//  Created by zorro on 14-12-5.
//  Copyright (c) 2014年 zorro. All rights reserved.
//

#import "FileModelEntity.h"
#import "YYJSONHelper.h"
#import "DownloadEntity.h"

@implementation FileModelEntity

DEF_SINGLETON(FileModelEntity)

- (instancetype)init
{
    self = [super init];
    if (self)
    {

    }
    
    return self;
}

- (void)startUpdateFirmwareInfo
{
    [self fileModelRequestWithBaseLink:@"/apps/firmwares/firmware.json" withRequestType:FileModelEntityRequestFirmware];
}

- (void)fileModelRequestWithBaseLink:(NSString *)link withRequestType:(FileModelEntityRequest)requestType
{
    [self.requestHelper emptyCache];
    HttpRequest *hr = [self.requestHelper get:link];
    NSLog(@"hr = %@", hr);
    
    [hr succeed:^(MKNetworkOperation *op) {
        NSString *str = [op responseString];
        
         NSLog(@"[op responseString] = ..%@", str);
        
        
        
        if (str)
        {
            [self saveData:str withRequestType:requestType];
            
            [self requestSuccessWithString:str withRequestType:requestType];
        }
    } failed:^(MKNetworkOperation *op, NSError *err) {
        
        [self requestFailWithString:nil withRequestType:requestType];
    }];
    
    [self.requestHelper submit:hr];
    hr.shouldContinueWithInvalidCertificate = YES;
}

- (void)saveData:(NSString *)string withRequestType:(FileModelEntityRequest)requestType
{
    switch (requestType)
    {
        case FileModelEntityRequestFirmware:
        {
            _wareInfoArray = [string toModels:NSClassFromString(@"WareInfoModel") forKey:@"firmwareInfo"];
            
            [self configureFirmwareInfoModel];
            
            break;
        }
            
        default:
            break;
    }
}

// 为当前固件配置固件信息模型.
- (void)configureFirmwareInfoModel
{
    if (_wareInfoArray && _wareInfoArray.count > 0)
    {
        for (int i = 0; i < _wareInfoArray.count; i++)
        {
            WareInfoModel *model = _wareInfoArray[i];
            if (model.device_id.integerValue == [UserInfoHelper sharedInstance].bltModel.deviceID)
            {
                _wareInfo = model;
                
                break;
            }
        }
        
        if (_wareInfo)
        {
            [UserInfoHelper sharedInstance].bltModel.bltOnlineVersion = _wareInfo.version.integerValue;
        }
    }
}

- (void)requestSuccessWithString:(NSString *)string withRequestType:(FileModelEntityRequest)requestType
{
  
}

- (void)requestFailWithString:(NSString *)string withRequestType:(FileModelEntityRequest)requestType
{
    [self performSelector:@selector(startUpdateFirmwareInfo) withObject:nil afterDelay:120];
}

@end
