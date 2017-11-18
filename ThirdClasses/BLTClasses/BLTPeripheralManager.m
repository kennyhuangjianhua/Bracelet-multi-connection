//
//  BLTPeripheralManager.m
//  AJBracelet
//
//  Created by zorro on 15/10/12.
//  Copyright © 2015年 zorro. All rights reserved.
//

#import "BLTPeripheralManager.h"
#import "BLTUUID.h"

@interface BLTPeripheralManager () <CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBPeripheralManager *peripheraManager;
@property (nonatomic, strong) CBMutableCharacteristic *customerCharacteristic;
@property (nonatomic, strong) CBMutableService *customerService;
@end

@implementation BLTPeripheralManager

DEF_SINGLETON(BLTPeripheralManager)

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        if (![AJ_LastWareUUID getObjectValue])
        {
            [AJ_LastWareUUID setObjectValue:AJ_DeviceName];
        }
        
        [self setUp];
    }
    
    return self;
}

- (void)setUp
{
    _peripheraManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    _customerService = [[CBMutableService alloc] initWithType:BLTUUID.uartServiceUUID
                                                      primary:YES];
    CBMutableCharacteristic *char1 = [[CBMutableCharacteristic alloc] initWithType:BLTUUID.txCharacteristicUUID
                                                                        properties:CBCharacteristicPropertyWrite
                                                                             value:nil
                                                                       permissions:CBAttributePermissionsWriteable];
    CBMutableCharacteristic *char2 = [[CBMutableCharacteristic alloc] initWithType:BLTUUID.rxCharacteristicUUID
                                                                        properties:CBCharacteristicPropertyNotify
                                                                             value:nil
                                                                       permissions:CBAttributePermissionsReadable];
    
    _customerService.characteristics = @[char1, char2];
    
    [_peripheraManager addService:_customerService];
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state != CBPeripheralManagerStatePoweredOn)
    {
        return;
    }
    
    [_peripheraManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : BLTUUID.uartServiceUUID,
                                          CBAdvertisementDataLocalNameKey : @"test"}];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral
                  central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic");
    
    [self sendData:@"2"];
    
}

// 注销
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
}

- (void)sendData:(NSString *)text
{
    [_peripheraManager updateValue:[text dataUsingEncoding:NSUTF8StringEncoding]
                 forCharacteristic:(CBMutableCharacteristic *)_customerService.characteristics[1] onSubscribedCentrals:nil];
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // Start sending again
    [self sendData:@"1"];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    NSLog(@"..%@", request.value);
}

@end
