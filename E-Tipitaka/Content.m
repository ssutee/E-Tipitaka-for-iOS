//
//  Content.m
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Content.h"
#import "History.h"
#import "Item.h"


@implementation Content
@dynamic lang;
@dynamic page;
@dynamic text;
@dynamic volume;
@dynamic items;
@dynamic histories;

- (void)addItemsObject:(Item *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"items" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"items"] addObject:value];
    [self didChangeValueForKey:@"items" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeItemsObject:(Item *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"items" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"items"] removeObject:value];
    [self didChangeValueForKey:@"items" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addItems:(NSSet *)value {    
    [self willChangeValueForKey:@"items" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"items"] unionSet:value];
    [self didChangeValueForKey:@"items" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeItems:(NSSet *)value {
    [self willChangeValueForKey:@"items" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"items"] minusSet:value];
    [self didChangeValueForKey:@"items" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addHistoriesObject:(History *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"histories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"histories"] addObject:value];
    [self didChangeValueForKey:@"histories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeHistoriesObject:(History *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"histories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"histories"] removeObject:value];
    [self didChangeValueForKey:@"histories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addHistories:(NSSet *)value {    
    [self willChangeValueForKey:@"histories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"histories"] unionSet:value];
    [self didChangeValueForKey:@"histories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeHistories:(NSSet *)value {
    [self willChangeValueForKey:@"histories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"histories"] minusSet:value];
    [self didChangeValueForKey:@"histories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
