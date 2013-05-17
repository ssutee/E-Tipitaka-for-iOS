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

@property(nonatomic, strong) IBOutlet UILabel *titleLabel1;
@property(nonatomic, strong) IBOutlet UILabel *titleLabel2;
@property(nonatomic, strong) IBOutlet UITextView *textView;
@property(nonatomic, strong) Item *selectedItem;
@property(nonatomic, strong) UIPopoverController *popoverController;
@property(nonatomic, strong) ReadViewController *readViewController;

-(IBAction) backgroundClicked;
-(IBAction) saveButtonClicked:(id) sender;
-(IBAction) cancelButtonClicked:(id) sender;

@end
