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
@property (nonatomic, retain) NSString * lang;

- (void)addContentsObject:(Content *)value;
- (void)removeContentsObject:(Content *)value;

@end
