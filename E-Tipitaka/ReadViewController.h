//
//  ReadViewController.h
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapDetectingWindow.h"
#import "BaseReadViewController.h"
#import "MBProgressHUD.h"
#import "ASIHTTPRequest.h"

@class Content;
@class DictionaryListViewController;

#define kGotoActionSheet 1001
#define kLanguageActionSheet 1002
#define kSelectItemActionSheet 1003
#define kItemOptionsActionSheet 1004
#define kBookmarkOptionsActionSheet 1005

#define kGotoPageAlert 2001
#define kGotoItemAlert 2002
#define kDatabaseAlert 2003
#define kQuitAlert 2004
#define kFacebookAlert 2005

@interface ReadViewController : BaseReadViewController 
<UIWebViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate, TapDetectingWindowDelegate, MBProgressHUDDelegate, ASIProgressDelegate>
{
    TapDetectingWindow *mWindow;
    
    BOOL showToolbar;
	NSArray *alterItems;
	
    DictionaryListViewController *dictionaryListViewController;
    
    UIPopoverController *searchPopoverController;
    UIPopoverController *bookmarkPopoverController;
    UIPopoverController *booklistPopoverController;
    UIPopoverController *dictionaryPopoverController;
    UIBarButtonItem *searchButton;
    UIBarButtonItem *languageButton;
    UIBarButtonItem *booklistButton;
    UIBarButtonItem *noteButton;
    UIBarButtonItem *bookmarkButton;
    UIBarButtonItem *gotoButton;
    UIBarButtonItem *titleButton;
    UIBarButtonItem *dictionaryButton;
    
    UIToolbar *bottomToolBar;
    UIActionSheet *languageActionSheet;
    UIActionSheet *gotoActionSheet;
    UIActionSheet *itemOptionsActionSheet;
    double lastScale;
}

@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UILabel *pageNumberLabel;
@property(nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic, retain) IBOutlet UIView *contentView;
@property(nonatomic, retain) IBOutlet UILabel *toastText;

@property(nonatomic, retain) NSArray *alterItems;

@property (nonatomic, retain) UIPopoverController *searchPopoverController;
@property (nonatomic, retain) UIPopoverController *bookmarkPopoverController;
@property (nonatomic, retain) UIPopoverController *booklistPopoverController;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *searchButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *languageButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *booklistButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *gotoButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *noteButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *bookmarkButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *titleButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *dictionaryButton;
@property (nonatomic, retain) UIActionSheet *languageActionSheet;
@property (nonatomic, retain) UIActionSheet *gotoActionSheet;
@property (nonatomic, retain) UIActionSheet *itemOptionsActionSheet;
@property (nonatomic, retain) IBOutlet UISlider *pageSlider;
@property (nonatomic, retain) IBOutlet UIToolbar *bottomToolbar;

-(IBAction)gotoButtonClicked:(id)sender;
-(IBAction)nextButtonClicked:(id)sender;
-(IBAction)backButtonClicked:(id)sender;
-(IBAction)languageButtonClicked:(id)sender;
-(IBAction)noteButtonClicked:(id)sender;
-(IBAction)toggleLanguage:(id)sender;
-(IBAction)showSearchView:(id)sender;
-(IBAction)showBookmarkListView:(id)sender;
-(IBAction)showBooklistTableView:(id)sender;
//-(IBAction)showDictionary:(id)sender;

-(void) updateLanguageButtonTitle;

-(void) resetScrollPositions;
-(void) dismissAllPopoverControllers;
-(void) showToast;
-(void) hideToast:(NSTimer *)theTimer;

//-(void) lookUpDictionary:(id)sender;

-(void) showItemOptions:(NSArray *)items withTag:(NSInteger)tagNumber withTitle:(NSString *)titleName;


@end
