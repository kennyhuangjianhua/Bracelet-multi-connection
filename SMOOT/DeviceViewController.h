//
//  DeviceViewController.h
//  project
//
//  Created by 黄建华 on 2017/11/4.
//  Copyright © 2017年 黄建华. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceViewController : UIViewController  <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic, strong) UITableView *tabelView;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) NSString *searchString;
@end
