//
//  Bookmark.h
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface Bookmark : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Item * item;

@end
