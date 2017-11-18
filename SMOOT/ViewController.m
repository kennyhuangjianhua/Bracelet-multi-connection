//
//  ViewController.m
//  project
//
//  Created by 黄建华 on 2017/9/23.
//  Copyright © 2017年 黄建华. All rights reserved.
//

#import "ViewController.h"
#import "DeviceViewController.h"
#import "ListTableViewCell.h"
#import "BLTPeripheral.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIImageView *backImageView = [[UIImageView alloc] init];
    backImageView.image = [UIImage imageNamed:@"背景"];
    backImageView.frame = CGRectMake(0, 0, HHHWIDTH, HHHHEIGHT);
    [self.view addSubview:backImageView];
    
    UIView *start = [[UIView alloc] init];
    start.frame = CGRectMake(0, 0, HHHWIDTH, 20);
    [self.view addSubview:start];
    
    UIButton *search = [[UIButton alloc] init];
    search.frame = CGRectMake(50, 20, 40, 40);
    search.imageNormal = @"search";
    search.imageSelecte = @"search";
    [search addTarget:self action:@selector(searchButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:search];
    
    
    UILabel *searchLabel = [[UILabel alloc] init];
    searchLabel.frame = CGRectMake(100, 30, 120, 20);
    searchLabel.text = @"搜索设备";
    searchLabel.font = HHHFONT(15.0);
    searchLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:searchLabel];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.frame = CGRectMake(HHHWIDTH - 180, 35, 180, 20);
    _timeLabel.text = [[NSDate date] dateToString];
    _timeLabel.font = HHHFONT(15.0);
    _timeLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:_timeLabel];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(updateTimeR) userInfo:nil repeats:YES];
    
    _listArray = [[NSArray alloc] initWithObjects:@"设备名称",@"设备连接状态",@"设备信号强度",@"设备当前电量",@"MAC地址",@"设备固件号", nil];
    
    _testFunctionArray = [[NSArray alloc] initWithObjects:@"屏幕显示测试",@"马达测试",@"三轴传感器测试",@"字库测试",@"查找手环测试(开)",@"查找手环测试(关)",@"相机拍照测试(开)",@"相机拍照测试(关)",@"心率传感器测试(开)",@"心率传感器测试(关)",@"血氧传感器测试(开)", @"血氧传感器测试(关)",@"血压传感器测试(开)",@"血压传感器测试(关)",@"用户信息设置",@"实时步数获取",@"计步大数据",@"睡眠大数据",@"心率大数据",@"重启设备", nil];
    
    _writeView = [[UITextView alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBleDeviceState) name:@"updateBleDeviceState" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bleacceptdata:) name:@"bleacceptdata" object:nil];
//    [self tableViewSetupUi];
    
    _isWriteCommand = NO;
    
    _readString = [NSMutableString string];
}

- (void)bleacceptdata:(NSNotification *)info
{
    NSData *data = [info object];
    NSMutableString *stringV = [NSMutableString string];
    UInt8 val[20] = {0};
    [data getBytes:&val length:data.length];
    
   
    if (val[1] == 0x07)
    {
        if (val[2] == 0x01)
        {
            if (data.length>3)
            {
          NSInteger step = val[3] * 256 * 256 * 256 + val[4] * 256 * 256 + val[5] * 256 + val[6];
          NSInteger tmpDistance = val[7] * 256 * 256 * 256 + val[8] * 256 * 256 + val[9] * 256 + val[10];
          NSInteger tmpCalory = val[11] * 256 * 256 * 256 + val[12] * 256 * 256 + val[13] * 256 + val[14];
         [stringV appendString:[NSString stringWithFormat:@"当前步数:[ %ld ]路里:[ %ld ]距离:[ %ld ]",(long)step,(long)tmpCalory,(long)tmpDistance]];
            }
        }
    }
    
    for(int i = 0 ; i < data.length ; i++)
    {
        [stringV appendString:[NSString stringWithFormat:@"%02X ",val[i]]];
    }
    [stringV appendString:@"\n"];

    [_readString insertString:stringV atIndex:0];
    NSLog(@"接收到的数据为>>>>>%@",_readString);
    
    
    
    
    if (!_isWriteCommand)
    {
        [_tabelView reloadData];
    }
}

- (void)updateBleDeviceState
{
    if (KK_BLTModel.isConnected)
    {
        SHOWMBProgressHUD(@"连接成功", nil, nil, NO, 2.0);
    }
    else
    {
        SHOWMBProgressHUD(@"断开连接", nil, nil, NO, 2.0);
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateBleDeviceState" object:nil];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.tag == 1000)
    {
      NSLog(@"text write >>>>>>%@",textView.text);
        _writeString = textView.text;
        _isWriteCommand = NO;
        [_tabelView reloadData];
    }
    else if (textView.tag == 2000)
    {
      NSLog(@"text read >>>>>>%@",textView.text);
//        _readString = textView.text;
    }

}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    _isWriteCommand = YES;
}

- (void)tableViewSetupUi
{
    if (_tabelView )
    {
        [_tabelView removeFromSuperview];
        _tabelView.delegate = nil;
        _tabelView.dataSource = nil;
        _tabelView = nil;
    }
    _tabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, HHHWIDTH, HHHHEIGHT -64) style:UITableViewStyleGrouped];
    _tabelView.delegate = self;
    _tabelView.dataSource = self;
    [self.view addSubview:_tabelView];
    _tabelView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    _tabelView.sectionFooterHeight = 0.0;
    _tabelView.sectionHeaderHeight = 0.0;
    _tabelView.backgroundColor = [UIColor clearColor];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [self tableViewSetupUi];
}

- (void)updateTimeR
{
    _timeLabel.text = [[NSDate date] dateToString];
    if (KK_BLTModel.isConnected)
    {
        [[BLTPeripheral sharedInstance]updateRSSI];
         NSLog(@"updateDeviceRssi >>>>>>>%@",KK_BLTModel.bltRSSI);
        [_tabelView reloadData];
    }
}

- (void)searchButtonClick
{
    NSLog(@"searchButtonClick>>>>>>");
    [AJ_LastWareUUID setObjectValue:@""];
    DeviceViewController *vc = [[DeviceViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
    if (section == 0 ||section == 3)
    {
          return 40.0;
    }
    else
    {
         return 40.0;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 40.0;
    }
    else if (indexPath.section ==1)
     {
        return 40.0;
     }
    else if (indexPath.section ==2)
    {
        return 80.0;
    }
    else
    {
        return 40.0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return _listArray.count;
    }
    else  if (section == 1)
    {
        return  1;
    }
    else  if (section == 2)
    {
        return  1;
    }
    else
    {
        return _testFunctionArray.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return @"当前设备信息";
    }
     else  if (section == 1)
     {
         return @"发送数据";
     }
     else  if (section == 2)
     {
         return @"接收数据";
     }
    
    else
    {
        return @"测试项目";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ListTableViewCell";
   ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    
    if (nil == cell)
    {
        cell = [[ListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];

        if(indexPath.section == 1)
        {
            UITextView *write = [[UITextView alloc] init];
            write.tag = 1000;
            write.delegate = self;
            [cell.contentView addSubview:write];
            UIButton *sendButton = [[UIButton alloc] init];
            sendButton.tag = 3000;
            [cell.contentView addSubview:sendButton];
        }
        
        if(indexPath.section == 2)
        {
            UITextView *read = [[UITextView alloc] init];
            read.delegate = self;
            read.tag = 2000;
            [cell.contentView addSubview:read];
        }
    }
    
    [cell.contentView setBackgroundColor:UIColorHEX(0x2f2f30)];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = HHHFONT(15.0);

    if (indexPath.section == 0)
    {
        cell.textLabel.text = @"";
        [cell updateCellWitchAtIndexPath:indexPath withtext:_listArray[indexPath.row] ishidden:NO];
    }
    else if (indexPath.section == 1)
    {
        UITextView *write = (UITextView *)[cell viewWithTag:1000];
        write.frame = CGRectMake(0, 0, HHHWIDTH - 220, 40);
        write.text = _writeString;
        
        UIButton *sendButton = (UIButton *)[cell viewWithTag:3000];
        sendButton.frame = CGRectMake(HHHWIDTH - 120, 0, 120, 40);
        [sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
        sendButton.backgroundColor = [UIColor redColor];
        
    }
    else if (indexPath.section == 2)
    {
        UITextView *read = (UITextView *)[cell viewWithTag:2000];
        read.frame = CGRectMake(0, 0, HHHWIDTH, 80);
        read.text = _readString;
    }
    else if (indexPath.section == 3)
    {
         [cell updateCellWitchAtIndexPath:indexPath withtext:_testFunctionArray[indexPath.row] ishidden:NO];
    }
    
    return cell;
}

- (void)sendButtonClick
{
    NSLog(@"发送数据>>>>>>>>>%@",_writeString);

    if (_writeString.length %2 == 0)
    {
        _readString = [NSMutableString string];
        [KK_BLTSend sendSendValue:^(id object, BLTAcceptModelType type)
         {
             
         } withString:_writeString];
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 || indexPath.section == 2)
    {
        UITableViewCell *cell=[tableView cellForRowAtIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    if (indexPath.section == 3)
    {
        if (indexPath.row == 0)
        {
            [KK_BLTSend screenTest:^(id object, BLTAcceptModelType type) {
                
            }];
        }
        else if (indexPath.row == 1)
        {
            [KK_BLTSend motorTest:^(id object, BLTAcceptModelType type)
            {
                
            }];
        }
        else if (indexPath.row == 2)
        {
            [KK_BLTSend threeaxisTest:^(id object, BLTAcceptModelType type) {
                
            }];
        }
        else if (indexPath.row == 3)
        {
            [KK_BLTSend fontTest:^(id object, BLTAcceptModelType type) {
                
            }];
        }
        else if (indexPath.row == 4)
        {
            [KK_BLTSend sendSetFindBle:YES withUpdateBlock:^(id object, BLTAcceptModelType type) {
                
            }];
        }
        else if (indexPath.row == 5)
        {
            [KK_BLTSend sendSetFindBle:NO withUpdateBlock:^(id object, BLTAcceptModelType type) {
                
            }];
        }
        else if (indexPath.row == 6)
        {
            [KK_BLTSend sendControlTakePhotoState:YES WithUpdateBlock:^(id object, BLTAcceptModelType type)
            {
            
            }];

        }
        else if (indexPath.row == 7)
        {
            [KK_BLTSend sendControlTakePhotoState:NO WithUpdateBlock:^(id object, BLTAcceptModelType type)
             {
                 
             }];
        }
        
        else if (indexPath.row == 8)
        {
            [KK_BLTSend heartTest:^(id object, BLTAcceptModelType type)
            {
                
            } type:YES];
            
        }
        else if (indexPath.row == 9)
        {
            [KK_BLTSend heartTest:^(id object, BLTAcceptModelType type)
             {
                 
             } type:NO];
        }
        else if (indexPath.row == 10)
        {
            [KK_BLTSend oxTest:^(id object, BLTAcceptModelType type) {
                
            } type:YES];
            
        }
        else if (indexPath.row == 11)
        {
            [KK_BLTSend oxTest:^(id object, BLTAcceptModelType type) {
                
            } type:NO];
        }
        else if (indexPath.row == 12)
        {
            [KK_BLTSend bpTest:^(id object, BLTAcceptModelType type) {
                
            } type:YES];
            
        }
        else if (indexPath.row == 13)
        {
            [KK_BLTSend bpTest:^(id object, BLTAcceptModelType type) {
                
            } type:NO];
        }
        else if (indexPath.row == 14)
        {
            [KK_BLTSend sendUserInfoSettingWithBlock:^(id object, BLTAcceptModelType type) {
                
            }];
        }
        else if (indexPath.row == 15)
        {
            [KK_BLTSend realStep:^(id object, BLTAcceptModelType type) {
                
            }];
        }
        else if (indexPath.row == 16)
        {
            [KK_BLTSend sendBigStepWithUpdate:^(id object, BLTAcceptModelType type) {
                
            }];
        }
        else if (indexPath.row == 17)
        {
            [KK_BLTSend sendBigSleepWithUpdate:^(id object, BLTAcceptModelType type) {
                
            }];
        }
        else if (indexPath.row == 18)
        {
            [KK_BLTSend sendBigheartWithUpdate:^(id object, BLTAcceptModelType type) {
                
            }];
        }
        else if (indexPath.row == 19)
        {
            [KK_BLTSend sendDeviceRebootWithUpdate:^(id object, BLTAcceptModelType type) {

            }];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

