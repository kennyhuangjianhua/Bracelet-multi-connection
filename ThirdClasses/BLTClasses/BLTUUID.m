//
//  BLTUUID.m
//  ProductionTest
//
//  Created by zorro on 15-1-16.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import "BLTUUID.h"
#import "BLTManager.h"

@implementation BLTUUID

#pragma mark --- 设备所包含的所有UUID ---
// 服务
+ (CBUUID *)uartServiceUUID
{
    return [CBUUID UUIDWithString:@"8F400001-CFB4-14A3-F1BA-F61F35CDDBAF"];
}

//服务的结合 X9 I6 目前
+ (NSArray *)uartServiceUUIDS
{
    return @[[CBUUID UUIDWithString:@"8F400001-CFB4-14A3-F1BA-F61F35CDDBAF"],[CBUUID UUIDWithString:@"0xfff0"]];
}

//服务的结合 X9 I6 目前 (包含升级服务)
+ (NSArray *)uartServiceUUIDAndUpdateService
{
    return @[[CBUUID UUIDWithString:@"8F400001-CFB4-14A3-F1BA-F61F35CDDBAF"],[CBUUID UUIDWithString:@"0xfff0"],[CBUUID UUIDWithString:@"00001530-1212-EFDE-1523-785FEABCD123"]];
}

// 写 特征
+ (CBUUID *)txCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"8f400002-cfb4-14a3-f1ba-f61f35cddbaf"];
}

// 读 特征
+ (CBUUID *)rxCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"8f400003-cfb4-14a3-f1ba-f61f35cddbaf"];
}

// 大数据写
+ (CBUUID *)bigDataWriteCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"00000af1-0000-1000-8000-00805f9b34fb"];
}

// 大数据读
+ (CBUUID *)bigDataReadCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"00000af2-0000-1000-8000-00805f9b34fb"];
}

// 硬件绑定的特征
+ (CBUUID *)hardwareRevisionStringUUID
{
    return [CBUUID UUIDWithString:@"2A27"];
}

// 设备信息服务
+ (CBUUID *)deviceInformationServiceUUID
{
    return [CBUUID UUIDWithString:@"180A"];
}

// 升级服务UUID : 00001530-1212-EFDE-1523-785FEABCD123

// 升级时的服务
+ (CBUUID *)updateServiceUUID
{
    return [CBUUID UUIDWithString:@"00001530-1212-EFDE-1523-785FEABCD123"];
}

// 控制中心.
+ (CBUUID *)controlPointCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"00001531-1212-EFDE-1523-785FEABCD123"];
}

// 数据传输特征
+ (CBUUID *)packetCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"00001532-1212-EFDE-1523-785FEABCD123"];
}

// 固件版本特征
+ (CBUUID *)versionCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"00001534-1212-EFDE-1523-785FEABCD123"];
}

+ (NSString *)representativeString:(CBUUID *)uuid
{
    NSData *data = [uuid data];
    NSUInteger bytesToConvert = [data length];
    const unsigned char *uuidBytes = [data bytes];
    NSMutableString *outputString = [NSMutableString stringWithCapacity:16];
    
    for (NSUInteger currentByteIndex = 0; currentByteIndex < bytesToConvert; currentByteIndex++)
    {
        switch (currentByteIndex)
        {
            case 3:
            case 5:
            case 7:
            case 9:[outputString appendFormat:@"%02x-", uuidBytes[currentByteIndex]];
                
                break;
                
            default:[outputString appendFormat:@"%02x", uuidBytes[currentByteIndex]];
        }
        
    }
    
    return outputString;
}


@end

