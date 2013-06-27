//
//  UITextInputAlertView.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 9/10/54 BE.
//  Copyright 2554 __MyCompanyName__. All rights reserved.
//

#import "UITextInputAlertView.h"

@implementation UITextInputAlertView

@synthesize label;
@synthesize field;

- (id)init
{
    self = [super init];
    if (self) {        
        label = [[UILabel alloc] initWithFrame:CGRectMake(12,40,260,25)];
        label.font = [UIFont systemFontOfSize:18];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.shadowColor = [UIColor blackColor];
        label.shadowOffset = CGSizeMake(0,-1);
        label.textAlignment = UITextAlignmentCenter;
        
        [self addSubview:label];
        
        UIImageView *image = [[UIImageView alloc] 
                                  initWithImage:[UIImage 
                                                 imageWithContentsOfFile:[[NSBundle mainBundle] 
                                                                          pathForResource:@"passwordfield" ofType:@"png"]]];
        image.frame = CGRectMake(11,79,262,31);
        [self addSubview:image];
        
        UIViewController *controller = (UIViewController *)self.delegate;
        if (UIInterfaceOrientationIsPortrait(controller.interfaceOrientation)) {
            field = [[UITextField alloc] initWithFrame:CGRectMake(16, 83, 252, 25)];
        }
        else {
            field = [[UITextField alloc] initWithFrame:CGRectMake(16, 68, 252, 25)];
        }
        
        field.font = [UIFont systemFontOfSize:18];
        field.backgroundColor = [UIColor whiteColor];
        field.secureTextEntry = NO;
        field.keyboardAppearance = UIKeyboardAppearanceAlert;
        field.keyboardType = UIKeyboardTypeNumberPad;
        
        field.delegate = self.delegate;
        
        [field becomeFirstResponder];
        [self addSubview:field];
        
        [self setTransform:CGAffineTransformMakeTranslation(0,0)];
    }
    
    return self;
}





@end
