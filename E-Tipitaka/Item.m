//
//  Item.m
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Item.h"
#import "Content.h"


@implementation Item
@dynamic begin;
@dynamic number;
@dynamic section;
@dynamic sut;
@dynamic content;
@dynamic bookmarks;


- (void)addBookmarksObject:(NSManagedObject *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"bookmarks" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"bookmarks"] addObject:value];
    [self didChangeValueForKey:@"bookmarks" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeBookmarksObject:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"bookmarks" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"bookmarks"] removeObject:value];
    [self didChangeValueForKey:@"bookmarks" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addBookmarks:(NSSet *)value {    
    [self willChangeValueForKey:@"bookmarks" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"bookmarks"] unionSet:value];
    [self didChangeValueForKey:@"bookmarks" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeBookmarks:(NSSet *)value {
    [self willChangeValueForKey:@"bookmarks" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"bookmarks"] minusSet:value];
    [self didChangeValueForKey:@"bookmarks" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
