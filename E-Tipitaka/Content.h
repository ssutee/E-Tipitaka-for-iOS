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

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * volume;
@property (nonatomic, retain) NSString * lang;
@property (nonatomic, retain) NSNumber * page;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) NSSet *histories;
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
