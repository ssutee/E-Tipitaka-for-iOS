//
//  SpecificedLanguageReadViewController.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 9/23/54 BE.
//  Copyright 2554 __MyCompanyName__. All rights reserved.
//

#import "BaseReadViewController.h"

@interface SpecificedLanguageReadViewController : BaseReadViewController
{
    NSString *_language;
}

-(NSString *) getCurrentLanguage;
-(void) setCurrentLanguage:(NSString *)language;


@end
