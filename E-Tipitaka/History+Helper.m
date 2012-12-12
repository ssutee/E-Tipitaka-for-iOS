//
//  History+Helper.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 11/25/55 BE.
//
//

#import "History+Helper.h"

@implementation History (Helper)

+ (History *) historyWithKeywords:(NSString *)keywords lang:(NSString *)lang inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"History"];
    request.predicate = [NSPredicate predicateWithFormat:@"keywords = %@ AND lang = %@", keywords, lang];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    History *history = nil;
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    } else if (results.count > 1)  {
        NSLog(@"Duplicated History");
        history = results.lastObject;
    } else if (results.count == 0) {
        history = [NSEntityDescription insertNewObjectForEntityForName:@"History" inManagedObjectContext:context];
        history.keywords = keywords;
        history.lang = lang;
    } else {
        history = results.lastObject;
    }
    return history;
}

@end
