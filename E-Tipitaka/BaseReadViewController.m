//
//  BaseReadViewController.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 9/10/54 BE.
//  Copyright 2554 __MyCompanyName__. All rights reserved.
//

#import "BaseReadViewController.h"
#import "ContentViewController.h"
#import "ContentInfo.h"
#import "QueryHelper.h"
#import "Utils.h"

@implementation BaseReadViewController

@synthesize contentView=_contentView;
@synthesize titleLabel=_titleLabel;
@synthesize pageNumberLabel=_pageNumberLabel;
@synthesize contentViewController=_contentViewController;
@synthesize pageSlider=_pageSlider;
@synthesize toastText=_toastText;
@synthesize scrollView=_scrollView;
@synthesize viewControllers=_viewControllers;

@synthesize dataDictionary=_dataDictionary;
@synthesize scrollPostion=_scrollPostion;
@synthesize keywords=_keywords;
@synthesize scrollToKeyword=_scrollToKeyword;
@synthesize scrollToItem=_scrollToItem;
@synthesize savedItemNumber=_savedItemNumber;
@synthesize fontSize=_fontSize;
@synthesize pageFunctionUsed=_pageFunctionUsed;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc
{
    [_titleLabel release];
    [_pageNumberLabel release];
    [_contentView release];
    [_contentViewController release];
    [_dataDictionary release];
    [_keywords release];
    [_scrollPostion release];
    [_pageSlider release];
    [_toastText release];
    [_viewControllers release];
    [_scrollView release];
    [super dealloc];    
}

-(NSString *) getCurrentLanguage
{
    return [self.dataDictionary valueForKey:@"Language"];
}

-(NSNumber *) getCurrentVolume
{
    return [[self.dataDictionary valueForKey:[self getCurrentLanguage]] valueForKey:@"Volume"];	        
}

-(NSNumber *) getCurrentPage
{
    return [[self.dataDictionary valueForKey:[self getCurrentLanguage]] valueForKey:@"Page"];	        
}

-(void) setCurrentLanguage:(NSString *)language
{
    [self.dataDictionary setValue:language forKey:@"Language"];
}

-(void) setCurrentVolume:(NSNumber *)volume
{
    [[self.dataDictionary valueForKey:[self getCurrentLanguage]] setValue:volume forKey:@"Volume"];
}

-(void) setCurrentPage:(NSNumber *)page
{
    [[self.dataDictionary valueForKey:[self getCurrentLanguage]] setValue:page forKey:@"Page"];    
}

- (void)reloadData {
    if (self.dataDictionary) {
        NSString *language = [self getCurrentLanguage];    
        NSNumber *oldVolume = [[self.dataDictionary valueForKey:language] valueForKey:@"Volume"];
        NSNumber *newVolume = [[[Utils readData] valueForKey:language] valueForKey:@"Volume"];
        if (self.viewControllers == nil || [oldVolume intValue] != [newVolume intValue]) {
            ContentInfo *info = [[ContentInfo alloc] init];
            info.language = language;
            info.volume = newVolume;
            [info setType:LANGUAGE|VOLUME];
            currentMaxPages = [QueryHelper getMaximumPageValue:info];
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * currentMaxPages, self.scrollView.frame.size.height);

            NSMutableArray *controllers = [[NSMutableArray alloc] init];
            for (unsigned i = 0; i < currentMaxPages; i++)
            {
                [controllers addObject:[NSNull null]];
            }
            self.viewControllers = controllers;
            [controllers release];            
            [info release];
        }
    }
    
    self.dataDictionary = [Utils readData];
}

-(void) updatePageTitle:(NSString *)language volume:(NSNumber *)volume page:(NSNumber *)page 
{
    
    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = language;
    info.volume = volume;
    [info setType:LANGUAGE|VOLUME];
    NSInteger maxPage = [QueryHelper getMaximumPageValue:info];
    [info release];
    
    if (self.pageSlider.maximumValue != maxPage) {
        self.pageSlider.maximumValue = maxPage;
    }
    self.pageSlider.value = [page floatValue];
    
	NSString *newLabel1, *newLabel2;
	
	if([language isEqualToString:@"Thai"]) {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            newLabel1 = [[NSString alloc] initWithFormat:@"พระไตรปิฎก (ภาษาไทย) เล่มที่ %@", volume];
        } else {
            newLabel1 = [[NSString alloc] initWithFormat:@"พระไตรปิฎก (ภาษาไทย) เล่มที่ %@ หน้าที่ %@", 
                         volume, page];
        }
	} else {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            newLabel1 = [[NSString alloc] initWithFormat:@"พระไตรปิฎก (ภาษาบาลี) เล่มที่ %@", volume];
        } else {
            newLabel1 = [[NSString alloc] initWithFormat:@"พระไตรปิฎก (ภาษาบาลี) เล่มที่ %@ หน้าที่ %@", 
                         volume, page];            
        }
	}
    
    newLabel2 = [[NSString alloc] initWithFormat:@"หน้าที่ %@ / %d", page, maxPage];
    
    self.titleLabel.text = [Utils arabic2thai:newLabel1];
    self.pageNumberLabel.text = [Utils arabic2thai:newLabel2];
    
	[newLabel1 release];
    [newLabel2 release];    
}


-(void) updateReadingPage {
	if(!self.dataDictionary)
		return;
    
    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = [self getCurrentLanguage];
    info.volume = [self getCurrentVolume];
    info.page = [self getCurrentPage];
    [info setType:(LANGUAGE|VOLUME|PAGE)];
    NSArray *fetchedObjects = [QueryHelper getContents:info];
    [info release];    
    
	if(fetchedObjects == nil) {
		NSLog(@"Whoops, couldn't fetch");
	} else {		
		if ([fetchedObjects count] > 0) {
            self.contentViewController.content = [fetchedObjects objectAtIndex:0];
            self.contentViewController.fontSize = self.fontSize;
            self.contentViewController.scrollToHighlightText = NO;
            self.contentViewController.scrollToItemNumber = NO;
            self.contentViewController.highlightText = self.keywords;            
            if (self.scrollToItem) {
                self.scrollToItem = NO;
                self.contentViewController.itemNumber = self.savedItemNumber;
                self.contentViewController.scrollToItemNumber = YES;
            } else if (_scrollToKeyword) {
                self.scrollToKeyword = NO;                
                self.contentViewController.scrollToHighlightText = YES;
            } else {
                
                self.contentViewController.scrollPosition = [[self.scrollPostion valueForKey:[self getCurrentLanguage]] intValue];                
            }
            [self.contentViewController update];
		}
	}
    
    [self updatePageTitle:[self getCurrentLanguage]  volume:[self getCurrentVolume] page:[self getCurrentPage]];
    [Utils writeData:self.dataDictionary];
}

-(void)updateLanguageButtonTitle {
	NSString *language = [_dataDictionary valueForKey:@"Language"];
	if ([language isEqualToString:@"Thai"]) {
		self.navigationItem.leftBarButtonItem.title = @"บาลี";
	} else {
		self.navigationItem.leftBarButtonItem.title = @"ไทย";		
	}
}

-(IBAction)increaseFontSize:(id)sender {
    self.fontSize += 2;
    [self.dataDictionary setValue:[NSNumber numberWithInt:self.fontSize] forKey:@"FontSize"];
    [self updateReadingPage];
}

-(IBAction)decreaseFontSize:(id)sender {
    self.fontSize -= 2;
    [self.dataDictionary setValue:[NSNumber numberWithInt:self.fontSize] forKey:@"FontSize"];    
    [self updateReadingPage];    
}


-(IBAction)nextButtonClicked:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self dismissAllPopoverControllers];
    }
    
    self.scrollToItem = NO;
    self.scrollToKeyword = NO;
        
    NSString *language = [self getCurrentLanguage];
    NSNumber *page = [self getCurrentPage];
    NSNumber *volume = [self getCurrentVolume];
    
    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = language;
    info.volume = volume;
    [info setType:LANGUAGE|VOLUME];
    
    if ([page intValue] < [QueryHelper getMaximumPageValue:info]) {        
        [self.scrollPostion setValue:[NSNumber numberWithInt:0] forKey:language];                
        page = [NSNumber numberWithInt:[page intValue]+1];                
        [self setCurrentPage:page];
        [self updateReadingPage];
    }     
    [info release];    
    self.pageFunctionUsed = YES;    
}  

-(IBAction)backButtonClicked:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self dismissAllPopoverControllers];
    }

    self.scrollToItem = NO;
    self.scrollToKeyword = NO;    
    
    NSString *language = [self getCurrentLanguage];
    NSNumber *page = [self getCurrentPage];
    
    if ([page intValue] > 1) {
        // reset scroll position
        [self.scrollPostion setValue:[NSNumber numberWithInt:0] forKey:language];        
        page = [NSNumber numberWithInt:[page intValue]-1];        
        [self setCurrentPage:page];
        [self updateReadingPage];			
    }
    self.pageFunctionUsed = YES;
}


-(IBAction)sliderValueChanged:(UISlider *)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self dismissAllPopoverControllers];
    }

    self.scrollToItem = NO;
    self.scrollToKeyword = NO;

    
    NSString *language = [self getCurrentLanguage];    
    NSNumber *volume = [self getCurrentVolume];
    
    // reset scroll position
    [self.scrollPostion setValue:[NSNumber numberWithInt:0] forKey:language];      
    
    NSNumber *page = [NSNumber numberWithInt: round(sender.value)];
    
    [self setCurrentPage:page];    
    [self updatePageTitle:language volume:volume page:page];    
    self.pageFunctionUsed = YES;
}

-(IBAction) startUpdatingPage:(id)sender {
    [self updateReadingPage];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
    return NO;
}

- (void)loadScrollViewWithPage:(int)page
{
    if (page < 0)
        return;    
    if (page >= currentMaxPages)
        return;
    
    // replace the placeholder if necessary
    ContentViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[ContentViewController alloc] init];
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [self.scrollView addSubview:controller.view];
        self.contentViewController = controller;
        [self updateReadingPage];
    }
}



-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation { 
    [self updateReadingPage];
}

- (void) dismissAllPopoverControllers {
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.pageFunctionUsed) {
        return;
    }
    
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;

    [self setCurrentPage:[NSNumber numberWithInt:page+1]];    
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.pageFunctionUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageFunctionUsed = NO;
}



#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self reloadData];
    [self updateReadingPage];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithInt:0], @"Thai", 
                          [NSNumber numberWithInt:0], @"Pali",nil];
    self.scrollPostion = dict;
    [dict release];
    
//    ContentViewController *controller = [[ContentViewController alloc] initWithNibName:@"ContentView" bundle:nil];
//    self.contentViewController = controller;
//    [controller release];
//    self.contentViewController.view.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
//    [self.contentView addSubview:self.contentViewController.view];
        
    self.pageSlider.continuous = YES;    
	self.scrollToItem = NO;
    self.scrollToKeyword = NO;    
    self.pageSlider.minimumValue = 1;    
    self.toastText.hidden = YES;
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    [self reloadData];
    self.fontSize = [[self.dataDictionary valueForKey:@"FontSize"] intValue];    
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.titleLabel = nil;
    self.pageNumberLabel = nil;
    self.contentView = nil;
    self.contentViewController = nil;
    self.dataDictionary = nil;
    self.keywords = nil;
    self.scrollPostion = nil;
    self.pageSlider = nil;
    self.toastText = nil;
    self.scrollView = nil;
    self.viewControllers = nil;
}




@end
