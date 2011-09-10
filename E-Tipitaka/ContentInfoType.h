//
//  ContentInfoType.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 9/10/54 BE.
//  Copyright 2554 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ContentInfo;

@interface ContentInfoType : NSObject

- (NSUInteger) getTypeCode;
- (NSPredicate *) predicate:(ContentInfo *)info;

@end

@interface Language_Volume : ContentInfoType
@end

@interface Language_Volume_Page : ContentInfoType 
@end

@interface Language_Volume_ItemNumber : ContentInfoType 
@end

@interface Language_Volume_ItemNumber_Section : ContentInfoType 
@end

@interface Language_Volume_Page_Begin : ContentInfoType 
@end

@interface Language_Volume_Begin : ContentInfoType
@end
