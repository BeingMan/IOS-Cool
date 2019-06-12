//
//  Contact+CoreDataProperties.m
//  Final
//
//  Created by ybc on 2019/6/6.
//  Copyright © 2019 ybc. All rights reserved.
//
//

#import "Contact+CoreDataProperties.h"

@implementation Contact (CoreDataProperties)

+ (NSFetchRequest<Contact *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Contact"];
}

@dynamic contid;
@dynamic email;
@dynamic name;
@dynamic number;
@dynamic phone;
@dynamic qq;
@dynamic wechat;
@dynamic icon;
@dynamic user;

@end
