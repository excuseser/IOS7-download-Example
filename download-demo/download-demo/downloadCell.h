//
//  downloadCell.h
//  download-demo
//
//  Created by kan xu on 15/11/16.
//  Copyright © 2015年 kan xu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface downloadCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *progressLabel;
@property (nonatomic, strong) IBOutlet UILabel *stateLabel;
@property (nonatomic, strong) IBOutlet UIProgressView *fileProgress;
@property (nonatomic, strong) IBOutlet UIImageView *img;

@end
