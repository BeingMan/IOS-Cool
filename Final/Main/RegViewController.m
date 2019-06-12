//
//  RegViewController.m
//  Final
//
//  Created by ybc on 2019/6/3.
//  Copyright © 2019 ybc. All rights reserved.
//

#import "RegViewController.h"
#import <CoreData/CoreData.h>
#import "User+CoreDataClass.h"
#import "Check.h"

@interface RegViewController ()
@property(strong,nonatomic)NSManagedObjectContext *context;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password1;
@property (weak, nonatomic) IBOutlet UITextField *password2;
- (IBAction)cancel:(id)sender;
- (IBAction)certain:(id)sender;

@end

@implementation RegViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContext];
    [self.password1 setSecureTextEntry:YES];
    [self.password2 setSecureTextEntry:YES];
}


- (IBAction)cancel:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)certain:(id)sender {
    NSString *name = self.name.text;
    NSString *phone = self.phone.text;
    NSString *email = self.email.text;
    NSString *password1 = self.password1.text;
    NSString *password2 = self.password2.text;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSError *error = nil;
    
    if (!name.length||!password1.length || !phone.length || !email.length || !password2) {
        [self alertViewWithTitle:@"提示" message:@"信息不能为空！"CertainButtonTitle:@"确定"];
        return;
    }else if(![Check validateMobile:phone]){
        [self alertViewWithTitle:@"提示" message:@"请输入正确手机号！"CertainButtonTitle:@"确定"];
        return;
    }else if(![Check validateEmail:email]){
        [self alertViewWithTitle:@"提示" message:@"请输入正确邮箱！"CertainButtonTitle:@"确定"];
        return;
    }else if(password1!=password2){
        [self alertViewWithTitle:@"提示" message:@"密码不一致，请重新填写！"CertainButtonTitle:@"确定"];
        return;
    };
    
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@",name];
    NSArray *users = [self.context executeFetchRequest:request error:&error];
    if (!error ) {
        if(users.count>0){
            [self alertViewWithTitle:@"提示" message:@"用户名已存在，请重新填写" CertainButtonTitle:@"确定"];
            return;
        }
    }
    request.predicate = [NSPredicate predicateWithFormat:@"phone = %@",phone];
    users = [self.context executeFetchRequest:request error:&error];
    if (!error ) {
        if(users.count>0){
            [self alertViewWithTitle:@"提示" message:@"手机号已存在，请重新填写" CertainButtonTitle:@"确定"];
            return;
        }
    }
    request.predicate = [NSPredicate predicateWithFormat:@"email = %@",email];
    users = [self.context executeFetchRequest:request error:&error];
    if (!error ) {
        if(users.count>0){
            [self alertViewWithTitle:@"提示" message:@"邮箱已存在，请重新填写" CertainButtonTitle:@"确定"];
            return;
        }
    }
    
    User *user = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:self.context];
    user.name = name;
    user.phone = phone;
    user.email = email;
    user.password = password1;
    
    [self.context save:&error];
    if (!error) {
        [self.view endEditing:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        NSLog(@"%@",error);
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
@end
