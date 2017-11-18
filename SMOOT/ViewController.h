//
//  ViewController.h
//  project
//
//  Created by 黄建华 on 2017/9/23.
//  Copyright © 2017年 黄建华. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SportModel.h"
#import "SleepModel.h"
//#import "LLFMDBVc1.h"
//#import "EWMViewController.h"
//#import "BrightnessViewController.h"
//#import "SpeakChangeStringViewController.h"
@interface ViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>

@property (nonatomic, strong) UITableView *tabelView;
@property (nonatomic, strong) NSArray *listArray;
@property (nonatomic, strong) NSArray *testFunctionArray;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UITextView *writeView;
@property (nonatomic, strong) UITextView *acceptView;
@property (nonatomic, strong) NSString *writeString;
@property (nonatomic, strong) NSMutableString *readString;
@property (nonatomic, assign) BOOL isWriteCommand;

@end

