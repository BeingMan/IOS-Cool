//
//  Contact+CoreDataProperties.h
//  Final
//
//  Created by ybc on 2019/6/6.
//  Copyright © 2019 ybc. All rights reserved.
//
//

#import "Contact+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Contact (CoreDataProperties)

+ (NSFetchRequest<Contact *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *contid;
@property (nullable, nonatomic, copy) NSString *email;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *number;
@property (nullable, nonatomic, copy) NSString *phone;
@property (nullable, nonatomic, copy) NSString *qq;
@property (nullable, nonatomic, copy) NSString *wechat;
@property (nullable, nonatomic, copy) NSString *icon;
@property (nullable, nonatomic, retain) User *user;

@end

NS_ASSUME_NONNULL_END
