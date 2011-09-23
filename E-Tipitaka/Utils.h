//
//  Utils.h
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utils : NSObject {

}

+ (NSString *)arabic2thai:(NSString *)text;
+ (NSDictionary *)readData;
+ (void)writeData:(NSDictionary *)plistDict;
+ (NSDictionary *)readPages;
+ (NSDictionary *)readItems;
+ (NSDictionary *)readNames;
+ (NSDictionary *)readPlist:(NSString *)name;
+ (char *) replace:(const char *)original pattern:(const char *)pattern 
       replacement:(const char*)replacement;
+(NSString *) createHeaderTitle:(NSNumber *)volume;
@end
