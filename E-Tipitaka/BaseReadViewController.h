//
//  BaseReadViewController.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 9/10/54 BE.
//  Copyright 2554 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapDetectingWindow.h"

@class ContentViewController;

@interface BaseReadViewController : UIViewController<UIScrollViewDelegate> {
    NSUInteger currentMaxPages;
}

@property(nonatomic, retain) NSDictionary *dataDictionary;
@property(nonatomic, retain) NSMutableDictionary *scrollPostion;
@property(nonatomic, retain) NSString *keywords;

@property(assign) BOOL scrollToKeyword;
@property(assign) NSInteger savedItemNumber;
@property(assign) BOOL scrollToItem;
@property(assign) NSInteger fontSize;
@property(assign) BOOL pageFunctionUsed;

@property(nonatomic, retain) ContentViewController *contentViewController;   

@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) NSMutableArray *viewControllers;

@property(nonatomic, retain) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) IBOutlet UILabel *pageNumberLabel;
@property(nonatomic, retain) IBOutlet UIView *contentView;
@property(nonatomic, retain) IBOutlet UISlider *pageSlider;
@property(nonatomic, retain) IBOutlet UILabel *toastText;

-(void) updateReadingPage;
-(void) updatePageTitle:(NSString *)language volume:(NSNumber *)volume page:(NSNumber *)page;
-(void) reloadData;

-(void) dismissAllPopoverControllers;

-(NSString *) getCurrentLanguage;
-(NSNumber *) getCurrentVolume;
-(NSNumber *) getCurrentPage;
-(void) setCurrentLanguage:(NSString *)language;
-(void) setCurrentVolume:(NSNumber *)volume;
-(void) setCurrentPage:(NSNumber *)page;

-(IBAction)nextButtonClicked:(id)sender;
-(IBAction)backButtonClicked:(id)sender;
-(IBAction)sliderValueChanged:(UISlider *)sender;
-(IBAction) startUpdatingPage:(id)sender;


@end
