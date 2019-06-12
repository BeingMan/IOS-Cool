//
//  DataViewController.m
//  Final
//
//  Created by ybc on 2019/6/10.
//  Copyright © 2019 ybc. All rights reserved.
//

#import "DataViewController.h"
#import "Contact+CoreDataClass.h"
#import "User+CoreDataClass.h"
#import "Task+CoreDataClass.h"
#import <CoreData/CoreData.h>
#import "Check.h"

#define FileName @"ybc.Final.plist"

@interface DataViewController ()
@property(strong,nonatomic)NSManagedObjectContext *context;
@property (weak, nonatomic) IBOutlet UILabel *taskAll;
@property (weak, nonatomic) IBOutlet UILabel *taskSome;
@property (weak, nonatomic) IBOutlet UILabel *friendsAll;

@end

@implementation DataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContext];
    User *curUser = [self findCurUser];
    NSArray *arr =[curUser.contact allObjects];
    self.friendsAll.text =[NSString stringWithFormat:@"%d",(int)arr.count];
    arr = [curUser.task allObjects];
    self.taskAll.text =[NSString stringWithFormat:@"%d",(int)arr.count];
    int num=0;
    for(Task *task in arr){
        if([task.completed isEqualToString:@"0"]) num++;
    }
    self.taskSome.text =[NSString stringWithFormat:@"%d",num];
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
    [self.view endEditing:YES]; // 退出键盘
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
