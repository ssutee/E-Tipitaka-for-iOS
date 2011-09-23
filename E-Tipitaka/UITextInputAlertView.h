//
//  UITextInputAlertView.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 9/10/54 BE.
//  Copyright 2554 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextInputAlertView : UIAlertView {
    UILabel *label;
    UITextField *field;
}

@property (nonatomic, readonly) UILabel *label;
@property (nonatomic, readonly) UITextField *field;

@end
