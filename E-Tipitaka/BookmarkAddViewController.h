//
//  BookmarkAddViewController.h
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item, ReadViewController;

@interface BookmarkAddViewController : UIViewController {
	UILabel *titleLabel1;
	UILabel *titleLabel2;
	UITextView *textView;
	Item *selectedItem;
    UIPopoverController *popoverController;
    ReadViewController *readViewController;
}

@property(nonatomic, retain) IBOutlet UILabel *titleLabel1;
@property(nonatomic, retain) IBOutlet UILabel *titleLabel2;
@property(nonatomic, retain) IBOutlet UITextView *textView;
@property(nonatomic, retain) Item *selectedItem;
@property(nonatomic, retain) UIPopoverController *popoverController;
@property(nonatomic, retain) ReadViewController *readViewController;

-(IBAction) backgroundClicked;
-(IBAction) saveButtonClicked:(id) sender;
-(IBAction) cancelButtonClicked:(id) sender;

@end
