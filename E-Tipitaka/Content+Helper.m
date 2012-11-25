//
//  Content+Helper.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 11/25/55 BE.
//
//

#import "Content+Helper.h"

@implementation Content (Helper)

+ (Content *)getContentWithLang:(NSString *)lang volume:(NSNumber *)volume page:(NSNumber *)page inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Content"];
    request.predicate = [NSPredicate predicateWithFormat:@"lang = %@ AND volume = %@ AND page = %@", lang, volume, page];
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    Content *content = nil;
    if (error || results.count > 1) {
        NSLog(@"%@", error.localizedDescription);
    } else if (results.count == 1) {
        content = results.lastObject;
    }
    return content;
}

@end
