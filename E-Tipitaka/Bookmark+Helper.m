//
//  Bookmark+Helper.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 11/24/55 BE.
//
//

#import "Bookmark+Helper.h"
#import "Item.h"

@implementation Bookmark (Helper)

+ (Bookmark *)bookmarkWithItem:(Item *)item inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Bookmark"];
    request.predicate = [NSPredicate predicateWithFormat:@"item = %@", item];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    Bookmark *bookmark = nil;
    if (error || results.count > 1) {
        NSLog(@"%@", error.localizedDescription);
    } else if (results.count == 0) {
        bookmark = [NSEntityDescription insertNewObjectForEntityForName:@"Bookmark" inManagedObjectContext:context];
        bookmark.item = item;
    } else {
        bookmark = results.lastObject;
    }
    return bookmark;
}

@end
