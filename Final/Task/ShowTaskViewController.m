//
//  ShowTaskViewController.m
//  Final
//
//  Created by ybc on 2019/6/5.
//  Copyright © 2019 ybc. All rights reserved.
//

#import "ShowTaskViewController.h"
#import "PCDatePickerView.h"
@interface ShowTaskViewController ()
@property (weak, nonatomic) IBOutlet UITextField *tit;
@property (weak, nonatomic) IBOutlet UITextField *con1;
@property (weak, nonatomic) IBOutlet UITextView *con2;
@property (weak, nonatomic) IBOutlet UITextField *dt;

@end

@implementation ShowTaskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.con2.layer.borderColor=[UIColor grayColor].CGColor;
    self.con2.layer.borderWidth=1.0;
    self.con2.layer.cornerRadius=5.0;
    self.con1.layer.borderColor=[UIColor grayColor].CGColor;
    self.con1.layer.borderWidth=1.0;
    self.con1.layer.cornerRadius=5.0;
    self.tit.layer.borderColor=[UIColor grayColor].CGColor;
    self.tit.layer.borderWidth=1.0;
    self.tit.layer.cornerRadius=5.0;
    self.dt.layer.borderColor=[UIColor grayColor].CGColor;
    self.dt.layer.borderWidth=1.0;
    self.dt.layer.cornerRadius=5.0;
    self.dt.enabled = false;
    
    self.tit.text = self.rectask.name;
    self.con1.text = self.rectask.con1;
    self.con2.text = self.rectask.con2;
    [self sureDatePickerView:self.rectask.time];
}

- (void)sureDatePickerView:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    self.dt.text =strDate;
}
@end
