//
//  AddFriendViewController.m
//  Final
//
//  Created by ybc on 2019/6/6.
//  Copyright © 2019 ybc. All rights reserved.
//

#import "AddFriendViewController.h"
#import <CoreData/CoreData.h>
#import "Check.h"
#import "User+CoreDataClass.h"
#import "Contact+CoreDataClass.h"
#define FileName @"ybc.Final.plist"
#define UPDATE_INFO_NOTIFICATION @"updateInfo2"

@interface AddFriendViewController ()
@property(strong,nonatomic)NSManagedObjectContext *context;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *qq;
@property (weak, nonatomic) IBOutlet UITextField *number;
@property (weak, nonatomic) IBOutlet UITextField *wechat;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (strong,nonatomic) Contact *reccont;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupContext];
}


- (IBAction)cancel:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    NSString *name = self.name.text;
    NSString *phone = self.phone.text;
    NSString *number = self.number.text;
    NSString *qq = self.qq.text;
    NSString *wechat = self.wechat.text;
    NSString *email = self.email.text;
    NSArray<Contact*> *items = [[NSArray alloc]init];
    
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
    
    items = [user.contact allObjects];
    
    Contact *contact = [NSEntityDescription insertNewObjectForEntityForName:@"Contact" inManagedObjectContext:self.context];
    contact.name = name;
    contact.phone = phone;
    contact.qq = qq;
    contact.number = number;
    contact.wechat = wechat;
    contact.user = user;
    contact.email = email;
    contact.contid =[NSString stringWithFormat:@"%d",(int)(items.count)];
    contact.icon = @"user.png";
    
    self.reccont = contact;
    [self.context save:&error];
    if (!error) {
        [self.view endEditing:YES];
        [self postNotification];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        NSLog(@"%@",error);
    }
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
@end
