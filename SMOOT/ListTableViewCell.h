//
//  ListTableViewCell.h
//  SMOOT
//
//  Created by 黄建华 on 2017/11/6.
//  Copyright © 2017年 zorro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTableViewCell : UITableViewCell

- (void)updateCellWitchAtIndexPath:(NSIndexPath *)indexPath withtext:(NSString *)text ishidden:(BOOL)hidden;

@property (nonatomic,strong) UILabel *listLabel;
@property (nonatomic,strong) UILabel *deviceInfoLabel;
@property (nonatomic,strong) UIButton *deviceInfoImageView;
@end
