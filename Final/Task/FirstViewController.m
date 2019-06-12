//
//  FirstViewController.m
//  Final
//
//  Created by ybc on 2019/6/2.
//  Copyright © 2019 ybc. All rights reserved.
//

#import "FirstViewController.h"
#import <CoreData/CoreData.h>
#import "Check.h"
#import "User+CoreDataClass.h"
#import "Task+CoreDataClass.h"
#import "PCDatePickerView.h"
#define FileName @"ybc.Final.plist"
#define UPDATE_INFO_NOTIFICATION @"updateInfo1"
@interface FirstViewController ()
@property(strong,nonatomic)NSManagedObjectContext *context;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *context1;
@property (weak, nonatomic) IBOutlet UITextField *dt;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UITextView *context2;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)show:(id)sender;
@property (nonatomic, strong) PCDatePickerView *datePicker;
@property (strong,nonatomic) NSDate *recDate;
@property (strong,nonatomic) Task *rectask;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.context2.layer.borderColor=[UIColor grayColor].CGColor;
    self.context2.layer.borderWidth=1.0;
    self.context2.layer.cornerRadius=5.0;
    self.context1.layer.borderColor=[UIColor grayColor].CGColor;
    self.context1.layer.borderWidth=1.0;
    self.context1.layer.cornerRadius=5.0;
    self.name.layer.borderColor=[UIColor grayColor].CGColor;
    self.name.layer.borderWidth=1.0;
    self.name.layer.cornerRadius=5.0;
    self.dt.layer.borderColor=[UIColor grayColor].CGColor;
    self.dt.layer.borderWidth=1.0;
    self.dt.layer.cornerRadius=5.0;
    self.dt.enabled = false;
    
    [self setupContext];
    
    self.datePicker = [[PCDatePickerView alloc] init];
    [self.view addSubview:self.datePicker];
    __weak __typeof(&*self) weakSelf = self;
    _datePicker.doneAction = ^(NSDate *date){
        [weakSelf sureDatePickerView:date];
    };
    
}

- (void)sureDatePickerView:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    self.dt.text =strDate;
    self.recDate = [[NSDate alloc]init];
    self.recDate = date;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (sender != self.doneButton) return;
    
}

- (IBAction)cancel:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    NSString *name = self.name.text;
    NSString *con1 = self.context1.text;
    NSString *con2 = self.context2.text;
    NSString *dt = self.dt.text;
    NSArray<Task*> *items = [[NSArray alloc]init];
    
    if( !name.length || !con1.length || !dt.length){
        [self alertViewWithTitle:@"提示" message:@"信息不能为空！"CertainButtonTitle:@"确定"];
        return;
    }
    
    NSString *username =[[NSString alloc]init];
    NSFileManager *manager=[NSFileManager defaultManager];
    if ([manager fileExistsAtPath:[self filePath]]) {
        NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
        username=[user objectForKey:@"Name"];
    }
    User *user =[[User alloc]init];
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
    
    items = [user.task allObjects];
    
    Task *task = [NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:self.context];
    task.name = name;
    task.con1 = con1;
    task.con2 = con2;
    task.time = self.recDate;
    task.user = user;
    task.taskid = [NSString stringWithFormat:@"%d",(int)(items.count)];
    task.completed = @"0";
    
    self.rectask = task;
    [self.context save:&error];
    if (!error) {
        [self.view endEditing:YES];
        [self postNotification];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        NSLog(@"%@",error);
    }
}

- (IBAction)show:(id)sender {
    [self.datePicker showView];
}

-(void)postNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_INFO_NOTIFICATION object:self userInfo:nil];
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
@end
