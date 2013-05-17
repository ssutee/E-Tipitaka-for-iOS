//
//  BaseReadViewController.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 9/10/54 BE.
//  Copyright 2554 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapDetectingWindow.h"
#import "DictionaryListViewController.h"

#define MAXIMUM_PAGES 10000

@class BaseReadViewController;

@protocol BaseReadViewControllerDelegate <NSObject>

- (void)baseReadViewController:(BaseReadViewController *)controller didLoadVolume:(NSInteger)volume andPage:(NSInteger)page;

@end


#define allTrim( object ) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ]

@class ContentViewController;

@interface BaseReadViewController : UIViewController<UIScrollViewDelegate> {
    NSUInteger currentMaxPages;
}

@property(nonatomic, strong) NSDictionary *dataDictionary;
@property(nonatomic, strong) NSMutableDictionary *scrollPostion;
@property(nonatomic, strong) NSString *keywords;

@property(assign) BOOL scrollToKeyword;
@property(assign) NSInteger savedItemNumber;
@property(assign) BOOL scrollToItem;
@property(assign) NSInteger fontSize;
@property(assign) BOOL pageFunctionUsed;

@property(weak) ContentViewController *contentViewController;   

@property(nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property(nonatomic, strong) NSMutableArray *viewControllers;
@property (nonatomic, strong) UIPopoverController *dictionaryPopoverController;
@property(nonatomic, strong) DictionaryListViewController *dictionaryListViewController;

@property(nonatomic, strong) IBOutlet UILabel *titleLabel;
@property(nonatomic, strong) IBOutlet UILabel *pageNumberLabel;
@property(nonatomic, strong) IBOutlet UIView *contentView;
@property(nonatomic, strong) IBOutlet UISlider *pageSlider;
@property(nonatomic, strong) IBOutlet UILabel *toastText;

@property(nonatomic, unsafe_unretained) id<BaseReadViewControllerDelegate> delegate;

-(void) updateReadingPage;
-(void) updatePageTitle:(NSString *)language volume:(NSNumber *)volume page:(NSNumber *)page;
-(void) reloadData;
-(void) forceReloadData;

- (void)initScrollViewWithCurrentPage;
- (BOOL)prepareScrollViewForPage:(int)page;

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
