//
//  ContentInfo.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 9/10/54 BE.
//  Copyright 2554 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define LANGUAGE    1
#define VOLUME      2
#define PAGE        4
#define SECTION     8
#define ITEM_NUMBER 16
#define BEGIN       32

@class ContentInfoType;

@interface ContentInfo : NSObject
{
    ContentInfoType *_type;
}

@property(nonatomic, strong) NSString *language;
@property(nonatomic, strong) NSNumber *volume;
@property(nonatomic, strong) NSNumber *page;
@property(nonatomic, strong) NSNumber *section;
@property(nonatomic, strong) NSNumber *itemNumber;
@property(assign) BOOL begin;

-(NSPredicate *) predicate;
-(NSUInteger) getType;
-(void) setType:(NSUInteger) typeCode;

@end
