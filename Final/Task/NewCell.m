//
//  NewCell.m
//  Final
//
//  Created by ybc on 2019/6/5.
//  Copyright © 2019 ybc. All rights reserved.
//

#import "NewCell.h"

@interface NewCell ()
@property(strong,nonatomic)NSManagedObjectContext *context;
@end

@implementation NewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

- (IBAction)addBtnClick {
    if ([self.delegate respondsToSelector:@selector(NewCellDidClickAddButton:)]) {
        [self.delegate NewCellDidClickAddButton:self];
    }

}

@end
