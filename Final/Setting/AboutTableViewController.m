//
//  AboutTableViewController.m
//  Final
//
//  Created by ybc on 2019/6/10.
//  Copyright © 2019 ybc. All rights reserved.
//

#import "AboutTableViewController.h"
#import "AboutCell.h"
@interface AboutTableViewController ()

@end

@implementation AboutTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row ==0){
        return 220;
    }else{
        return 45;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row ==0){
        NSString *CellIdentifier = @"AboutCell";
        AboutCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        [cell.image setImage:[UIImage imageNamed:@"user.png"]];
        cell.name.text = @"事务管理APP";
        cell.version.text = @"Version 1.0.0";
        return cell;
    }else{
        NSString *CellIdentifier = @"defCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        switch (indexPath.row) {
            case 1:
                cell.textLabel.text =@"去评分";
                break;
               
            case 2:
                cell.textLabel.text =@"功能介绍";
                break;
            case 3:
                cell.textLabel.text =@"投诉";
                break;
            case 4:
                cell.textLabel.text =@"版本更新";
                break;
            default:
                break;
        }
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
}
@end
