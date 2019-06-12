//
//  EditContactViewController.m
//  Final
//
//  Created by ybc on 2019/6/7.
//  Copyright © 2019 ybc. All rights reserved.
//

#import "EditContactViewController.h"
#import <CoreData/CoreData.h>
#import "Check.h"
#import "User+CoreDataClass.h"
#import "Contact+CoreDataClass.h"

#define FileName @"ybc.Final.plist"
#define EDITUPDATE_INFO_NOTIFICATION @"updateInfo3"

@interface EditContactViewController ()
@property(strong,nonatomic)NSManagedObjectContext *context;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *number;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *qq;
@property (weak, nonatomic) IBOutlet UITextField *wechat;
@property (weak, nonatomic) IBOutlet UITextField *email;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end

@implementation EditContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContext];
    
    self.name.text = self.reccont.name;
    self.number.text = self.reccont.number;
    self.phone.text = self.reccont.phone;
    self.qq.text = self.reccont.qq;
    self.wechat.text = self.reccont.wechat;
    self.email.text = self.reccont.email;
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

-(Contact *)findContWithId:(NSString *)contid{
    User *user = [self findCurUser];
    NSArray<Contact*> *items = [[NSArray alloc]init];
    items = [user.contact allObjects];
    Contact *cont =[[Contact alloc]init];
    for(Contact *item in items){
        if([item.contid isEqualToString:contid]){
            cont = item;
            return cont;
        }
    }
    
    return cont;
}

-(void)postNotification{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDITUPDATE_INFO_NOTIFICATION object:self userInfo:nil];
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

// 获取路径FileName文件的路径的方法
-(NSString *)filePath
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [array objectAtIndex:0];
    NSString *finalPath = [path stringByAppendingPathComponent:@"Preferences"];
    return [finalPath stringByAppendingPathComponent:FileName];
}

- (IBAction)done:(id)sender {
    NSString *name = self.name.text;
    NSString *number =self.number.text;
    NSString *phone =self.phone.text;
    NSString *qq =self.qq.text;
    NSString *wechat =self.wechat.text;
    NSString *email =self.email.text;

    if( !name.length ){
        [self alertViewWithTitle:@"提示" message:@"名字不能为空！"CertainButtonTitle:@"确定"];
        return;
    }else if(![Check validateMobile:phone] && phone.length){
        [self alertViewWithTitle:@"提示" message:@"请输入正确手机号！"CertainButtonTitle:@"确定"];
        return;
    }else if(![Check validateEmail:email] && email.length){
        [self alertViewWithTitle:@"提示" message:@"请输入正确邮箱！"CertainButtonTitle:@"确定"];
        return;
    }
    
    Contact *cont = [self findContWithId:self.reccont.contid];
    cont.name = name;
    cont.number = number;
    cont.phone = phone;
    cont.email = email;
    cont.wechat = wechat;
    cont.qq = qq;
    
    NSError *error = nil;
    [self.context save:&error];
    if (!error) {
        [self.view endEditing:YES];
        [self postNotification];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        NSLog(@"%@",error);
    }
    
}

- (IBAction)cancel:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
