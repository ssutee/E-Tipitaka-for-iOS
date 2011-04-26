//
//  History.h
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content;

@interface History : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * keywords;
@property (nonatomic, retain) NSSet* contents;

- (void)addContentsObject:(Content *)value;
- (void)removeContentsObject:(Content *)value;

@end
