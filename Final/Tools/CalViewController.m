//
//  CalViewController.m
//  Final
//
//  Created by ybc on 2019/6/10.
//  Copyright © 2019 ybc. All rights reserved.
//

#import "CalViewController.h"

@interface CalViewController ()
@property (weak, nonatomic) IBOutlet UILabel *screen;
- (IBAction)clean:(id)sender;
- (IBAction)change:(id)sender;
- (IBAction)percent:(id)sender;
- (IBAction)div:(id)sender;
- (IBAction)mul:(id)sender;
- (IBAction)del:(id)sender;
- (IBAction)add:(id)sender;
- (IBAction)result:(id)sender;
- (IBAction)dot:(id)sender;
- (IBAction)zero:(id)sender;
- (IBAction)one:(id)sender;
- (IBAction)two:(id)sender;
- (IBAction)three:(id)sender;
- (IBAction)four:(id)sender;
- (IBAction)five:(id)sender;
- (IBAction)six:(id)sender;
- (IBAction)seven:(id)sender;
- (IBAction)eight:(id)sender;
- (IBAction)nine:(id)sender;
@property double num1;
@property double num2;
@property Boolean isDo;
@property BOOL flag;
@property BOOL error;
@property NSMutableString *calculatePattern;
@property NSMutableString *calculateShowPattern;
@property NSMutableArray  *operators;
@end

@implementation CalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.screen.layer.borderColor=[UIColor grayColor].CGColor;
    self.screen.layer.borderWidth=1.0;
    self.screen.layer.cornerRadius=5.0;
    [self initData];
    
}
-(void)initData{
    self.num1 = 0;
    self.num2 = 0;
    self.isDo = false;
    self.screen.text =[NSString stringWithFormat:@"%d",0];
    _flag = YES;
    _error = NO;
    _operators = [NSMutableArray array];
    _calculatePattern = [[NSMutableString alloc]init];
    
}
- (IBAction)clean:(id)sender {
    [self initData];
}

- (IBAction)change:(id)sender {
    [_calculatePattern insertString:@"-" atIndex:0];
    self.screen.text = [self.calculatePattern mutableCopy];
    
}

- (IBAction)percent:(id)sender {
    double number = [[_calculatePattern copy] doubleValue];
    self.screen.text = [NSString stringWithFormat:@"%0.2f", number/100];
    _calculatePattern =[self.screen.text mutableCopy];
}

- (IBAction)div:(id)sender {
    [self.calculatePattern appendString:@"/"];
    self.screen.text = [self.calculatePattern mutableCopy];
}

- (IBAction)mul:(id)sender {
    [self.calculatePattern appendString:@"*"];
    self.screen.text = [self.calculatePattern mutableCopy];
}

- (IBAction)del:(id)sender {
    [self.calculatePattern appendString:@"-"];
    self.screen.text = [self.calculatePattern mutableCopy];
}

- (IBAction)add:(id)sender {
    [self.calculatePattern appendString:@"+"];
    self.screen.text = [self.calculatePattern mutableCopy];
}

- (IBAction)result:(id)sender {
    NSString *result = [self calculatePattern:[self scanPattern:_calculatePattern]];
    _flag = YES;
    if(_error) {
        self.screen.text = [NSString stringWithFormat:@"%@", @"您的输入有误"];
        _error = NO;
    }else {
        double res = [result doubleValue];
        result =[self formatFloat:res];
        self.screen.text = result;
        self.calculatePattern = [result mutableCopy];
    }
    return;
}

- (IBAction)dot:(id)sender {
    [self.calculatePattern appendString:@"."];
    self.screen.text = [self.calculatePattern mutableCopy];
}

- (IBAction)zero:(id)sender {
    [self.calculatePattern appendString:@"0"];
    self.screen.text = [self.calculatePattern mutableCopy];
}

- (IBAction)one:(id)sender {
    [self.calculatePattern appendString:@"1"];
    self.screen.text = [self.calculatePattern mutableCopy];
}

- (IBAction)two:(id)sender {
    [self.calculatePattern appendString:@"2"];
    self.screen.text = [self.calculatePattern mutableCopy];
}

- (IBAction)three:(id)sender {
    [self.calculatePattern appendString:@"3"];
    self.screen.text = [self.calculatePattern mutableCopy];
}

- (IBAction)four:(id)sender {
    [self.calculatePattern appendString:@"4"];
    self.screen.text = [self.calculatePattern mutableCopy];
}

- (IBAction)five:(id)sender {
    [self.calculatePattern appendString:@"5"];
    self.screen.text = [self.calculatePattern mutableCopy];
}

- (IBAction)six:(id)sender {
    [self.calculatePattern appendString:@"6"];
    self.screen.text = [self.calculatePattern mutableCopy];
}

- (IBAction)seven:(id)sender {
    [self.calculatePattern appendString:@"7"];
    self.screen.text = [self.calculatePattern mutableCopy];
}

- (IBAction)eight:(id)sender {
    [self.calculatePattern appendString:@"8"];
    self.screen.text = [self.calculatePattern mutableCopy];
}

- (IBAction)nine:(id)sender {
    [self.calculatePattern appendString:@"9"];
    self.screen.text = [self.calculatePattern mutableCopy];
}

//扫描算术表达式.完成中缀转后缀的功能
- (NSArray *)scanPattern:(NSString *)pattern {
    NSUInteger header = 0;
    NSMutableString *middleData = [NSMutableString stringWithFormat:@""];
    NSMutableArray *middleArray = [NSMutableArray array];
    
    for (; header < pattern.length; header++) {
        unichar letter = [pattern characterAtIndex:header];
        NSLog(@"%d", letter);
        if ((letter >= 48 && letter <= 57) || letter == 46) {
            char ch = (char)letter;
            [middleData appendFormat:@"%c", ch];
        }else {
            if ([middleData length] <= 0) {
                _error = YES;
                break;
            }
            [middleArray addObject:[middleData copy]];
            char ch = (char)letter;
            NSString *character = [NSString stringWithFormat:@"%c", ch];
            
            BOOL isHighLevel = (ch == '/' || ch == '*' || ch == '%');
            
            if([_operators count] == 0) {
                [_operators addObject:character];
            } else if(isHighLevel && ([[_operators lastObject] isEqualToString:@"+"] || [[_operators lastObject] isEqualToString:@"-"])) {
                [_operators addObject:character];
            }else {
                [middleData appendString:[_operators lastObject]];
                [middleArray addObject:[_operators lastObject]];
                [_operators removeLastObject];
                [_operators addObject:character];
            }
            NSRange range = NSMakeRange(0, [middleData length]);
            [middleData deleteCharactersInRange:range];
        }
    }
    [middleArray addObject:[middleData copy]];
    
    while ([_operators count]) {
        [middleArray addObject:[_operators lastObject]];
        [_operators removeLastObject];
    }
    return [middleArray copy];
}

- (NSString *)calculatePattern:(NSArray *)pattern {
    NSMutableArray *intStack = [NSMutableArray array];
    double result=0;
    
    for (int i = 0; i < [pattern count]; i++) {
        NSString *letter = pattern[i];
        NSLog(@"%@", letter);
        NSString *string = [letter stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
        
        if (string.length == 0 || [string containsString:@"."]) {
            NSNumber *number = [NSNumber numberWithDouble:[letter doubleValue]];
            [intStack addObject:number];
        } else {
            NSNumber *topNum = [intStack lastObject];
            [intStack removeLastObject];
            
            NSNumber *secondNum = [intStack lastObject];
            [intStack removeLastObject];
            
            double top = [topNum doubleValue];
            double second = [secondNum doubleValue];
            
            switch([pattern[i] characterAtIndex:0])
            {
                case '*':
                    result = top * second;
                    break;
                case '/':
                    result = second / top;
                    break;
                case '+':
                    result = top + second;
                    break;
                case '-':
                    result = second - top;
                    break;
            }
            [intStack addObject:[NSNumber numberWithDouble:result]];
        }
    }
    NSNumber *finalResult = [intStack lastObject];
    [intStack removeLastObject];
    
    return [NSString stringWithFormat:@"%@", finalResult];
}

- (NSString *)formatFloat:(double)f
{
    if (fmodf(f, 1)==0) {//如果有一位小数点
        return [NSString stringWithFormat:@"%.0f",f];
    } else if (fmodf(f*10, 1)==0) {//如果有两位小数点
        return [NSString stringWithFormat:@"%.1f",f];
    } else {
        NSString *res =[NSString stringWithFormat:@"%.4f",f];
        if([res doubleValue] == 0){
            return @"0";
        }else{
            return res;
        }
    }
}

@end
