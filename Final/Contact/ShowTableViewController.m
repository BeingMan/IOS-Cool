//
//  ShowTableViewController.m
//  Final
//
//  Created by ybc on 2019/6/7.
//  Copyright © 2019 ybc. All rights reserved.
//

#import "ShowTableViewController.h"

@interface ShowTableViewController ()

@end

@implementation ShowTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView initWithFrame:CGRectMake(0, 0, 414, 736) style:UITableViewStyleGrouped];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section ==0){
        return 1;
    }else{
        return 5;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"friend";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        if(indexPath.section ==0){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
            cell.textLabel.text = self.reccont.name;
            cell.imageView.image = [UIImage imageNamed:self.reccont.icon];
            
        }else{
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"手 机";
                    cell.detailTextLabel.text = self.reccont.phone;
                    break;
                case 1:
                    cell.textLabel.text = @"学 号";
                    cell.detailTextLabel.text = self.reccont.number;
                    break;
                case 2:
                    cell.textLabel.text = @"Q Q";
                    cell.detailTextLabel.text = self.reccont.qq;
                    break;
                case 3:
                    cell.textLabel.text = @"微 信";
                    cell.detailTextLabel.text = self.reccont.wechat;
                    break;
                case 4:
                    cell.textLabel.text = @"邮 箱";
                    cell.detailTextLabel.text = self.reccont.email;
                    break;
                default:
                    break;
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(indexPath.section == 1 && indexPath.row == 0){
        NSMutableString  * str = [[NSMutableString alloc] initWithFormat:@"tel:%@",self.reccont.phone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]  options:@{UIApplicationOpenURLOptionsSourceApplicationKey : @YES} completionHandler:nil];
    }
}

@end
