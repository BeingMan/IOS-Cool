//
//  Task+CoreDataProperties.m
//  Final
//
//  Created by ybc on 2019/6/4.
//  Copyright © 2019 ybc. All rights reserved.
//
//

#import "Task+CoreDataProperties.h"

@implementation Task (CoreDataProperties)

+ (NSFetchRequest<Task *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"Task"];
}

@dynamic completed;
@dynamic con1;
@dynamic con2;
@dynamic name;
@dynamic time;
@dynamic taskid;
@dynamic user;

@end
