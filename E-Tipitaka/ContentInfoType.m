//
//  ContentInfoType.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 9/10/54 BE.
//  Copyright 2554 __MyCompanyName__. All rights reserved.
//

#import "ContentInfoType.h"
#import "ContentInfo.h"

@implementation ContentInfoType

- (NSUInteger) getTypeCode
{
    return 0;
}

- (NSPredicate *) predicate:(ContentInfo *)info
{
    return nil;
}

@end

@implementation Language_Volume

- (NSUInteger) getTypeCode
{
    return LANGUAGE | VOLUME;
}

- (NSPredicate *) predicate:(ContentInfo *)info
{
    return [NSPredicate 
            predicateWithFormat:@"(lang = %@ && volume = %d)",
            [info.language lowercaseString], [info.volume intValue]];
}

@end

@implementation Language_Volume_Page

- (NSUInteger) getTypeCode
{
    return LANGUAGE | VOLUME | PAGE;
}

- (NSPredicate *) predicate:(ContentInfo *)info
{
    return [NSPredicate 
            predicateWithFormat:@"(lang = %@ && volume = %d && page = %d)",
            [info.language lowercaseString], [info.volume intValue], [info.page intValue]];
}

@end

@implementation Language_Volume_ItemNumber

- (NSUInteger) getTypeCode
{
    return LANGUAGE | VOLUME | ITEM_NUMBER;
}

- (NSPredicate *) predicate:(ContentInfo *)info
{
    return [NSPredicate 
            predicateWithFormat:@"(number = %d && content.lang = %@ && content.volume = %d && begin = 1)",
            [info.itemNumber intValue],
            [info.language lowercaseString], 
            [info.volume intValue]];
}

@end

@implementation Language_Volume_ItemNumber_Section

- (NSUInteger) getTypeCode
{
    return LANGUAGE | VOLUME | ITEM_NUMBER | SECTION;
}

- (NSPredicate *) predicate:(ContentInfo *)info
{
    return [NSPredicate 
            predicateWithFormat:@"(number = %d && content.lang = %@ && content.volume = %d && begin = 1 && section = %d)",
            [info.itemNumber intValue],
            [info.language lowercaseString], 
            [info.volume intValue],
            [info.section intValue]];
}

@end

@implementation Language_Volume_Page_Begin

- (NSUInteger) getTypeCode
{
    return LANGUAGE | VOLUME | PAGE | BEGIN;
}

- (NSPredicate *) predicate:(ContentInfo *)info
{
    return [NSPredicate 
            predicateWithFormat:@"(content.lang = %@ && content.volume = %d && content.page = %d && begin = %d)",
            [info.language lowercaseString], 
            [info.volume intValue],
            [info.page intValue], info.begin];
}

@end

@implementation Language_Volume_Begin

- (NSUInteger) getTypeCode
{
    return LANGUAGE | VOLUME | BEGIN;
}

- (NSPredicate *) predicate:(ContentInfo *)info
{
    return [NSPredicate 
            predicateWithFormat:@"(content.lang = %@ && content.volume = %d && begin = %d)",
            [info.language lowercaseString], 
            [info.volume intValue], info.begin];
}

@end