//
//  Item+Helper.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 11/24/55 BE.
//
//

#import "Item.h"

@interface Item (Helper)

+ (Item *)itemWithSection:(NSNumber *)section number:(NSNumber *)number volume:(NSNumber *)volume lang:(NSString *)lang inManagedObjectContext:(NSManagedObjectContext *)context;

@end
