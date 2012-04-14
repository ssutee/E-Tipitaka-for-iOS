//
//  Item.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 3/27/55 BE.
//  Copyright (c) 2555 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Bookmark, Content;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSNumber * begin;
@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSNumber * section;
@property (nonatomic, retain) NSNumber * sut;
@property (nonatomic, retain) Content *content;
@property (nonatomic, retain) NSSet *bookmarks;
@end

@interface Item (CoreDataGeneratedAccessors)

- (void)addBookmarksObject:(Bookmark *)value;
- (void)removeBookmarksObject:(Bookmark *)value;
- (void)addBookmarks:(NSSet *)values;
- (void)removeBookmarks:(NSSet *)values;
@end
