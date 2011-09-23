//
//  DoubleReadViewController.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpecificedLanguageReadViewController.h"

#define kSourceLanguageSide 1
#define kTargetLanguageSide 2

@interface DoubleReadViewController : UIViewController <UIActionSheetDelegate> {
    NSString *sourceLanguage;
    NSString *targetLanguage;
    
    NSString *keywords;
    
    NSDictionary *mappingTable;    
    BOOL scrollToItem;
    NSInteger savedItemNumber;
    
    UIActionSheet *itemOptionsActionSheet;
        
    IBOutlet UIBarButtonItem *compareButton1;
    IBOutlet UIBarButtonItem *returnButton1;
    IBOutlet UIBarButtonItem *headerButton1;

    IBOutlet UIBarButtonItem *compareButton2;
    IBOutlet UIBarButtonItem *returnButton2;
    IBOutlet UIBarButtonItem *headerButton2;    
}

@property (nonatomic, retain) IBOutlet SpecificedLanguageReadViewController *sourceController;
@property (nonatomic, retain) IBOutlet SpecificedLanguageReadViewController *targetController;

@property (nonatomic, retain) NSDictionary *mappingTable;

@property (nonatomic, retain) UIActionSheet *itemOptionsActionSheet;

@property (nonatomic, retain) NSString *sourceLanguage;
@property (nonatomic, retain) NSString *targetLanguage;
@property (nonatomic, retain) NSString *keywords;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *compareButton1;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *returnButton1;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *headerButton1;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *compareButton2;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *returnButton2;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *headerButton2;

@property (assign) BOOL scrollToItem;
@property (assign) NSInteger savedItemNumber;

-(IBAction) returnToRead:(id)sender;
//-(IBAction) compare:(id)sender;

//-(IBAction) next:(id)sender;
//-(IBAction) back:(id)sender;
//-(IBAction) sliderValueChanged:(id)sender;


//-(void) updatePages;
//-(void) updatePage:(NSString *)language;
//-(void) updatePage:(NSString *)language withKeyword:(NSString *)term;


@end
