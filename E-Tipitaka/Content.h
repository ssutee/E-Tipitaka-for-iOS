//
//  Content.h
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class History, Item;

@interface Content : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * lang;
@property (nonatomic, retain) NSNumber * page;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * volume;
@property (nonatomic, retain) NSSet* items;
@property (nonatomic, retain) NSSet* histories;

- (void)addHistoriesObject:(History *)value;
- (void)removeHistoriesObject:(History *)value;

@end
