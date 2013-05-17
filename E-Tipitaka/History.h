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

@property (nonatomic, strong) NSString * detail;
@property (nonatomic, strong) NSNumber * star;
@property (nonatomic, strong) NSString * lang;
@property (nonatomic, strong) NSString * keywords;
@property (nonatomic, strong) NSDate * created;
@property (nonatomic, strong) NSNumber * state;
@property (nonatomic, strong) NSData * selected;
@property (nonatomic, strong) NSData * read;
@property (nonatomic, strong) NSSet *contents;
@end

@interface History (CoreDataGeneratedAccessors)

- (void)addContentsObject:(Content *)value;
- (void)removeContentsObject:(Content *)value;
- (void)addContents:(NSSet *)values;
- (void)removeContents:(NSSet *)values;
@end
