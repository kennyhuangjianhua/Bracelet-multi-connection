//
//  ZKKViewController.m
//  VPhone
//
//  Created by zorro on 14-10-22.
//  Copyright (c) 2014年 zorro. All rights reserved.
//

#import "ZKKViewController.h"
#import "BLTAcceptModel.h"

@interface ZKKViewController ()

@end

@implementation ZKKViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self loadTabBarItem];
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.rightBarButtonItem = nil;
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)updateContentWithObject:(id)object withType:(BLTAcceptModelType)type
{

}

- (void)loadTabBarItem
{

}

- (void)loadItemButton
{
    UIButton *button = [UIButton simpleWithRect:CGRectMake(0, 0, 44, 44)
                                      withTitle:@"蓝牙"
                                withSelectTitle:@"蓝牙"
                            withBackgroundColor:[UIColor clearColor]];
    [button addTouchUpTarget:self action:@selector(clickBlueTooth)];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItem = item;
    
    button = [UIButton simpleWithRect:CGRectMake(0, 0, 44, 44)
                            withTitle:@"设置"
                      withSelectTitle:@"设置"
                  withBackgroundColor:[UIColor clearColor]];
    [button addTouchUpTarget:self action:@selector(clickSetting)];
    item = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.rightBarButtonItem = item;
    
    self.navigationController.navigationBar.barTintColor = UIColorRGB(4, 4, 4);
    
    [self loadTitleView:@"首页"];
}

- (void)clickBlueTooth
{
  
}

- (void)clickSetting
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadTitleView:(NSString *)text
{
    _titleLabel = [UILabel simpleWithRect:CGRectMake(0, 0, 120, 40)];
    _titleLabel.text = text;
    _titleLabel.font = [UIFont systemFontOfSize:20];
    self.navigationItem.titleView = _titleLabel;
    
    self.navigationController.navigationBar.barTintColor = UIColorHEX(0x272530);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self loadItemButton];
}

// 下面的是6.0以后的
#pragma mark 旋屏
- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

@end
