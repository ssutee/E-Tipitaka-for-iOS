//
//  Content+Helper.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 11/25/55 BE.
//
//

#import "Content.h"

@interface Content (Helper)

+ (Content *)getContentWithLang:(NSString *)lang volume:(NSNumber *)volume page:(NSNumber *)page inManagedObjectContext:(NSManagedObjectContext *)context;

@end
