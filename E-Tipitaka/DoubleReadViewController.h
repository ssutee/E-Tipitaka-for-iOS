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

@property (nonatomic, strong) IBOutlet SpecificedLanguageReadViewController *sourceController;
@property (nonatomic, strong) IBOutlet SpecificedLanguageReadViewController *targetController;

@property (nonatomic, strong) NSDictionary *mappingTable;

@property (nonatomic, strong) UIActionSheet *itemOptionsActionSheet;

@property (nonatomic, strong) NSString *sourceLanguage;
@property (nonatomic, strong) NSString *targetLanguage;
@property (nonatomic, strong) NSString *keywords;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *compareButton1;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *returnButton1;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *headerButton1;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *compareButton2;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *returnButton2;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *headerButton2;

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
