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

@property (nonatomic, strong) NSDate * created;
@property (nonatomic, strong) NSNumber * important;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSNumber * order;
@property (nonatomic, strong) Item *item;

@end
