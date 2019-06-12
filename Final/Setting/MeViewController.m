//
//  MeViewController.m
//  Final
//
//  Created by ybc on 2019/6/10.
//  Copyright © 2019 ybc. All rights reserved.
//

#import "MeViewController.h"
#import <CoreData/CoreData.h>
#import "User+CoreDataClass.h"
#import "Check.h"
#define FileName @"ybc.Final.plist"
#define UPDATE_INFO_NOTIFICATION @"updateInfo4"
@interface MeViewController ()
@property(strong,nonatomic)NSManagedObjectContext *context;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
- (IBAction)edit:(id)sender;
- (IBAction)save:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *editBt;
@property Boolean isEdit;
@property (nonatomic,strong) User *curUser;
@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isEdit =false;
    [self initData];
    
}
-(void)initData{
    [self setupContext];
    _curUser = [self findCurUser];
    self.name.enabled =false;
    self.phone.enabled =false;
    self.email.enabled =false;
    self.password.enabled =false;
    self.name.text = _curUser.name;
    self.phone.text = _curUser.phone;
    self.email.text = _curUser.email;
    self.password.text = @"";
    [self.editBt setTitle: @"编辑" forState:UIControlStateNormal];
}

- (IBAction)edit:(id)sender {
    if(self.isEdit){
        [self initData];
    }else{
        self.name.enabled =true;
        self.phone.enabled =true;
        self.email.enabled =true;
        self.password.enabled =true;
        [self.editBt setTitle: @"取消" forState:UIControlStateNormal];
    }
    self.isEdit=!self.isEdit;
}

- (IBAction)save:(id)sender {
    NSString *name = self.name.text;
    NSString *phone = self.phone.text;
    NSString *email = self.email.text;
    NSString *password = self.password.text;
    if (!name.length||!password.length || !phone.length || !email.length) {
        [self alertViewWithTitle:@"提示" message:@"信息不能为空！"CertainButtonTitle:@"确定"];
        return;
    }else if(![Check validateMobile:phone]){
        [self alertViewWithTitle:@"提示" message:@"请输入正确手机号！"CertainButtonTitle:@"确定"];
        return;
    }else if(![Check validateEmail:email]){
        [self alertViewWithTitle:@"提示" message:@"请输入正确邮箱！"CertainButtonTitle:@"确定"];
        return;
    }
    
    NSError *error = nil;
    _curUser.name = name;
    _curUser.phone = phone;
    _curUser.email = email;
    _curUser.password = password;
    [self.context save:&error];
    if (!error) {
        [self.view endEditing:YES];
        [self alertViewWithTitle:@"提示" message:@"修改成功!"CertainButtonTitle:@"确定"];
        [self postNotification];
        [self initData];
    }else{
        NSLog(@"%@",error);
    }
}

-(void)postNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_INFO_NOTIFICATION object:self userInfo:nil];
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

// 键盘弹起时触发的方法
-(void)keyboardWillShow:(NSNotification *)notification{
    [UIView beginAnimations:@"keyboardWillShow" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGRect rect=self.view.frame;
    rect.origin.y=-60;
    self.view.frame=rect;
    [UIView commitAnimations];
}

// 键盘关闭时调用的方法
-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView beginAnimations:@"keyboardWillHide" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    self.view.frame = rect;
    [UIView commitAnimations];
}

// 屏幕单击事件响应
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES]; // 退出键盘
}

// 提示信息的方法
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
