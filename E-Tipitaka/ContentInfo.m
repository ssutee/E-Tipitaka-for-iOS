//
//  ContentInfo.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 9/10/54 BE.
//  Copyright 2554 __MyCompanyName__. All rights reserved.
//

#import "ContentInfo.h"
#import "ContentInfoType.h"

@implementation ContentInfo

@synthesize language;
@synthesize page;
@synthesize volume;
@synthesize section;
@synthesize itemNumber;
@synthesize begin;

-(NSUInteger) getType
{
    return [_type getTypeCode];
}

-(void) setType:(NSUInteger) typeCode
{
    [_type release];
    switch (typeCode) {
        case LANGUAGE | VOLUME:
            _type = [[Language_Volume alloc] init];
            break;
        case LANGUAGE | VOLUME | PAGE:
            _type = [[Language_Volume_Page alloc] init];
            break;
        case LANGUAGE | VOLUME | ITEM_NUMBER:
            _type = [[Language_Volume_ItemNumber alloc] init];
            break;
        case LANGUAGE | VOLUME | ITEM_NUMBER | SECTION:
            _type = [[Language_Volume_ItemNumber_Section alloc] init];
            break;
        case LANGUAGE | VOLUME | BEGIN:
            _type = [[Language_Volume_Begin alloc] init];
            break;
        case LANGUAGE | VOLUME | PAGE | BEGIN:
            _type = [[Language_Volume_Page_Begin alloc] init];
            break;
        default:
            [NSException raise:@"Invalid type code value" format:@"type code of %d is invalid", typeCode];            
            break;
    }
}

- (void)dealloc
{
    [super dealloc];
    [_type release];
}

- (NSPredicate *)predicate
{
    return [_type predicate:self];
}

@end
