//
//  History.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 5/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content;

@interface History : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * lang;
@property (nonatomic, retain) NSString * keywords;
@property (nonatomic, retain) NSNumber * star;
@property (nonatomic, retain) NSNumber * state;
@property (nonatomic, retain) NSSet* contents;

- (void)addContentsObject:(Content *)value;
- (void)removeContentsObject:(Content *)value;
- (void)addContents:(NSSet *)value;
- (void)removeContents:(NSSet *)value;

@end
