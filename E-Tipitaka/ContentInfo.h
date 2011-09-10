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
    NSString *language;
    NSNumber *volume;
    NSNumber *page;
    NSNumber *section;
    NSNumber *itemNumber;
    BOOL begin;
    ContentInfoType *_type;
}

@property(assign) NSString *language;
@property(assign) NSNumber *volume;
@property(assign) NSNumber *page;
@property(assign) NSNumber *section;
@property(assign) NSNumber *itemNumber;
@property(assign) BOOL begin;

-(NSPredicate *) predicate;
-(NSUInteger) getType;
-(void) setType:(NSUInteger) typeCode;

@end
