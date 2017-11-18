//
//  DeviceViewController.m
//  project
//
//  Created by 黄建华 on 2017/11/4.
//  Copyright © 2017年 黄建华. All rights reserved.
//

#import "DeviceViewController.h"

@interface DeviceViewController ()

@end

@implementation DeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImageView *backImageView = [[UIImageView alloc] init];
    backImageView.image = [UIImage imageNamed:@"背景"];
    backImageView.frame = CGRectMake(0, 0, HHHWIDTH, HHHHEIGHT);
    [self.view addSubview:backImageView];
    
    UIView *start = [[UIView alloc] init];
    start.frame = CGRectMake(0, 0, HHHWIDTH, 20);
    [self.view addSubview:start];
    
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 20, HHHWIDTH, 40);
    view.backgroundColor = UIColorHEX(0x303031);
    [self.view addSubview:view];
    
    UILabel *titleLabel1 = [[UILabel alloc] init];
    titleLabel1.frame = CGRectMake(0, 29, HHHWIDTH, 20);
    titleLabel1.textAlignment = NSTextAlignmentCenter;
    titleLabel1.text = @"设备列表";
    titleLabel1.font = HHHFONT(15.0);
    titleLabel1.textColor = [UIColor whiteColor];
    [self.view addSubview:titleLabel1];
    
    UIButton *search = [[UIButton alloc] init];
    search.frame = CGRectMake(20, 20, 40, 40);
    search.imageNormal = @"返回";
    search.imageSelecte = @"返回";
    [search addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:search];
    
    UILabel *searchLabel = [[UILabel alloc] init];
    searchLabel.frame = CGRectMake(70, 30, 100, 20);
    searchLabel.text = @"返回";
    searchLabel.font = HHHFONT(14.0);
    searchLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:searchLabel];
    
    UIButton *searchDevice = [[UIButton alloc] init];
    [searchDevice setFontSize:14.0];
    searchDevice.frame = CGRectMake(HHHWIDTH - 80, 20, 70, 40);
    [searchDevice setTitle:@"继续搜索" forState:UIControlStateNormal];
    [searchDevice addTarget:self action:@selector(searchDeviceButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchDevice];
    
    _listArray = [NSMutableArray array];

    _tabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64 +40, HHHWIDTH, HHHHEIGHT -64-40) style:UITableViewStyleGrouped];
    _tabelView.delegate = self;
    _tabelView.dataSource = self;
    [self.view addSubview:_tabelView];
    _tabelView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    _tabelView.sectionFooterHeight = 0.0;
    _tabelView.sectionHeaderHeight = 0.0;
    _tabelView.backgroundColor = [UIColor clearColor];
    
    DEF_WEAKSELF_(DeviceViewController);
    [BLTManager sharedInstance].updateModelBlock = ^ (BLTModel *model, BLTUpdateModelType type) {
        [weakSelf updateWithModel:model type:type];
    };
    
    [self searchDeviceButtonClick];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.text = @"设备名过滤:";
    label.frame = CGRectMake(10, 64+10, 100, 30);
    [self.view addSubview:label];
    
    UITextField *text = [[UITextField alloc] init];
    text.frame = CGRectMake(130, 64 +10, HHHWIDTH - 100, 30);
    text.text = @"X9";
    _searchString = text.text;
    text.backgroundColor = [UIColor clearColor];
    text.textColor = [UIColor whiteColor];
    [self.view addSubview:text];
    text.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bleacceptdata:) name:@"bleacceptdata" object:nil];
}

- (void)bleacceptdata:(NSNotification *)info
{
//    NSData *data = [info object];
//    NSMutableString *stringV = [NSMutableString string];
//    UInt8 val[20] = {0};
//    [data getBytes:&val length:data.length];
//
//    if (val[1] == 0x07)
//    {
//        if (val[2] == 0x01)
//        {
//            if (data.length>3)
//            {
//                NSInteger step = val[3] * 256 * 256 * 256 + val[4] * 256 * 256 + val[5] * 256 + val[6];
//                NSInteger tmpDistance = val[7] * 256 * 256 * 256 + val[8] * 256 * 256 + val[9] * 256 + val[10];
//                NSInteger tmpCalory = val[11] * 256 * 256 * 256 + val[12] * 256 * 256 + val[13] * 256 + val[14];
//                [stringV appendString:[NSString stringWithFormat:@"当前步数:[ %ld ]路里:[ %ld ]距离:[ %ld ]",(long)step,(long)tmpCalory,(long)tmpDistance]];
//            }
//        }
//    }
        [_tabelView reloadData];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.text)
    {
        _searchString = textField.text;
        [_tabelView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)updateWithModel:(BLTModel *)model type:(BLTUpdateModelType)type
{
    //       _dataArr = [BLTManager sharedInstance].allWareArray;
    
    if (type == BLTUpdateModelDidConnect)
    {
        SHOWMBProgressHUD(@"连接成功", nil, nil, NO, 1.5);
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(backButtonClick) object:nil];
//        [self performSelector:@selector(backButtonClick) withObject:nil afterDelay:1.0];
    }
    else if (type == BLTUpdateDataTypeNormalData);
    {
        NSArray *arrys =  [BLTManager sharedInstance].allWareArray;
        NSLog(@"蓝牙设备列表>>>>>>%@",arrys);
        
        NSMutableArray *new = [NSMutableArray array];
        
        for (int i = 0; i <arrys.count; i ++)
        {
            BLTModel *model = [arrys objectAtIndex:i];
            if (model.macAddress.length >0 && model.bltName.length > 0)
            {
                NSRange search = [model.bltName rangeOfString:_searchString];
                if (search.location == NSNotFound)
                {
                 
                }
                else
                {
                      [new addObject:model];
                }
                    
            }
        }
        _listArray = [NSMutableArray arrayWithArray:new];
        [_tabelView reloadData];
        
    }
}

- (void)searchDeviceButtonClick
{
    NSLog(@"searchDeviceButtonClick>>>");
//    [[BLTManager sharedInstance] startCan];
//    [KK_BLTSend sendTestWithBlock:^(id object, BLTAcceptModelType type)
//    {
//        
//    }];
}

- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // 设置section字体颜色 背景
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textColor = UIColorHEX(0xfdc776);
    header.contentView.backgroundColor = UIColorHEX(0x1b1c1d);
    header.textLabel.font = HHHFONT(18.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return _listArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
        return @"已发现设备";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"DetailRemindCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:identifier];
        
        UILabel *macAddress = [[UILabel alloc]init];
        macAddress.tag = indexPath.row +100;
        [cell.contentView addSubview:macAddress];
        
        UILabel *stepLabel = [[UILabel alloc]init];
        stepLabel.tag = indexPath.row + 2000;
        [cell.contentView addSubview:stepLabel];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.tag = indexPath.row + 1000;
        [cell.contentView addSubview:imageView];
        
        UIButton *sendStep = [[UIButton alloc] init];
        sendStep.tag = indexPath.row + 3000;
        [cell.contentView addSubview:sendStep];
    }
    
    [cell.contentView setBackgroundColor:UIColorHEX(0x2f2f30)];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = HHHFONT(15.0);
    
    UILabel *stepLabel = (UILabel *)[cell viewWithTag:indexPath.row + 2000];
    stepLabel.frame = CGRectMake(165, 13, 110 , 20);
    stepLabel.font = [UIFont systemFontOfSize:13.0];
    stepLabel.textColor = [UIColor whiteColor];
    
    UIButton *stepButton = (UIButton *)[cell viewWithTag:indexPath.row + 3000];
    stepButton.frame = CGRectMake(HHHWIDTH -40-50, 0, 50, 40);
    [stepButton setTitle:@"获取" forState:UIControlStateNormal];
    [stepButton addTarget:self action:@selector(stepButtonsendStep:) forControlEvents:UIControlEventTouchUpInside];
    [stepButton setFontSize:13.0];
    
    
    UILabel *macAddressLabel = (UILabel *)[cell viewWithTag:indexPath.row + 100];
    macAddressLabel.frame = CGRectMake(50, 13, 150 , 20);
    macAddressLabel.font = [UIFont systemFontOfSize:13.0];
    macAddressLabel.textColor = [UIColor whiteColor];
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:indexPath.row + 1000];
    imageView.frame = CGRectMake(HHHWIDTH - 40, 10, 30, 30);
    
    if (indexPath.section == 0)
    {
        BLTModel *model = _listArray[indexPath.row];
        
        BLTModel *newModel = [BLTModel getModelFromDBWtihUUID:model.bltUUID];
        
        cell.textLabel.text = newModel.bltName;
        macAddressLabel.text = [NSString stringWithFormat:@"%@",newModel.macAddress];
        stepLabel.text = [NSString stringWithFormat:@"步数:%d",newModel.stepTotal];
        if (model.isConnected)
        {
            imageView.image = [UIImage imageNamed:@"连接"];
        }
        else
        {
            imageView.image = [UIImage imageNamed:@"断开"];
        }
    }

    return cell;
}

- (void)stepButtonsendStep:(UIButton *)sender
{
    BLTModel *model = _listArray [sender.tag - 3000];
    BLTModel *getModel = [BLTModel getModelFromDBWtihUUID:model.bltUUID];
    NSLog(@"getModel>>>>>>>step>>>>%d",getModel.stepTotal);
    
    [KK_BLTSend sendTestWithBlock:^(id object, BLTAcceptModelType type) {
        
    } withModel:model];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if (indexPath.row == 0)
    //    {
    //        LLFMDBVc1 *vc = [[LLFMDBVc1 alloc] init];
    //        [self.navigationController pushViewController:vc animated:YES];
    //    }
    //    if (indexPath.row == 1)
    //    {
    //        EWMViewController *vc = [[EWMViewController alloc] init];
    //       [self.navigationController pushViewController:vc animated:YES];
    //    }
    //    if (indexPath.row == 2)
    //    {
    //        BrightnessViewController *vc = [[BrightnessViewController alloc] init];
    //        [self.navigationController pushViewController:vc animated:YES];
    //    }
    //    if (indexPath.row == 3)
    //    {
    //        SpeakChangeStringViewController *vc = [[SpeakChangeStringViewController alloc] init];
    //           [self.navigationController pushViewController:vc animated:YES];
    //    }
    BLTModel *model = _listArray[indexPath.row];
    if (model.isConnected)
    {
        [[BLTManager sharedInstance] disConnectPeripheralWithModel:model];
    }
    else
    {
         [[BLTManager sharedInstance] connectPeripheralWithModel:model];
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
