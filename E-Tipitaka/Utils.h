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
+ (char *) replace:(const char *)original pattern:(const char *)pattern 
       replacement:(const char*)replacement;

@end
