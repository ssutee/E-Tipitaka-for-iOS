//
//  Bookmark.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 3/27/55 BE.
//  Copyright (c) 2555 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface Bookmark : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) Item *item;

@end
