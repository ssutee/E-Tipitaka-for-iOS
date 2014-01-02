//
//  ImportTool.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 2/1/14.
//
//

#import <Foundation/Foundation.h>

@interface ImportTool : NSObject

+ (BOOL)importDataFromFile:(NSString *)filePath bookmarksCount:(NSInteger *)bookmarksCount historiesCount:(NSInteger *)historiesCount inContext:(NSManagedObjectContext *)context;
+ (BOOL)importData:(id)jsonObject bookmarksCount:(NSInteger *)bookmarksCount historiesCount:(NSInteger *)historiesCount inContext:(NSManagedObjectContext *)context;

@end
