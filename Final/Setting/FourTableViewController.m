//
//  FourTableViewController.m
//  Final
//
//  Created by ybc on 2019/5/31.
//  Copyright © 2019 ybc. All rights reserved.
//

#import "FourTableViewController.h"
#import "User+CoreDataClass.h"
#import <CoreData/CoreData.h>
#import "Check.h"
#define UPDATE_INFO_NOTIFICATION @"updateInfo4"
#define FileName @"ybc.Final.plist"

@interface FourTableViewController ()
@property(strong,nonatomic)NSManagedObjectContext *context;
@end

@implementation FourTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContext];
    [self addObserverToNotification];
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
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"friend";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    User *user = [self findCurUser];
    if (cell == nil) {
        if(indexPath.section ==0){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
            cell.textLabel.text = user.name;
            cell.imageView.image = [UIImage imageNamed:@"user.png"];
        }else{
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"本机资料";
                    break;
                case 1:
                    cell.textLabel.text = @"关于";
                    cell.detailTextLabel.text = @"版本 1.0.0";
                    break;
                case 2:
                    cell.textLabel.text = @"退出";
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
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
    if(indexPath.section == 0 ){
        [self performSegueWithIdentifier:@"me" sender:self];
    }else if( indexPath.row == 0){
        [self performSegueWithIdentifier:@"data" sender:self];
    }else if( indexPath.row == 1){
        [self performSegueWithIdentifier:@"about" sender:self];
    }else if( indexPath.row == 2){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)setupContext{
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    NSManagedObjectModel *model = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *store = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSError *error = nil;
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *sqlitePath = [doc stringByAppendingPathComponent:@"user.sqlite"];
    NSLog(@"文件路径：%@", sqlitePath);
    
    [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[NSURL fileURLWithPath:sqlitePath] options:nil error:&error];
    context.persistentStoreCoordinator = store;
    self.context = context;
}

-(User *) findCurUser{
    User *user = [[User alloc]init];
    NSString *username =[[NSString alloc]init];
    NSFileManager *manager=[NSFileManager defaultManager];
    if ([manager fileExistsAtPath:[self filePath]]) {
        NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
        username=[user objectForKey:@"Name"];
    }
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSError *error = nil;
    if([Check validateMobile:username]){
        request.predicate = [NSPredicate predicateWithFormat:@"phone = %@",username];
    }else{
        request.predicate = [NSPredicate predicateWithFormat:@"email = %@",username];
    }
    NSArray *users = [self.context executeFetchRequest:request error:&error];
    if (!error ) {
        if(users.count>0){
            user = users[0];
        }
    }
    
    return user;
}

// 获取路径FileName文件的路径的方法
-(NSString *)filePath
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [array objectAtIndex:0];
    NSString *finalPath = [path stringByAppendingPathComponent:@"Preferences"];
    return [finalPath stringByAppendingPathComponent:FileName];
}

-(void)addObserverToNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfo:) name:UPDATE_INFO_NOTIFICATION object:nil];
}

-(void)updateInfo:(NSNotification *)notification{
    [self setupContext];
    [self.tableView reloadData];
}

@end
