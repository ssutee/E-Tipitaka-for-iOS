//
//  Bookmark+Helper.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 11/24/55 BE.
//
//

#import "Bookmark.h"

@interface Bookmark (Helper)

+ (Bookmark *)bookmarkWithItem:(Item *)item inManagedObjectContext:(NSManagedObjectContext *)context;

@end
