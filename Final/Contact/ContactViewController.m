//
//  ContactViewController.m
//  Final
//
//  Created by ybc on 2019/6/6.
//  Copyright © 2019 ybc. All rights reserved.
//

#import "ContactViewController.h"
#import "User+CoreDataClass.h"
#import "Contact+CoreDataClass.h"
#import <CoreData/CoreData.h>
#import "Check.h"
#import "ChineseString.h"
#import "EditContactViewController.h"
#import "ShowTableViewController.h"

#define FileName @"ybc.Final.plist"
#define UPDATE_INFO_NOTIFICATION @"updateInfo2"
#define EDITUPDATE_INFO_NOTIFICATION @"updateInfo3"

@interface ContactViewController () <UITableViewDataSource,UISearchBarDelegate>
@property(strong,nonatomic)NSManagedObjectContext *context;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;

@property (nonatomic, strong) NSArray *groups;
@property Contact* sendcont;
@property User *curUser;
@property NSMutableArray *listSection;
@property NSMutableArray *listPhone;
@property (nonatomic, strong) NSMutableArray *listfilterPhone;
-(void)handleSearchForTerm:(NSString *)searchTerm;

- (IBAction)addFriend:(id)sender;
@end

@implementation ContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupContext];
    [self addObserverToNotification];
    [self loadData];
}

-(void)loadData{
    [self setupContext];
    self.listSection = [[NSMutableArray alloc] init];
    self.listPhone =[[NSMutableArray alloc] init];
    User *user = [self findCurUser];
    NSArray<Contact*> *friendArray = [user.contact allObjects];
    NSMutableArray * listPhoneShow = [[NSMutableArray alloc] init];
    //获取列表首字母，并排序
    self.listSection = [ChineseString IndexArray:friendArray];
    //把通讯录对象按照首字母进行分组排序
    listPhoneShow = [ChineseString LetterSortArray:friendArray];
    //把对应的同一个首字母下联系人对象按照首字母排序列表进行分组；
    NSInteger count = [listPhoneShow count];
    NSArray * array = nil;
 
    for(int i =0;i<count;i++){
        array =[listPhoneShow objectAtIndex:i];
        NSInteger arrCount = [array count];
        NSMutableArray * showArr = [[NSMutableArray alloc] init];
        
        for(int j =0;j< arrCount;j++){
            
            NSString *tempStr = [array objectAtIndex:j];
            
            for(Contact * add in friendArray){
                
                if([[add name] isEqualToString:tempStr]){
                    [showArr addObject:add];
                    break;
                }
                
            }
            
        }
        [self.listPhone addObject:showArr];
    }
}

#pragma mark - 数据源方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.searchbar.text.length ==0){
        return self.listSection.count;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.searchbar.text.length ==0){
        NSMutableArray * showArr = self.listPhone[section];
        return showArr.count;
    }else{
        return self.listfilterPhone.count;
    }
    
}

- (NSMutableArray *)listfilterPhone
{
    if(!_listfilterPhone){
        _listfilterPhone = [NSMutableArray array];
    }
    return _listfilterPhone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1.定义一个循环标识
    static NSString *ID = @"friend";
    
    // 2.从缓存池中取出可循环利用cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    // 3.缓存池中没有可循环利用的cell
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    // 4.设置数据
    if(self.searchbar.text.length ==0){
        NSMutableArray *showArr = self.listPhone[indexPath.section];
        Contact *friend = showArr[indexPath.row];
        
        cell.imageView.image = [UIImage imageNamed:friend.icon];
        cell.textLabel.text = friend.name;
    }else{
        Contact *friend  = self.listfilterPhone[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:friend.icon];
        cell.textLabel.text = friend.name;
    }
    
    return cell;
}

/**
 *  第section组显示的头部标题
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if(self.searchbar.text.length ==0){
        return self.listSection[section];
    }else{
        return nil;
    }
}

/**
 *  返回右边索引条显示的字符串数据
 */
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.listSection copy];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self handleSearchForTerm:searchText];
}

- (void)handleSearchForTerm:(NSString *)searchTerm
{
    if(self.searchbar.text.length == 0){
        [self.tableview reloadData];
    }else{
        [self.listfilterPhone removeAllObjects];
        for (NSMutableArray *items in self.listPhone) {
            for(Contact * item in items){
                NSString *str1 = [item.name uppercaseString];
                NSString *str2 = [searchTerm uppercaseString];
                if([str1 containsString:str2]){
                    [self.listfilterPhone addObject:item];
                }
            }
        }
        [self.tableview reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchbar resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.sendcont = [self findContWithId:[self.listPhone[indexPath.section][indexPath.row] contid]];
    [self performSegueWithIdentifier:@"showCont" sender:self];
}

- ( UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UIContextualAction *editRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"编辑" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {

            self.sendcont = [self findContWithId:[self.listPhone[indexPath.section][indexPath.row] contid]];

        [self performSegueWithIdentifier:@"editCont" sender:self];
    }];
    editRowAction.image = [UIImage imageNamed:@"编辑"];
    editRowAction.backgroundColor = [UIColor grayColor];
    
    UIContextualAction *deleteRowAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
        
        [self delFriendWithId:[self.listPhone[indexPath.section][indexPath.row] contid]];
        [self loadData];
        completionHandler (YES);
        [self.tableview reloadData];
    }];
    deleteRowAction.image = [UIImage imageNamed:@"删除"];
    deleteRowAction.backgroundColor = [UIColor redColor];
    
    UISwipeActionsConfiguration *config = [UISwipeActionsConfiguration configurationWithActions:@[deleteRowAction,editRowAction]];
    return config;
}

-(void)delFriendWithId:(NSString *)friendid{
    User *user = [self findCurUser];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
    
    NSError *error = nil;
    NSArray *friends = [self.context executeFetchRequest:request error:&error];
    if (!error) {
        for (Contact *cont in friends) {
            if(cont.user == user){
                if([cont.contid intValue]== [friendid intValue]){
                    [self.context deleteObject:cont];
                }else if([cont.contid intValue] > [friendid intValue]){
                    cont.contid = [NSString stringWithFormat:@"%d",(int)([cont.contid intValue]-1)];
                }
            }
        }
    }else{
        NSLog(@"%@",error);
    }
    [self.context save:nil];
}

-(void)addObserverToNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfo:) name:UPDATE_INFO_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInfo:) name:EDITUPDATE_INFO_NOTIFICATION object:nil];
}

-(void)updateInfo:(NSNotification *)notification{
    [self loadData];
    [self.tableview reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editCont"]) {
        UIViewController *vc = segue.destinationViewController;
        [vc setValue:self.sendcont forKey:@"reccont"];
    }else if ([segue.identifier isEqualToString:@"showCont"]) {
        UITableViewController *vc = segue.destinationViewController;
        [vc setValue:self.sendcont forKey:@"reccont"];
    }
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
- (IBAction)addFriend:(id)sender {
}
@end
