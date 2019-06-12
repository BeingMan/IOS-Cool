//
//  FirstTableViewController.m
//  Final
//
//  Created by ybc on 2019/5/30.
//  Copyright © 2019 ybc. All rights reserved.
//

#import "FirstTableViewController.h"
#import "User+CoreDataClass.h"
#import "Task+CoreDataClass.h"
#import <CoreData/CoreData.h>
#import "Check.h"
#import "NewCell.h"
#import "ShowTaskViewController.h"
#import "EditViewController.h"
#define FileName @"ybc.Final.plist"
#define UPDATE_INFO_NOTIFICATION @"updateInfo1"
#define EDITDATE_INFO_NOTIFICATION @"updateInfo"


@interface FirstTableViewController ()<NewCellDelegate>
@property NSMutableArray<Task*> *toDoItems;
@property(strong,nonatomic)NSManagedObjectContext *context;
@property Task* sendTask;
@property (nonatomic, strong) NSTimer *timer;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segentButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortButton;
- (IBAction)changeSort:(id)sender;
- (IBAction)segent:(id)sender;
@property Boolean *sort;
@end

@implementation FirstTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sort = false;
    [self addObserverToNotification];
    [self setupContext];
    self.toDoItems = [[NSMutableArray alloc] init];
    [self loadData];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.toDoItems count];
}

- (void)loadData {
    [self setupContext];
    User *user = [self findCurUser];
    NSArray<Task*> *items = [[NSArray alloc]init];
    items = [user.task allObjects];
    NSArray *testArr = [[NSArray alloc]init];
    if(self.sort){
        testArr = [items sortedArrayUsingFunction:intSortUp context:nil];
    }else{
        testArr = [items sortedArrayUsingFunction:intSortDown context:nil];
    }
    NSMutableArray *segArr =[[NSMutableArray alloc]init];
    if(self.segentButton.selectedSegmentIndex == 0){
        for(Task * task in testArr){
            if([task.completed isEqualToString:@"0"]){
                [segArr addObject:task];
            }
        }
    }else{
        segArr = [testArr mutableCopy];
    }
    self.toDoItems = segArr;
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

NSInteger intSortUp(Task *num1, Task *num2, void *context)
{
    
    int v1 = [num1.taskid intValue];
    int v2 = [num2.taskid intValue];
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

NSInteger intSortDown(Task *num1, Task *num2, void *context)
{
    
    int v1 = [num1.taskid intValue];
    int v2 = [num2.taskid intValue];
    if (v1 > v2)
        return NSOrderedAscending;
    else if (v1 < v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ListPrototypeCell";
    NewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Task *toDoItem = [self.toDoItems objectAtIndex:indexPath.row];
    cell.title.text = toDoItem.name;
    cell.comment.text = toDoItem.con1;
    if(((int)[toDoItem.time timeIntervalSinceNow])<0){
        cell.title.textColor = [UIColor grayColor];
        cell.comment.textColor = [UIColor grayColor];
    }else{
        cell.title.textColor = [UIColor blackColor];
        cell.comment.textColor = [UIColor blackColor];
    }
    if ([toDoItem.completed isEqualToString:@"1"]) {
        UIImage *image =[UIImage imageNamed:@"check2"];
        [cell.icon setImage:image forState:UIControlStateNormal];
    } else {
        UIImage *image =[UIImage imageNamed:@"check1"];
        [cell.icon setImage:image forState:UIControlStateNormal];
    }
    cell.delegate = self;
    cell.tag =[toDoItem.taskid intValue];
    return cell;
}

-(void)NewCellDidClickAddButton:(NewCell *)cell{
    Task *task =[self findTaskWithId:[NSString stringWithFormat:@"%d",(int)cell.tag]];
    if([task.completed isEqualToString:@"1"]){
        task.completed =@"0";
    }else{
        task.completed =@"1";
    }
    [self.context save:nil];
    [self loadData];
    [self.tableView reloadData];
}

-(void)addObserverToNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfo:) name:UPDATE_INFO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editdateInfo:) name:EDITDATE_INFO_NOTIFICATION object:nil];

}

-(void)updateInfo:(NSNotification *)notification{
    [self loadData];
    [self.tableView reloadData];
}

-(void)editdateInfo:(NSNotification *)notification{
    [self loadData];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(self.sort){
        self.sendTask = [self findTaskWithId:[NSString stringWithFormat:@"%d",(int)indexPath.row]];
    }else{
        self.sendTask = [self findTaskWithId:[NSString stringWithFormat:@"%lu",(self.toDoItems.count - (int)indexPath.row -1)]];
    }
    [self performSegueWithIdentifier:@"showTask" sender:self];
}

-(Task *)findTaskWithId:(NSString *)taskid{
    User *user = [self findCurUser];
    NSArray<Task*> *items = [[NSArray alloc]init];
    items = [user.task allObjects];
    Task *task =[[Task alloc]init];
    for(Task *item in items){
        if([item.taskid isEqualToString:taskid]){
            task = item;
            return task;
        }
    }
    return task;
    
}

-(void)delTaskWithId:(NSString *)taskid{
    User *user = [self findCurUser];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Task"];
    
    NSError *error = nil;
    NSArray *tasks = [self.context executeFetchRequest:request error:&error];
    if (!error) {
        for (Task *task in tasks) {
            if(task.user == user){
                if([task.taskid intValue]== [taskid intValue]){
                    [self.context deleteObject:task];
                }else if([task.taskid intValue] > [taskid intValue]){
                    task.taskid = [NSString stringWithFormat:@"%d",(int)([task.taskid intValue]-1)];
                }
            }
        }
    }else{
        NSLog(@"%@",error);
    }
    [self.context save:nil];
}

- ( UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {

    UIContextualAction *editRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"编辑" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        User *user = [self findCurUser];
        NSArray *array = [user.task allObjects];
        if(self.sort){
            self.sendTask = [self findTaskWithId:[NSString stringWithFormat:@"%d",(int)indexPath.row]];
        }else{
            self.sendTask = [self findTaskWithId:[NSString stringWithFormat:@"%d",(int)(array.count-(int)indexPath.row-1)]];
        }
        
        [self performSegueWithIdentifier:@"editTask" sender:self];
        [self.tableView reloadData];
    }];
    editRowAction.image = [UIImage imageNamed:@"编辑"];
    editRowAction.backgroundColor = [UIColor grayColor];
    
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

        [self delTaskWithId:[NSString stringWithFormat:@"%d",(int)indexPath.row]];
        [self loadData];
        completionHandler (YES);
        [self.tableView reloadData];
    }];
    deleteRowAction.image = [UIImage imageNamed:@"删除"];
    deleteRowAction.backgroundColor = [UIColor redColor];
    
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction,editRowAction]];
    return config;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"editTask"]) {
        UIViewController *vc = segue.destinationViewController;
        [vc setValue:self.sendTask forKey:@"rectask"];
    }else if ([segue.identifier isEqualToString:@"showTask"]) {
        UIViewController *vc = segue.destinationViewController;
        [vc setValue:self.sendTask forKey:@"rectask"];
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

-(void)keyboardWillShow:(NSNotification *)notification{
    [UIView beginAnimations:@"keyboardWillShow" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGRect rect=self.view.frame;
    rect.origin.y=-60;
    self.view.frame=rect;
    [UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView beginAnimations:@"keyboardWillHide" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    self.view.frame = rect;
    [UIView commitAnimations];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

-(void)alertViewWithTitle:(NSString *)title message:(NSString *)message CertainButtonTitle:(NSString *)buttonTitle{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title  message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defult = [UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defult];
    [self presentViewController:alert animated:YES completion:nil];
}

-(NSString *)filePath
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [array objectAtIndex:0];
    NSString *finalPath = [path stringByAppendingPathComponent:@"Preferences"];
    return [finalPath stringByAppendingPathComponent:FileName];
}


- (IBAction)changeSort:(id)sender {
    if(self.sort){
        _sort = (Boolean *)false;
        self.sortButton.image =[UIImage imageNamed:@"down"];
    }else{
        _sort = (Boolean *)true;
        self.sortButton.image =[UIImage imageNamed:@"up"];
    }
    [self loadData];
    [self.tableView reloadData];
}

- (IBAction)segent:(id)sender {
    [self loadData];
    [self.tableView reloadData];
}
@end

