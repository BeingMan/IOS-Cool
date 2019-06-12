//
//  User+CoreDataProperties.h
//  Final
//
//  Created by ybc on 2019/6/4.
//  Copyright © 2019 ybc. All rights reserved.
//
//

#import "User+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface User (CoreDataProperties)

+ (NSFetchRequest<User *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *email;
@property (nullable, nonatomic, copy) NSString *name;
@property (nullable, nonatomic, copy) NSString *password;
@property (nullable, nonatomic, copy) NSString *phone;
@property (nullable, nonatomic, retain) NSSet<Contact *> *contact;
@property (nullable, nonatomic, retain) NSSet<Task *> *task;

@end

@interface User (CoreDataGeneratedAccessors)

- (void)addContactObject:(Contact *)value;
- (void)removeContactObject:(Contact *)value;
- (void)addContact:(NSSet<Contact *> *)values;
- (void)removeContact:(NSSet<Contact *> *)values;

- (void)addTaskObject:(Task *)value;
- (void)removeTaskObject:(Task *)value;
- (void)addTask:(NSSet<Task *> *)values;
- (void)removeTask:(NSSet<Task *> *)values;

@end

NS_ASSUME_NONNULL_END
