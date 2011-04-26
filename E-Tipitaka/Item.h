//
//  Item.h
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content;

@interface Item : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * begin;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSNumber * section;
@property (nonatomic, retain) NSNumber * sut;
@property (nonatomic, retain) Content * content;
@property (nonatomic, retain) NSSet* bookmarks;

- (void)addBookmarksObject:(NSManagedObject *)value;
- (void)removeBookmarksObject:(NSManagedObject *)value;
- (void)addBookmarks:(NSSet *)value;
- (void)removeBookmarks:(NSSet *)value;

@end
