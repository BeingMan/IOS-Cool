//
//  ViewController.m
//  Final
//
//  Created by ybc on 2019/5/28.
//  Copyright © 2019 ybc. All rights reserved.
//

#import "MainViewController.h"
#import <CoreData/CoreData.h>
#import "User+CoreDataClass.h"
#import "Check.h"
#define FileName @"ybc.Final.plist"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (nonatomic,strong) NSTimer *timer;//轮播定时器
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UISwitch *rememberSwitch;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property(strong,nonatomic)NSManagedObjectContext *context;
@property(weak,nonatomic) NSString *sendUser;
- (IBAction)login:(id)sender;
- (IBAction)showPassword:(id)sender;

@end

@implementation ViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupContext];

    //设置轮播图
    int count = 5;
    CGFloat imageY = 0;
    CGFloat imageW = self.scrollView.frame.size.width;
    CGFloat imageH = self.scrollView.frame.size.height;
    for (int i = 0; i<count; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        CGFloat imageX = i * imageW;
        imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
        NSString *imageName = [NSString stringWithFormat:@"img_0%d",i+1];
        imageView.image = [UIImage imageNamed:imageName];
        [self.scrollView addSubview:imageView];
    }
    CGFloat contentW = count * imageW;
    self.scrollView.contentSize = CGSizeMake(contentW, 0);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.pageControl.numberOfPages = count;
    self.scrollView.pagingEnabled = YES;
    [self addTimer];
    
    //键盘监听事件
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.passwordField setSecureTextEntry:YES];
    
    // 判断是否存在保存偏好设置的文件
    NSFileManager *manager=[NSFileManager defaultManager];
    if ([manager fileExistsAtPath:[self filePath]]) {
        // 创建NSUserDefaults实例对象
        NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
        NSString *name=[user objectForKey:@"Name"];
        NSString *password=[user objectForKey:@"Password"];
        BOOL remember=[[user objectForKey:@"isRemember"]boolValue];
        
        // 显示到界面中
        self.nameField.text=name;
        if (remember) {
            self.passwordField.text=password;
        }
        [self.rememberSwitch setOn:remember];
        
    }
}

//添加定时器方法
- (void)addTimer{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
//移除定时器
- (void)removeTimer{
    [self.timer invalidate];
    self.timer = nil;
}

// 定时器调用的方法
- (void)nextImage{
    // 图片的总数
    int count = 5;
    // 增加pageControl的页码
    NSInteger page = 0;
    if (self.pageControl.currentPage == count - 1) {
        page = 0;
    } else {
        page = self.pageControl.currentPage + 1;
    }
    // 计算scrollView滚动的位置
    CGFloat offsetX = page * self.scrollView.frame.size.width;
    CGPoint offset = CGPointMake(offsetX, 0);
    [self.scrollView setContentOffset:offset animated:YES];
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

-(void)dealloc{
    // 移除通知监听器
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

// 按回车键，切换文本框的输入焦点
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nameField) {
        [self.passwordField becomeFirstResponder];
    }
    return YES;
}

// 获取路径FileName文件的路径的方法
-(NSString *)filePath
{
    NSArray *array = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [array objectAtIndex:0];
    NSString *finalPath = [path stringByAppendingPathComponent:@"Preferences"];
    return [finalPath stringByAppendingPathComponent:FileName];
}

#pragma mark - UIScrollViewDelegate方法
/**
 *  当scrollView正在滚动就会调用
 */
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // 根据scrollView的滚动位置决定pageControl显示第几页
    CGFloat scrollW = scrollView.frame.size.width;
    int page = (scrollView.contentOffset.x + scrollW * 0.5) / scrollW;
    self.pageControl.currentPage = page;
}
//开始拖拽的时候调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self removeTimer];
}
//停止拖拽的时候调用方法
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self addTimer];
}


- (IBAction)login:(id)sender {
    NSString *name=self.nameField.text;
    NSString *password=self.passwordField.text;
    NSNumber *remember=[NSNumber numberWithBool:self.rememberSwitch.on];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    NSError *error = nil;
    
    if (!name.length||!password.length) {
        [self alertViewWithTitle:@"提示" message:@"账号和密码不能为空！"CertainButtonTitle:@"确定"];
        return;
    }else if([Check validateMobile:name]){
        request.predicate = [NSPredicate predicateWithFormat:@"phone = %@",name];
        NSArray *users = [self.context executeFetchRequest:request error:&error];
        if (!error ) {
            if(users.count<=0){
                [self alertViewWithTitle:@"提示" message:@"账号不存在，请重新填写" CertainButtonTitle:@"确定"];
                return;
            }else{
                for(User *user in users){
                    if (password != user.password) {
                        [self alertViewWithTitle:@"提示" message:@"密码错误" CertainButtonTitle:@"确定"];
                        return;
                    }
                    self.sendUser =user.name;
                }
            }
            
        }else{
            NSLog(@"%@",error);
        }
    }else if([Check validateEmail:name]){
        request.predicate = [NSPredicate predicateWithFormat:@"email = %@",name];
        NSArray *users = [self.context executeFetchRequest:request error:&error];
        if (!error ) {
            if(users.count<=0){
                [self alertViewWithTitle:@"提示" message:@"账号不存在，请重新填写" CertainButtonTitle:@"确定"];
                return;
            }else{
                for(User *user in users){
                    if (password != user.password) {
                        [self alertViewWithTitle:@"提示" message:@"密码错误" CertainButtonTitle:@"确定"];
                        return;
                    }
                    self.sendUser =user.name;
                }
            }
        }else{
            NSLog(@"%@",error);
        }
    }else{
        [self alertViewWithTitle:@"提示" message:@"请输入正确的账号！"CertainButtonTitle:@"确定"];
        return;
    }
    
    // 创建NSUserDefaults对象，并保存数据
    NSUserDefaults *user=[NSUserDefaults standardUserDefaults];
    [user setObject:name forKey:@"Name"];
    [user setObject:password forKey:@"Password"];
    [user setObject:remember forKey:@"isRemember"];
    
    // 立即保存信息
    [user synchronize];
    [self performSegueWithIdentifier:@"login" sender:self];
}
//页面传值
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    UITabBarController *vc = segue.destinationViewController;
//    if ([vc respondsToSelector:@selector(setSendValue:)]) {
//        [vc setValue:self.sendUser forKey:@"sendValue"];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// 提示信息的方法
-(void)alertViewWithTitle:(NSString *)title message:(NSString *)message CertainButtonTitle:(NSString *)buttonTitle{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title  message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defult = [UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:defult];
    [self presentViewController:alert animated:YES completion:nil];
}

//切换密码显示状态
- (IBAction)showPassword:(id)sender {
    if(![sender isOn]){
        [self.passwordField setSecureTextEntry:YES];
    }else{
        [self.passwordField setSecureTextEntry:NO];
    }
}

//上下文 关联Company.xcdatamodeld 模型文件
- (void)setupContext{
    
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
@end
