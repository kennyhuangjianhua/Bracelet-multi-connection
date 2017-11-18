

//
//  BLTService.m
//  ProductionTest
//
//  Created by zorro on 15-1-16.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#define AJ_DeviceName @"X9"
#define AJ_LastWareUUID @"AJ_LastWareUUID"

#import "BLTManager.h"
#import "BLTPeripheral.h"
#import "BLTUUID.h"
#import "AppDelegate.h"
#import "BLTSendModel.h"
#import "ShareData.h"
#import "FileModelEntity.h"

@interface BLTManager () <CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) CBPeripheral *discoverPeripheral;
@property (nonatomic, assign) NSInteger RSSI;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSString *alarmTimer;

@end

@implementation BLTManager

DEF_SINGLETON(BLTManager)

- (instancetype)init
{
    self = [super init];
    if (self)
    {
//        if (![AJ_LastWareUUID getObjectValue])
//        {
//            [AJ_LastWareUUID setObjectValue:AJ_DeviceName];
//        }
        [AJ_LastWareUUID setObjectValue:@""];
        
        _isAutoUpdate = NO;
        _DeviceType = [[NSArray alloc]init];
    
        _allWareArray = [[NSMutableArray alloc] initWithCapacity:0];
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
        [BLTPeripheral sharedInstance].updateModelBlock = ^(BLTModel *model, BLTUpdateModelType type) {
            [self updateModel:model type:type];
        };
    }
    
    return self;
}

// 更新各种蓝牙的情况.
- (void)updateModel:(BLTModel *)model type:(BLTUpdateModelType)type
{
    if (_updateModelBlock)
    {
        _updateModelBlock(model, type);
    }
}

- (BOOL)isConnected
{
    return _model.isConnected;
}

#pragma mark --- 通知界面的更新 ---

#pragma mark --- 操作移动设备的蓝牙链接 ---
- (void)startCan
{
    NSLog(@"完全的开始重新扫描...");
    [self scan];
}


- (void)newScan
{
    _isUpdateing = NO;
    
    NSLog(@"完全的开始重新扫描...");
    [self scan];
    
}

#pragma mark --- CBCentralManagerDelegate ---
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn)
    {
        return;
    }
    
    [self scan];
}

- (void)scan
{
//    if ([ShareData sharedInstance].backgroundMode != x f)
//    {
//        // return;
//    }
//    
    if (_centralManager.state != CBCentralManagerStatePoweredOn)
    {
        /*
         // 提示用户打开蓝牙.
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
         message:nil
         delegate:nil
         cancelButtonTitle:nil
         otherButtonTitles:@"OK", nil];
         [alert show];
         
         return;
         */
    }
    
    // 先停止扫描然后继续扫描. 避免因为多线程操作设备数组导致崩溃.
    [_centralManager stopScan];
    
    // SHOWMBProgressHUD(BL_Text(@"Searching"), nil, nil, NO, 2.0);
    
    [_allWareArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BLTModel *model = obj;
        switch (model.peripheral.state)
        {
            case CBPeripheralStateConnected:
                [_centralManager cancelPeripheralConnection:model.peripheral];
                break;
                
            default:
            {
                [_allWareArray removeObject:model];
            }
                break;
        }
    }];
    
    // [self updateViewsFromModel];
    /*
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                        forKey:CBCentralManagerScanOptionAllowDuplicatesKey]; */
//    [self.centralManager scanForPeripheralsWithServices:nil//@[BLTUUID.uartServiceUUID]
//                                                options:nil];
     [self.centralManager scanForPeripheralsWithServices:BLTUUID.uartServiceUUIDAndUpdateService options:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopScan) object:nil];
    [self performSelector:@selector(stopScan) withObject:nil afterDelay:10.0];
}

- (void)stopScan
{
    [self.centralManager stopScan];
}

- (void)initType:(NSArray*)type
{
    _DeviceType = type;
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"找到蓝牙设备了..%@..%@..%@", advertisementData, [peripheral.identifier UUIDString], peripheral.name);
    
    NSString *deviceName1 = peripheral.name;
    NSString *deviceName2 = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
    
    if (peripheral.name.length <= 0)
    {
        return;
    }
    
    // NSRange range = [[deviceName lowercaseString] rangeOfString:[proName lowercaseString]];
    if (![deviceName1 isEqualToString:AJ_DeviceName] &&
        ![deviceName2 isEqualToString:AJ_DeviceName]) {
        // 目前设备种类很多. 不唯一, 用服务过滤
        //         return;
    }
    
    NSString *idString = [peripheral.identifier UUIDString];
    
    if (!_isUpdateing)
    {
        NSString *mac=[NSString stringWithFormat:@"%@",[advertisementData objectForKey:@"kCBAdvDataManufacturerData"]];
        if (mac.length > 0)
        {
            //          NSLog(@"name>>>%@ mac>>>>%d mac>>>%@",peripheral.name,mac.length,mac);
            
        }
        // mac地址 >>>><00006064 05a415d4>
        // 先在设备列表数组里面查找有没有.
        BLTModel *model = extracted(self, idString);
        if (!model)
        {
            model = [BLTModel getModelFromDBWtihUUID:idString];
            [_allWareArray addObject:model];
        }
        
        BOOL macString = NO;
        if ([peripheral.name isEqualToString:DEVICEX9] || [peripheral.name isEqualToString:DEVICEIONE] || [peripheral.name isEqualToString:DEVICEX1OPRO])
        {
            if (mac.length == 19 || mac.length == 33 ||mac.length == 16)
            {
                macString = YES;
            }
            else
            {
                macString = NO;
            }
        }
        
        NSString *bltMacAddress = @"查询中...";
        if (macString)
        {
            NSString * macAddress = [mac substringWithRange:NSMakeRange(5, 13)];
            
            NSString *s1 = [macAddress substringWithRange:NSMakeRange(0, 2)];
            NSString *s2 = [macAddress substringWithRange:NSMakeRange(2, 2)];
            NSString *s3 = [macAddress substringWithRange:NSMakeRange(5, 2)];
            NSString *s4 = [macAddress substringWithRange:NSMakeRange(7, 2)];
            NSString *s5 = [macAddress substringWithRange:NSMakeRange(9, 2)];
            NSString *s6 = [macAddress substringWithRange:NSMakeRange(11, 2)];
            bltMacAddress = [NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",s1,s2,s3,s4,s5,s6];
            model.macAddress = bltMacAddress;
            model.bltName = deviceName1 ? deviceName1 : (deviceName2 ? deviceName2 : @"");
            model.bltRSSI = [NSString stringWithFormat:@"%d", ABS(RSSI.intValue)];
            model.peripheral = peripheral;
            [model updateToDB];
        }
      
    }
    else
    {

    }

    [self updateModel:nil type:BLTUpdateModelNormalState];
}

static BLTModel * extracted(BLTManager *object, NSString *idString) {
    return [object checkIsAddInAllWareWithID:idString];
}

- (void)connectPeripheralWithModel:(BLTModel *)model
{
    if (!model.isConnected)
    {
      [_centralManager connectPeripheral:model.peripheral options:nil];
      [self updateModel:model type:BLTUpdateModelNormalState];
    }
}

- (BLTModel *)checkIsAddInAllWareWithID:(NSString *)idString
{
    for (BLTModel *model in _allWareArray)
    {
        if ([model.bltUUID isEqualToString:idString])
        {
            return model;
        }
    }
    
    return nil;
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [BLTPeripheral sharedInstance].peripheral = peripheral;
    
    BLTModel *model = [self checkIsAddInAllWareWithID:peripheral.identifier.UUIDString];
    if (![_allWareArray containsObject:model])
    {
         [_allWareArray addObject:_model];
    }

     _sendModel = [[BLTSendModel alloc] init];
    
    [self updateModel:model type:BLTUpdateModelNormalState];
    
    [peripheral discoverServices:@[BLTUUID.uartServiceUUID]];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBleDeviceState" object:nil];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    BLTModel *model = [self checkIsAddInAllWareWithID:peripheral.identifier.UUIDString];
    [self updateModel:model type:BLTUpdateModelDisConnect];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"失去链接");
    
//    [_centralManager connectPeripheral:peripheral options:nil];

    BLTModel *model = [BLTModel getModelFromDBWtihUUID:peripheral.identifier.UUIDString];
    [self updateModel:model type:BLTUpdateModelDisConnect];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBleDeviceState" object:nil];
}

/***********************    下面关于很多防丢的功能暂时用不到    ****************************/

// 从连接的设备组里面移除掉某个设备.
- (void)removeModelWithPeripheral:(CBPeripheral *)peripheral withArray:(NSMutableArray *)array
{
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        BLTModel *model = obj;
        if (model.peripheral == peripheral)
        {
            [array removeObject:model];
            *stop = YES;
        }
    }];
}

// 在所有准备连接的数组中 根据设备寻找模型.
- (BLTModel *)findModelWithPeripheral:(CBPeripheral *)peripheral
{
    for (BLTModel *model in _allWareArray)
    {
        if (model.peripheral == peripheral)
        {
            return model;
        }
    }
    
    return nil;
}

- (void)disConnectPeripheralWithModel:(BLTModel *)model
{
    [_centralManager cancelPeripheralConnection:model.peripheral];
}

- (void)dismissLinkAndRepeatConnect
{
    if (_discoverPeripheral)
    {
        [self dismissLinkAndRepeatConnect:_discoverPeripheral];
    }
}

// 主动断开重连接
- (void)dismissLinkAndRepeatConnect:(CBPeripheral *)peripheral
{
    if (peripheral)
    {
        BLTModel *model = [self findModelWithPeripheral:peripheral];
        
        if (model)
        {
            // 非主动断开会重连.
            model.isInitiative = NO;
            model.isRepeatConnect = YES;
        }
        
        [_centralManager cancelPeripheralConnection:peripheral];
    }
}

- (void)initiativeDismissCurrentModel:(BLTModel *)model
{
    NSLog(@"主动断开设备.");
    model.isInitiative = YES;
    [_centralManager cancelPeripheralConnection:model.peripheral];
}

// 主动断开设备.
- (void)initiativeDismiss
{
    NSLog(@"主动断开设备.");
    
    if (_model && _model.peripheral)
    {
        _model.isInitiative = YES;
        [_centralManager cancelPeripheralConnection:_model.peripheral];
    }
}

// 主动断开, 去除显示在当前的设备
- (void)deleteModelFromAllWaresWith:(BLTModel *)model
{
    model.isInitiative = YES;
    [self disConnectPeripheralWithModel:model];
}

// 重置外围设备.
- (void)resetDiscoverPeripheral
{
    if (_discoverPeripheral)
    {
        _discoverPeripheral.delegate = nil;
        [_centralManager cancelPeripheralConnection:_discoverPeripheral];
        _discoverPeripheral = nil;
    }
    
    _model = nil;
}

- (void)dismissLink
{
    [self resetDiscoverPeripheral];
}

/**
 *  准备固件更新.
 */
- (void)checkIsAllownUpdateFirmWare
{
    if (self.discoverPeripheral.state == CBPeripheralStateConnected)
    {
        if ([UserInfoHelper sharedInstance].bltModel.batteryQuantity == 2)
        {
            SHOWMBProgressHUD(@"设备没有足够的电量.", nil, nil, NO, 2);
        }
        else
        {
            [self startUpdateFirmWare];
        }
    }
    else
    {
        SHOWMBProgressHUD(@"设备没有链接.", nil, nil, NO, 2.0);
    }
}

// 品艺升级
- (void)startDFUForPinyi
{

      _isUpdateing = YES;
    _updateModel = _model;
//        [BLTSendModel sendUpdateFirmwareWithUpdateBlock:^(id object, BLTAcceptModelType type) {
//        }];

   
    // [[BLTDFUHelper sharedInstance] gotoUpdateState];
    [BLTManager sharedInstance].model.isUpdateing = YES;

    
    [BLTDFUHelper sharedInstance].endBlock = ^(BOOL success) {
        [self firmWareUpdateEnd:success];
    };
}

// 开始对设备进行空中升级.
- (void)startUpdateFirmWare
{
//    _isUpdateing = YES;
//    _updateModel = _model;
//    [BLTSendModel sendUpdateFirmwareWithUpdateBlock:^(id object, BLTAcceptModelType type) {
//        if (type == BLTAcceptModelTypeNoMuchElec) {
//        } else if (type == BLTAcceptModelTypeNoSupport) {
//        } else {
//           
//        }
//    }];
//
//    [BLTDFUHelper sharedInstance].endBlock = ^(BOOL success) {
//        [self firmWareUpdateEnd:success];
//    };
}

// 升级结束 可能失败 可能成功.
- (void)firmWareUpdateEnd:(BOOL)success
{
    _isUpdateing = NO;
    _updateModel = nil;
    _model = nil;
    
    if (success)
    {
        SHOWMBProgressHUD(@"固件更新成功.", nil, nil, NO, 3.0);
    }
    else
    {
        SHOWMBProgressHUD(@"升级失败.", nil, nil, NO, 3.0);
    }
}

@end
