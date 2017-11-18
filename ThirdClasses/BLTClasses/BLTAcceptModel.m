
//  BLTAcceptModel.m
//  PlaneCup
//
//  Created by zorro on 15/3/19.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import "BLTAcceptModel.h"
#import "ShareData.h"
#import "BLTSendModel.h"
#import "BLTSimpleSend.h"
#import "DateTools.h"
#import "ShareData.h"

@implementation BLTAcceptModel
{
    NSMutableArray *_stepArray;
    //步数数组
    NSMutableArray *_distanceArray;
    //距离数组
    NSMutableArray *_calArray;
    //卡路里数组
    NSMutableArray *_sleepArray;
    //数据库的睡眠数组
    NSMutableArray *_DataSleepArray;
    //睡眠字典
    NSMutableDictionary *_sleepDic;
    NSMutableArray *_sleepArray2;
    //数据库的睡眠数组
    NSMutableArray *_DataSleepArray2;
    //睡眠字典
    NSMutableDictionary *_sleepDic2;
    
    //心率数组
    NSMutableArray *heart_rateArray;
    //血压数组
    NSMutableArray *blood_pressureArray;
    //血氧数组
    NSMutableArray *blood_oxygenArray;
    //心率开关
    BOOL heart_rateSwith;
    
    int countV;
    
    NSString *dataString;
    NSString *dataStringsleep1;
    NSString *dataStringsleep2;
    
    NSInteger _distanceToal;
    NSInteger _calTotal;
    NSInteger _stepTotal;
    
    BOOL _saveBp;
    
}

DEF_SINGLETON(BLTAcceptModel)

- (instancetype)init
{
    self = [super init];
    if (self) {
        //        _lastSerial = -999;
        //        _shakeArray = [[NSMutableArray alloc] init];
        //        _syncData = [[NSMutableData alloc] init];
        //        _indexArray = [[NSMutableArray alloc] init];
        
        // 直接启动蓝牙
        [BLTManager sharedInstance];
        [BLTPeripheral sharedInstance].updateDataBlock = ^(NSData *data, BLTUpdateDataType type,CBPeripheral *Peripheral)
        {
            [self updateData:data type:type servicePeripheral:Peripheral];
        };
        
        _adjustSleep = 0;
        _saveBp = NO;
    }
    
    return self;
}

- (void)updateData:(NSData *)data type:(BLTUpdateDataType)type servicePeripheral:(CBPeripheral *)Peripheral
{
//    NSLog(@"Peripheral >>>>>>%@ uuid:%@",Peripheral.name ,Peripheral.identifier.UUIDString);
//
    if (type == BLTUpdateDataTypeNormalData)
    {
//        [KK_ShareData updateExlWithData:data Withtype:EXLReceive];
            [self updateData:data service:Peripheral];
    }
    else if (type == BLTUpdateDataTypeBigData)
    {
        //        [self updateBigData:data];
    }
    else if (type == BLTUpdateDataTypeTransFail)
    {
        // 待检测逻辑.
        // [self updateFailInfo];
    }
}

- (void)setType:(BLTAcceptModelType)type
{
    _type = type;
    
    // 5秒后没有回复信息表示通讯失败.
    if (_type == BLTAcceptModelTypeUnKnown) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkWhetherCommunicationError) object:nil];
        // [self performSelector:@selector(checkWhetherCommunicationError) withObject:nil afterDelay:5.0];
    }
}

- (void)updateData:(NSData *)data service:(CBPeripheral *)Peripheral
{
    _type = BLTAcceptModelTypeSuccess;
    UInt8 val[20] = {0};
    [data getBytes:&val length:data.length];
    
    NSLog(@"接收到的蓝牙数据 = %@", data);
    id object = nil;
   
     if (val[1] == 0x01)
    {
        if (val[2] == 0x01)
        {
//            //获取设备mac地址
//            NSString * mac = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x",val[3],val[4],val[5],val[6],val[7],val[8]];
//            KK_BLTModel.macAddress = mac;
//            [KK_BLTModel updateToDB];
//            NSLog(@"%@",mac);
        }
        if (val[2] == 0x02)
        {
//            // 固件端返回：0x05 + 0x01 + 0x02 + 设备id(2 bytes) + 固件版本号(1 byte) + 电池状态(1 byte-0x00为正常, 0x01正在充电,0x02充满, 0x03为低电量) ＋电池电量(1 byte).
//            // 获取设备基本信息
//            KK_BLTModel.deviceID = val[3] * 256 + val[4];       // 设备ID
//            KK_BLTModel.bltVersion = val[5];                    // 固件版本
//            KK_BLTModel.batteryQuantity = val[7];               // 电池电量
//            KK_BLTModel.CustomerID = val[8] * 256 + val[9];     // 0X01自家产品  0x02为祥云手环
//            [KK_BLTModel updateToDB];
//            // 当前设备固件版本
//            NSLog(@"当前设备固件版本 = %d deviceID>>>%d CustomerID>>>>%d", KK_BLTModel.bltVersion,KK_BLTModel.deviceID,KK_BLTModel.CustomerID);
//            
//            _type = BLTAcceptModelTypeDevideInfo;
//            
//            if (_DeviceBasicInfo)
//            {
//                _DeviceBasicInfo(nil, 0);
//            }
            
        }
    }
      if (val[1] == 0x07)
     {
         if (val[2] == 0x01)
         {
             if (data.length>3)
             {
             NSInteger step = val[3] * 256 * 256 * 256 + val[4] * 256 * 256 + val[5] * 256 + val[6];
                
             NSLog(@"Ble uuid>>>%@ step>>%d",Peripheral.identifier.UUIDString,step);
             BLTModel *model = [BLTModel getModelFromDBWtihUUID:Peripheral.identifier.UUIDString];
             model.stepTotal = step;
             [model updateToDB];
//                 [KK_ShareData.todaySport updateRealTimeData:data];
             }
             if (_RealStepInfo)
             {
                 _RealStepInfo(nil,0);
             }
         }
          if (val[2] == 0x03)
         {
             //记步大数据
             [SportModel updateSportData:data];
         }
         else if (val[2] == 0x04)
         {
             // 保存数据的逻辑写在model内部
             [SleepModel updateSleepData:data];
         }
         else if (val[2] == 0x05)
         {
             //距离大数据
             [SportModel updateSportData:data];
         }
         else if (val[2] == 0x06)
         {
             //卡路里大数据
             [SportModel updateSportData:data];
         }
         else if (val[2] == 0xFF)
         {

             // 运动数据传输完毕
             [SportModel sportTransEnd];
             
             _type = BLTAcceptModelTypeDataTodaySportEnd;
             
             if (_saveStepInfo)
             {
                 _saveStepInfo(nil,0);
             }
             
         } else if (val[2] == 0xFE) {
             _adjustSleep = 0;
             
             _sleepEnd = YES;
             
             [SleepModel sleepTransEnd];
             

             _type = BLTAcceptModelTypeDataTodaySleepEnd;
             
             if (_saveSleepInfo)
             {
                 _saveSleepInfo (nil,0);
             }
         }
     }
    
    
    if (_updateValue)
    {
        _updateValue(object, _type);
        _updateValue = nil;
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"bleacceptdata" object:data];
}


// 检查当次通讯是否发生错误
- (void)checkWhetherCommunicationError
{
    if (_type == BLTAcceptModelTypeUnKnown)
    {
        [self updateFailInfo];
    }
}

// 提示失败信息
- (void)updateFailInfo
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkWhetherCommunicationError) object:nil];
    
    NSLog(@" 提示失败信息");
    _type = BLTAcceptModelTypeError;
    if (_updateValue)
    {
        _updateValue(nil, _type);
        _updateValue = nil;
    }
}

@end

