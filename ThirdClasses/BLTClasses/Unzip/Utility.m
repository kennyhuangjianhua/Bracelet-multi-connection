/*
 * Copyright (c) 2015, Nordic Semiconductor
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
 * USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "Utility.h"
#import "UnzipFirmware.h"
#import "DownloadEntity.h"

@implementation Utility

int  PACKETS_NOTIFICATION_INTERVAL = 10;
int const PACKET_SIZE = 20;

//14781423393840
+ (NSArray *)getUpdateFirmWarePath
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"14781423393840.zip" ofType:nil];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:filePath];
    
    
    
    return [Utility unzipFiles:url];
}

/*
+ (NSArray *)getUpdateFirmWarePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //在这里获取应用程序Documents文件夹里的文件及文件夹列表
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    NSError *error = nil;
    NSArray *fileList = [[NSArray alloc] init];
    //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
    fileList = [fileManager contentsOfDirectoryAtPath:documentDir error:&error];
    
//    for (NSString *file in fileList)
//    {
//        [_FileSaveArray addObject:file];
//    }
    
        NSString *strValue = @"";

        for (NSString *str in fileList)
        {
            NSRange search = [str rangeOfString:@"zip"];
            
            if (search.location != NSNotFound)
            {
                strValue = str;
                break;
            }
        }

    NSString *path = [documentPaths[0] stringByAppendingPathComponent:strValue];
    NSLog(@"本地升级文件 path >>>>%@",path);
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    
    return [Utility unzipFiles:url];
    
}
 */


- (void)localUpdateFirmware
{
    
}


+ (BOOL)isFileExtension:(NSString *)fileName fileExtension:(enumFileExtension)fileExtension
{
    if ([[fileName pathExtension] isEqualToString:[Utility stringFileExtension:fileExtension]]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSArray *)unzipFiles:(NSURL *)zipFileURL
{
    UnzipFirmware *unzipFiles = [[UnzipFirmware alloc]init];
    NSArray *firmwareFilesURL = [unzipFiles unzipFirmwareFiles:zipFileURL];
    // if manifest file exist inside then parse it and retrieve the files from the given path
    
    NSURL *applicationURL = nil;
    NSURL *applicationMetaDataURL = nil;
    
    for (NSURL *firmwareURL in firmwareFilesURL) {
        if ([[[firmwareURL path] lastPathComponent] isEqualToString:@"test.bin"]) {
            applicationURL = firmwareURL;
            NSLog(@".applicationURL = .%@", applicationURL);

        } else if ([[[firmwareURL path] lastPathComponent] isEqualToString:@"test.dat"]) {
            applicationMetaDataURL = firmwareURL;
            NSLog(@"applicationMetaDataURL = ..%@", applicationMetaDataURL);
        }
    }
    
    return @[applicationURL, applicationMetaDataURL];
}

+ (NSString *)stringFileExtension:(enumFileExtension)fileExtension
{
    switch (fileExtension)
    {
        case HEX:
            return @"hex";
        case BIN:
            return @"bin";
        case ZIP:
            return @"zip";
            
        default:
            return nil;
    }
}

+ (void)showAlert:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"DFU" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

+ (void)showBackgroundNotification:(NSString *)message
{
    UILocalNotification *notification = [[UILocalNotification alloc]init];
    notification.alertAction = @"Show";
    notification.alertBody = message;
    notification.hasAction = NO;
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    notification.timeZone = [NSTimeZone  defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] setScheduledLocalNotifications:[NSArray arrayWithObject:notification]];
}

+ (BOOL)isApplicationStateInactiveORBackground
{
    UIApplicationState applicationState = [[UIApplication sharedApplication] applicationState];
    if (applicationState == UIApplicationStateInactive || applicationState == UIApplicationStateBackground)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

@end
