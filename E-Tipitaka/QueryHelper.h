//
//  QueryHelper.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 9/10/54 BE.
//  Copyright 2554 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Content;
@class ContentInfo;

@interface QueryHelper : NSObject

//+(NSInteger) getMaximumItemValue:(NSString *)language ofVolume:(NSNumber *)volume;
+(NSInteger) getMaximumItemValue:(ContentInfo *)info;

//+(NSInteger) getMaximumPageValue:(NSString *)language ofVolume:(NSNumber *)volume;
+(NSInteger) getMaximumPageValue:(ContentInfo *)info;

+(NSArray *) getContents:(ContentInfo *)info;
+(NSArray *) getItems:(ContentInfo *)info;
+(NSArray *) getItemsFromContent:(Content *)content;


@end
