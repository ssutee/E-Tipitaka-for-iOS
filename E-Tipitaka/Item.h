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

@property (nonatomic, strong) NSNumber * begin;
@property (nonatomic, strong) NSNumber * number;
@property (nonatomic, strong) NSNumber * section;
@property (nonatomic, strong) NSNumber * sut;
@property (nonatomic, strong) Content *content;
@property (nonatomic, strong) NSSet *bookmarks;
@end

@interface Item (CoreDataGeneratedAccessors)

- (void)addBookmarksObject:(Bookmark *)value;
- (void)removeBookmarksObject:(Bookmark *)value;
- (void)addBookmarks:(NSSet *)values;
- (void)removeBookmarks:(NSSet *)values;
@end
