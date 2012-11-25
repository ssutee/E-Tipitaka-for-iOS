//
//  History+Helper.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 11/25/55 BE.
//
//

#import "History.h"

@interface History (Helper)

+ (History *) historyWithKeywords:(NSString *)keywords lang:(NSString *)lang inManagedObjectContext:(NSManagedObjectContext *)context;

@end
