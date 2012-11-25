//
//  Item+Helper.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 11/24/55 BE.
//
//

#import "Item+Helper.h"

@implementation Item (Helper)

+ (Item *)itemWithSection:(NSNumber *)section number:(NSNumber *)number volume:(NSNumber *)volume lang:(NSString *)lang inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Item"];
    request.predicate = [NSPredicate predicateWithFormat:@"section = %@ AND number = %@ AND content.volume = %@ AND content.lang = %@", section, number, volume, lang];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (!error && results.count > 0) {
        return results.lastObject;
    }
    return nil;
}

@end
