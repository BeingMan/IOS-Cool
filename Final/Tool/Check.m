//
//  Check.m
//  Final
//
//  Created by ybc on 2019/5/29.
//  Copyright © 2019 ybc. All rights reserved.
//

#import "Check.h"

@implementation Check
//邮箱验证
+(BOOL) validateEmail:(NSString *)email

{
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
    
}
//手机号码验证
+(BOOL)validateMobile:(NSString *)phone{
    
    NSString *MOBILE = @"^1[34578]\\d{9}$";
    
    NSPredicate *regexTestMobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",MOBILE];
    
    if ([regexTestMobile evaluateWithObject:phone]) {
        
        return YES;
        
    }else {
        
        return NO;
    }
    
}
@end
