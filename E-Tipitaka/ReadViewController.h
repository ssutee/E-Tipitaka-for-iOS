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

@class Content;
@class DictionaryListViewController;

#define kGotoActionSheet 1001
#define kLanguageActionSheet 1002
#define kSelectItemActionSheet 1003
#define kItemOptionsActionSheet 1004
#define kBookmarkOptionsActionSheet 1005
#define kDataToolsActionSheet 1006

#define kGotoPageAlert 2001
#define kGotoItemAlert 2002
#define kDatabaseAlert 2003
#define kQuitAlert 2004
#define kFacebookAlert 2005

#define kFacebookSharingKey @"kFacebookSharingKey"

@interface ReadViewController : BaseReadViewController 
<UIWebViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate, TapDetectingWindowDelegate, MBProgressHUDDelegate>
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

@property(nonatomic, strong) IBOutlet UILabel *titleLabel;
@property(nonatomic, strong) IBOutlet UILabel *pageNumberLabel;
@property(nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property(nonatomic, strong) IBOutlet UIView *contentView;
@property(nonatomic, strong) IBOutlet UILabel *toastText;

@property(nonatomic, strong) NSArray *alterItems;

@property (nonatomic, strong) UIPopoverController *searchPopoverController;
@property (nonatomic, strong) UIPopoverController *bookmarkPopoverController;
@property (nonatomic, strong) UIPopoverController *booklistPopoverController;
@property (nonatomic, strong) UIPopoverController *importFilePopoverController;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *searchButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *languageButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *booklistButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *gotoButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *noteButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *bookmarkButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *titleButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *dictionaryButton;
@property (nonatomic, strong) UIActionSheet *languageActionSheet;
@property (nonatomic, strong) UIActionSheet *gotoActionSheet;
@property (nonatomic, strong) UIActionSheet *itemOptionsActionSheet;
@property (nonatomic, strong) UIActionSheet *dataToolsActionSheet;
@property (nonatomic, strong) IBOutlet UISlider *pageSlider;
@property (nonatomic, strong) IBOutlet UIToolbar *bottomToolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *dataToolsButton;

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
