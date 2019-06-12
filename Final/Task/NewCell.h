//
//  NewCell.h
//  Final
//
//  Created by ybc on 2019/6/5.
//  Copyright © 2019 ybc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NewCell;

@protocol NewCellDelegate <NSObject>

@optional
// 协议中的方法
// 哪个cell的按钮被点击了.传一个cell
- (void)NewCellDidClickAddButton :(NewCell *)cell;

@end
NS_ASSUME_NONNULL_BEGIN

@interface NewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *icon;
@property (weak, nonatomic) IBOutlet UILabel *comment;
@property (weak, nonatomic) IBOutlet UILabel *title;

@property (nonatomic, weak) id<NewCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
