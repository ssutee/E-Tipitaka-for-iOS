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

+ (Bookmark *)bookmarkWithItem:(Item *)item text:(NSString *)text inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Bookmark"];
    request.predicate = [NSPredicate predicateWithFormat:@"item = %@ AND text = %@", item, text];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    Bookmark *bookmark = nil;
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    } else if (results.count > 1) {
        NSLog(@"Duplicated Bookmark");
        bookmark = results.lastObject;
    } else if (results.count == 0) {
        bookmark = [NSEntityDescription insertNewObjectForEntityForName:@"Bookmark" inManagedObjectContext:context];
        bookmark.item = item;
    } else {
        bookmark = results.lastObject;
    }
    return bookmark;
}

+ (NSArray *)bookmarksWithoutOrderInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Bookmark"];
    request.predicate = [NSPredicate predicateWithFormat:@"order = nil OR order = 0"];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];    
    return results;
}

@end
