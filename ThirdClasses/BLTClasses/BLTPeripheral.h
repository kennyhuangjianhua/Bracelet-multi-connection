//
//  BLTPeripheral.h
//  ProductionTest
//
//  Created by zorro on 15-1-16.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef enum {
    BLTUpdateModelNormalState = 0,          // 更新状态
    BLTUpdateModelDidConnect = 1,           // 连接  // 连接与断开也要更新状态.
    BLTUpdateModelDisConnect = 2,           // 断开
    BLTUpdateModelRSSI = 3,                 // 更新RSSI

} BLTUpdateModelType;

typedef enum {
    BLTUpdateDataTypeNormalData = 0,        // 普通数据
    BLTUpdateDataTypeBigData = 1,           // 大数据
    BLTUpdateDataTypeTransFail = 2          // 信息传输失败.
    
} BLTUpdateDataType;

// 传入的model为空时为全部刷新.传入具体的model时为单个刷新.

typedef void(^BLTUpdateModel)(BLTModel *model, BLTUpdateModelType type);
typedef CBPeripheral *(^BLTPeripheralPeripheral)();
// 数据更新.
typedef void(^BLTPeripheralUpdateData)(NSData *data, BLTUpdateDataType type,CBPeripheral *Peripheral);

@interface BLTPeripheral : NSObject <CBPeripheralDelegate>

@property (nonatomic, strong) BLTPeripheralUpdateData updateDataBlock;
@property (nonatomic, strong) BLTUpdateModel updateModelBlock;

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, assign) UInt8 *lastInfo;

AS_SINGLETON(BLTPeripheral)

- (void)errorMessage;
- (void)updateRSSI:(BOOL)isStart;

- (void)updateRSSI;

// 只连接一个设备时发数据.
- (void)senderDataToPeripheral:(NSData *)data;
// 多设备时指定外围设备发数据.
- (void)senderDataToPeripheral:(NSData *)data withPeripheral:(CBPeripheral *)peripheral;

@end
