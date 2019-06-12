//
//  Task+CoreDataProperties.h
//  Final
//
//  Created by ybc on 2019/6/4.
//  Copyright © 2019 ybc. All rights reserved.
//
//

#import "Task+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Task (CoreDataProperties)

+ (NSFetchRequest<Task *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *completed;
@property (nullable, nonatomic, copy) NSString *con1;
@property (nullable, nonatomic, copy) NSString *con2;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSDate *time;
@property (nullable, nonatomic, copy) NSString *taskid;
@property (nullable, nonatomic, retain) User *user;

@end

NS_ASSUME_NONNULL_END
