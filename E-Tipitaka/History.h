//
//  History.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 3/27/55 BE.
//  Copyright (c) 2555 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content;

@interface History : NSManagedObject

@property (nonatomic, retain) NSString * detail;
@property (nonatomic, retain) NSNumber * star;
@property (nonatomic, retain) NSString * lang;
@property (nonatomic, retain) NSString * keywords;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSData * selected;
@property (nonatomic, retain) NSSet *contents;
@end

@interface History (CoreDataGeneratedAccessors)

- (void)addContentsObject:(Content *)value;
- (void)removeContentsObject:(Content *)value;
- (void)addContents:(NSSet *)values;
- (void)removeContents:(NSSet *)values;
@end
