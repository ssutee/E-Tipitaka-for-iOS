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
    NSString *__weak language;
    NSNumber *__weak volume;
    NSNumber *__weak page;
    NSNumber *__weak section;
    NSNumber *__weak itemNumber;
    BOOL begin;
    ContentInfoType *_type;
}

@property(weak) NSString *language;
@property(weak) NSNumber *volume;
@property(weak) NSNumber *page;
@property(weak) NSNumber *section;
@property(weak) NSNumber *itemNumber;
@property(assign) BOOL begin;

-(NSPredicate *) predicate;
-(NSUInteger) getType;
-(void) setType:(NSUInteger) typeCode;

@end
