//
//  ShowTableViewController.h
//  Final
//
//  Created by ybc on 2019/6/7.
//  Copyright © 2019 ybc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contact+CoreDataClass.h"
NS_ASSUME_NONNULL_BEGIN

@interface ShowTableViewController : UITableViewController
@property (strong,nonatomic) Contact *reccont;
@end

NS_ASSUME_NONNULL_END
