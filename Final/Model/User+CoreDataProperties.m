//
//  User+CoreDataProperties.m
//  Final
//
//  Created by ybc on 2019/6/4.
//  Copyright © 2019 ybc. All rights reserved.
//
//

#import "User+CoreDataProperties.h"

@implementation User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"User"];
}

@dynamic email;
@dynamic name;
@dynamic password;
@dynamic phone;
@dynamic contact;
@dynamic task;

@end
