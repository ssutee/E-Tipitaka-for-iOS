//
//  Content.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 3/27/55 BE.
//  Copyright (c) 2555 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class History, Item;

@interface Content : NSManagedObject

@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSNumber * volume;
@property (nonatomic, strong) NSString * lang;
@property (nonatomic, strong) NSNumber * page;
@property (nonatomic, strong) NSSet *items;
@property (nonatomic, strong) NSSet *histories;
@end

@interface Content (CoreDataGeneratedAccessors)

- (void)addItemsObject:(Item *)value;
- (void)removeItemsObject:(Item *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;
- (void)addHistoriesObject:(History *)value;
- (void)removeHistoriesObject:(History *)value;
- (void)addHistories:(NSSet *)values;
- (void)removeHistories:(NSSet *)values;
@end
