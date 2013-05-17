//
//  BookmarkEditViewController.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Bookmark;

@interface BookmarkEditViewController : UIViewController {
    Bookmark *bookmark;
    UILabel *label1;
    UILabel *label2;
    UITextView *textView;
}

@property (nonatomic, strong) Bookmark *bookmark;
@property (nonatomic, strong) IBOutlet UILabel *label1;
@property (nonatomic, strong) IBOutlet UILabel *label2;
@property (nonatomic, strong) IBOutlet UITextView *textView;

-(IBAction) saveButtonClicked:(id) sender;

@end
