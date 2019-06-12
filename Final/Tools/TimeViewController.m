//
//  TimeViewController.m
//  Final
//
//  Created by ybc on 2019/6/7.
//  Copyright © 2019 ybc. All rights reserved.
//

#import "TimeViewController.h"

@interface TimeViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *datapicker;
@property (weak, nonatomic) IBOutlet UIButton *btn_start;
- (IBAction)click:(id)sender;

@end

@implementation TimeViewController
NSTimer *timer;
NSTimeInterval lefttime;

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


- (IBAction)click:(id)sender {
    lefttime = self.datapicker.countDownDuration;
    self.datapicker.userInteractionEnabled = NO;
    [sender setEnabled:NO ];
    NSString *message = [NSString stringWithFormat:@"剩余时间：%f秒",lefttime];
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"开始倒计时" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *certain = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertC addAction:certain];
    [self presentViewController:alertC animated:YES completion:nil];
    timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(tickDown) userInfo:nil repeats:YES];
}

-(void) tickDown{
    lefttime -=60;
    self.datapicker.countDownDuration = lefttime;
    if(lefttime<=0){
        [timer invalidate];
        self.datapicker.userInteractionEnabled = YES;
        self.btn_start.enabled = YES;
    }
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"倒计时结束！" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *certain = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertC addAction:certain];
    [self presentViewController:alertC animated:YES completion:nil];
}
@end
