//
//  Bookmark.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 12/3/2013.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Item;

@interface Bookmark : NSManagedObject

@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * important;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) Item *item;

@end
