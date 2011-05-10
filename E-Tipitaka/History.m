//
//  History.m
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "History.h"
#import "Content.h"


@implementation History
@dynamic keywords;
@dynamic contents;
@dynamic lang;

- (void)addContentsObject:(Content *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"contents" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"contents"] addObject:value];
    [self didChangeValueForKey:@"contents" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeContentsObject:(Content *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"contents" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"contents"] removeObject:value];
    [self didChangeValueForKey:@"contents" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addContents:(NSSet *)value {    
    [self willChangeValueForKey:@"contents" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"contents"] unionSet:value];
    [self didChangeValueForKey:@"contents" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeContents:(NSSet *)value {
    [self willChangeValueForKey:@"contents" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"contents"] minusSet:value];
    [self didChangeValueForKey:@"contents" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
