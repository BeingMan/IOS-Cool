//
//  Check.h
//  Final
//
//  Created by ybc on 2019/5/29.
//  Copyright © 2019 ybc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Check : NSObject

+(BOOL)validateEmail:(NSString *)email;
+(BOOL)validateMobile:(NSString *)phone;
@end

NS_ASSUME_NONNULL_END
