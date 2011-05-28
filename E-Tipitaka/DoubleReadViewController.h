//
//  DoubleReadViewController.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "TapDetectingWindow.h"

@interface DoubleReadViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate> {
//    TapDetectingWindow *mWindow;
    NSString *sourceLanguage;
    NSString *targetLanguage;
    NSDictionary *mappingTable;
    
    BOOL scrollToItem;
    NSInteger savedItemNumber;
    
    UIActionSheet *itemOptionsActionSheet;
    
    IBOutlet UIWebView *webview1;
    IBOutlet UIWebView *webview2;
    
    IBOutlet UISlider *slider1;
    IBOutlet UISlider *slider2;
    
    IBOutlet UILabel *pageLabel1;
    IBOutlet UILabel *titleLabel1;

    IBOutlet UILabel *pageLabel2;
    IBOutlet UILabel *titleLabel2;
    
    IBOutlet UIBarButtonItem *backButton1;
    IBOutlet UIBarButtonItem *nextButton1;
    IBOutlet UIBarButtonItem *compareButton1;
    IBOutlet UIBarButtonItem *returnButton1;
    IBOutlet UIBarButtonItem *headerButton1;

    IBOutlet UIBarButtonItem *backButton2;
    IBOutlet UIBarButtonItem *nextButton2;
    IBOutlet UIBarButtonItem *compareButton2;
    IBOutlet UIBarButtonItem *returnButton2;
    IBOutlet UIBarButtonItem *headerButton2;    
}

@property (nonatomic, retain) NSDictionary *mappingTable;

@property (nonatomic, retain) UIActionSheet *itemOptionsActionSheet;

@property (nonatomic, retain) NSString *sourceLanguage;
@property (nonatomic, retain) NSString *targetLanguage;

@property (nonatomic, retain) IBOutlet UIWebView *webview1;
@property (nonatomic, retain) IBOutlet UIWebView *webview2;

@property (nonatomic, retain) IBOutlet UISlider *slider1;
@property (nonatomic, retain) IBOutlet UISlider *slider2;

@property (nonatomic, retain) IBOutlet UILabel *pageLabel1;
@property (nonatomic, retain) IBOutlet UILabel *pageLabel2;

@property (nonatomic, retain) IBOutlet UILabel *titleLabel1;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel2;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton1;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *nextButton1;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *compareButton1;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *returnButton1;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *headerButton1;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton2;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *nextButton2;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *compareButton2;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *returnButton2;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *headerButton2;

@property (assign) BOOL scrollToItem;
@property (assign) NSInteger savedItemNumber;

-(IBAction) returnToRead:(id)sender;
-(IBAction) next:(id)sender;
-(IBAction) back:(id)sender;
-(IBAction) sliderValueChanged:(id)sender;
-(IBAction) compare:(id)sender;

-(void) updatePages;


@end
