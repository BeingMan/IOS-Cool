//
//  AboutCell.h
//  Final
//
//  Created by ybc on 2019/6/10.
//  Copyright © 2019 ybc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AboutCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *version;

@end

NS_ASSUME_NONNULL_END
