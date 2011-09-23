//
//  SpecificedLanguageReadViewController.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 9/23/54 BE.
//  Copyright 2554 __MyCompanyName__. All rights reserved.
//

#import "SpecificedLanguageReadViewController.h"

@implementation SpecificedLanguageReadViewController


-(NSString *) getCurrentLanguage
{
    return _language;
}

-(void) setCurrentLanguage:(NSString *)language
{
    _language = [NSString stringWithString:language];
}

@end
