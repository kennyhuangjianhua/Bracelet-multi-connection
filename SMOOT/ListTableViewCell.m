//
//  ListTableViewCell.m
//  SMOOT
//
//  Created by 黄建华 on 2017/11/6.
//  Copyright © 2017年 zorro. All rights reserved.
//

#import "ListTableViewCell.h"

@implementation ListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [ super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self loadCell];
        //        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)loadCell
{
    _listLabel = [[UILabel alloc] init];
    [self addSubview:_listLabel];
    
    _deviceInfoLabel = [[UILabel alloc] init];
    [self addSubview:_deviceInfoLabel];
    
    _deviceInfoImageView = [[UIButton alloc] init];
    [self addSubview:_deviceInfoImageView];
}

- (void)updateCellWitchAtIndexPath:(NSIndexPath *)indexPath withtext:(NSString *)text ishidden:(BOOL)hidden
{
    self.hidden = hidden;
    _listLabel.textColor = [UIColor whiteColor];
    _listLabel.font = HHHFONT(15.0);
    _listLabel.frame = CGRectMake(44, 12, 200, 20);
    _listLabel.text = text;
    
    _deviceInfoLabel.textColor = [UIColor whiteColor];
    _deviceInfoLabel.font = HHHFONT(15.0);
    _deviceInfoLabel.textAlignment = NSTextAlignmentRight;
    _deviceInfoLabel.frame = CGRectMake(HHHWIDTH - 230, 12, 200, 20);
    _deviceInfoLabel.text = text;
    
    _deviceInfoImageView.frame = CGRectMake(HHHWIDTH - 70, 0, 40, 40);

    if (indexPath.section == 0)
    {
        _listLabel.hidden = NO;
        if (KK_BLTModel.isConnected)
        {
            // 显示
            if (indexPath.row == 1 || indexPath.row ==2)
            {
                _deviceInfoLabel.hidden = YES;
                _deviceInfoImageView.hidden = NO;
            }
            else
            {
                _deviceInfoLabel.hidden = NO;
                _deviceInfoImageView.hidden = YES;
            }
            
        }
        else
        {
             _deviceInfoImageView.hidden = YES;
             _deviceInfoLabel.hidden = YES;
        }
        
        //设置
        if (indexPath.row == 0)
        {
            _deviceInfoLabel.text = KK_BLTModel.bltName;
        }
        
         if (indexPath.row == 1)
         {
             if (KK_BLTModel.isConnected)
             {
                 _deviceInfoImageView.imageNormal = @"连接";
             }
             else
             {
                 _deviceInfoImageView.imageNormal = @"断开";
             }
         }
        if (indexPath.row == 2)
        {
            if (KK_BLTModel.isConnected)
            {
                [self updateRssiImage];
            }
        }
        if (indexPath.row == 3)
        {
            _deviceInfoLabel.text = [NSString stringWithFormat:@"%ld%%",KK_BLTModel.batteryQuantity];
        }
        if (indexPath.row == 4)
        {
            _deviceInfoLabel.text = KK_BLTModel.macAddress;
        }
        
        if (indexPath.row == 5)
        {
            _deviceInfoLabel.text = [NSString stringWithFormat:@"%d",KK_BLTModel.bltVersion];
        }

    }
    else
    {
        _listLabel.hidden = NO;
        _deviceInfoLabel.hidden = YES;
        _deviceInfoImageView.hidden = YES;
    }
}

- (void)updateRssiImage
{
    NSInteger rssi = KK_BLTModel.bltRSSI.intValue;
    
    if (rssi <40)
    {
       _deviceInfoImageView.imageNormal = @"信号5";
    }
    else if(rssi >40 && rssi <55)
    {
        _deviceInfoImageView.imageNormal = @"信号4";
    }
    else if(rssi >55 && rssi <70)
    {
        _deviceInfoImageView.imageNormal = @"信号3";
    }
    else if(rssi >70 && rssi <85)
    {
        _deviceInfoImageView.imageNormal = @"信号2";
    }
    else
    {
        _deviceInfoImageView.imageNormal = @"信号1";
    }
        
}

@end
