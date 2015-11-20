//
//  downloadCell.m
//  download-demo
//
//  Created by kan xu on 15/11/16.
//  Copyright © 2015年 kan xu. All rights reserved.
//

#import "downloadCell.h"

@implementation downloadCell

- (void)awakeFromNib {
    // Initialization code
    _nameLabel.text = @"";
    _stateLabel.text = @"";
    _fileProgress.progress = 0;
    _progressLabel.text = @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
