//
//  ReadViewController.h
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapDetectingWindow.h"

@class Content;

#define kGotoActionSheet 1001
#define kLanguageActionSheet 1002
#define kSelectItemActionSheet 1003
#define kItemOptionsActionSheet 1004
#define kBookmarkOptionsActionSheet 1005

#define kGotoPageAlert 2001
#define kGotoItemAlert 2002

@interface ReadViewController : UIViewController 
<UIWebViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate, TapDetectingWindowDelegate, UIPopoverControllerDelegate, UISplitViewControllerDelegate>
{
	UILabel *titleLabel;
	UIToolbar *toolbar;
	UIWebView *htmlView;
	NSMutableDictionary *dataDictionary;
    NSDictionary *pagesDictionary;
    NSDictionary *itemsDictionary;    
	BOOL showToolbar;
	TapDetectingWindow *mWindow;
	
    BOOL scrollToItem;
    BOOL scrollToKeyword;
    
	NSInteger savedItemNumber;
	NSArray *alterItems;
	NSString *keywords;
	NSInteger thaiScrollPosition;
	NSInteger paliScrollPosition;
    NSInteger fontSize;
    UIPopoverController *searchPopoverController;
    UIPopoverController *bookmarkPopoverController;
    UIBarButtonItem *searchButton;
    UIBarButtonItem *languageButton;
    UIBarButtonItem *noteButton;
    UIBarButtonItem *bookmarkButton;
    UIBarButtonItem *gotoButton;
    UIBarButtonItem *titleButton;
    UIActionSheet *languageActionSheet;
    UIActionSheet *gotoActionSheet;
    UIActionSheet *itemOptionsActionSheet;
    UILabel *toastText;
    //UIActivityIndicatorView *indicator;
}

@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property(nonatomic, retain) IBOutlet UIWebView *htmlView;
@property(nonatomic, retain) IBOutlet UILabel *toastText;
@property(nonatomic, retain) NSDictionary *dataDictionary;
@property(nonatomic, retain) NSDictionary *pagesDictionary;
@property(nonatomic, retain) NSDictionary *itemsDictionary;
@property(nonatomic, retain) NSArray *alterItems;
@property(nonatomic, retain) NSString *keywords;
@property(assign) BOOL scrollToItem;
@property(assign) BOOL scrollToKeyword;
@property(assign) NSInteger savedItemNumber;
@property(assign) NSInteger fontSize;

@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) UIPopoverController *searchPopoverController;
@property (nonatomic, retain) UIPopoverController *bookmarkPopoverController;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *searchButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *languageButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *gotoButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *noteButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *bookmarkButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *titleButton;
//@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, retain) UIActionSheet *languageActionSheet;
@property (nonatomic, retain) UIActionSheet *gotoActionSheet;
@property (nonatomic, retain) UIActionSheet *itemOptionsActionSheet;

-(IBAction)gotoButtonClicked:(id)sender;
-(IBAction)nextButtonClicked:(id)sender;
-(IBAction)backButtonClicked:(id)sender;
-(IBAction)languageButtonClicked:(id)sender;
-(IBAction)noteButtonClicked:(id)sender;
-(IBAction)toggleLanguage:(id)sender;
-(IBAction)increaseFontSize:(id)sender;
-(IBAction)decreaseFontSize:(id)sender;
-(IBAction)showSearchView:(id)sender;
-(IBAction)showBookmarkListView:(id)sender;

-(void) updateLanguageButtonTitle;
-(void) updateReadingPage;
-(void) updateReadingPage:(NSString *)query;
-(void) reloadData;
-(void) resetScrollPositions;
-(void) dismissAllPopoverControllers;
-(void) showToast;
-(void) hideToast:(NSTimer *)theTimer;

-(NSInteger) getMaximumItemValue:(NSString *)language ofVolume:(NSNumber *)volume;
-(NSInteger) getMaximumPageValue:(NSString *)language ofVolume:(NSNumber *)volume;
-(NSArray *) getContents:(NSString *)language forVolume:(NSNumber *)volume  forPage:(NSNumber *)page;
-(NSArray *) getContents:(NSString *)language forVolume:(NSNumber *)volume;

-(NSArray *) getItems:(NSString *)language forVolume:(NSNumber *)volume forNumber:(NSNumber *)number;
-(NSArray *) getItems:(NSString *)language forVolume:(NSNumber *)volume forNumber:(NSNumber *)number forSection:(NSNumber *)section;
-(NSArray *) getItems:(NSString *)language forVolume:(NSNumber *)volume forPage:(NSNumber *)page onlyBegin:(BOOL)begin;
-(NSArray *) getItems:(NSString *)language forVolume:(NSNumber *)volume onlyBegin:(BOOL)begin;
-(NSArray *) getItemsFromContent:(Content *)content;


-(void) showItemOptions:(NSArray *)items withTag:(NSInteger)tagNumber withTitle:(NSString *)titleName;



@end
