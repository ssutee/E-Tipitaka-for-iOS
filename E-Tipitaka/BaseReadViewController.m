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
@synthesize dictionaryPopoverController=_dictionaryPopoverController;
@synthesize dictionaryListViewController = _dictionaryListViewController;

@synthesize delegate = _delegate;

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
    [_dataDictionary release];
    [_keywords release];
    [_scrollPostion release];
    [_pageSlider release];
    [_toastText release];
    [_viewControllers release];
    [_scrollView release];
    [_dictionaryPopoverController release];
    [_dictionaryListViewController release];
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

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(lookUpDictionary:)) { 
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            return NO;
        }
        NSString *selection = [self.contentViewController.webView
                               stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
        return ([allTrim(selection) length] != 0);
    }
    return [super canPerformAction:action withSender:sender];
}

-(void) lookUpDictionary:(id)sender
{
    [self showDictionary:nil];
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

-(NSArray *) fetchCurrentContent
{
    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = [self getCurrentLanguage];
    info.volume = [self getCurrentVolume];
    info.page = [self getCurrentPage];
    [info setType:(LANGUAGE|VOLUME|PAGE)];
    NSArray *fetchedObjects = [QueryHelper getContents:info];
    [info release];    
    return fetchedObjects;
}

-(NSArray *) fetchContent:(NSNumber *)page
{
    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = [self getCurrentLanguage];
    info.volume = [self getCurrentVolume];
    info.page = page;
    [info setType:(LANGUAGE|VOLUME|PAGE)];
    NSArray *fetchedObjects = [QueryHelper getContents:info];
    [info release];    
    return fetchedObjects;
}


-(void) updatePageInBackground:(NSUInteger)page
{
    if ([self prepareScrollViewForPage:page-1]) {
        NSArray *fetchedObjects = [self fetchContent:[NSNumber numberWithInt:page]];
        if (fetchedObjects == nil) {
            NSLog(@"Whoops, couldn't fetch");
        } else if ([fetchedObjects count] > 0) {          
            ContentViewController *controller = [self.viewControllers objectAtIndex:page-1];
            controller.content = [fetchedObjects objectAtIndex:0];
            controller.fontSize = self.fontSize;
            controller.scrollToHighlightText = NO;
            controller.scrollToItemNumber = NO;
            controller.highlightText = self.keywords;  
            controller.scrollPosition = 0;
            [controller update];      

        }
    }
}

-(void) updateReadingPage {
	if(!self.dataDictionary)
		return;
    
    [self prepareScrollViewForPage:[[self getCurrentPage] intValue]-1];    
    NSArray *fetchedObjects = [self fetchCurrentContent];    
    
	if(fetchedObjects == nil) {
		NSLog(@"Whoops, couldn't fetch");
	} else if ([fetchedObjects count] > 0) {            
        self.contentViewController = [self.viewControllers objectAtIndex:[[self getCurrentPage] intValue]-1];        
        self.contentViewController.content = [fetchedObjects objectAtIndex:0];
        self.contentViewController.fontSize = self.fontSize;
        self.contentViewController.scrollToHighlightText = NO;
        self.contentViewController.scrollToItemNumber = NO;
        self.contentViewController.highlightText = self.keywords;  
        if (self.scrollToItem) {
            self.contentViewController.itemNumber = self.savedItemNumber;
            self.contentViewController.scrollToItemNumber = YES;
            self.scrollToItem = NO;                
        } else if (self.scrollToKeyword) {
            self.scrollToKeyword = NO;                
            self.contentViewController.scrollToHighlightText = YES;
        } else {                
            self.contentViewController.scrollPosition = [[self.scrollPostion valueForKey:[self getCurrentLanguage]] intValue];                
        }        
        [self.contentViewController update];
	}    
    [self updatePageTitle:[self getCurrentLanguage]  volume:[self getCurrentVolume] page:[self getCurrentPage]];
    [Utils writeData:self.dataDictionary];
    
    self.pageFunctionUsed = YES;
    CGRect frame = self.contentView.frame;
    frame.origin.x = frame.size.width * ([[self getCurrentPage] intValue]-1);
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:NO];
        
    [self.delegate baseReadViewController:self didLoadVolume:[self getCurrentVolume].intValue andPage:[self getCurrentPage].intValue];
    
    [self updatePageInBackground:[[self getCurrentPage] intValue]-1];
    [self updatePageInBackground:[[self getCurrentPage] intValue]+1];
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

-(IBAction) startUpdatingPage:(id)sender {
    [self updateReadingPage];
}


-(IBAction)nextButtonClicked:(id)sender {
    self.pageFunctionUsed = YES;
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
}  


-(IBAction)backButtonClicked:(id)sender {
    self.pageFunctionUsed = YES;
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
}


-(IBAction)sliderValueChanged:(UISlider *)sender {
    self.pageFunctionUsed = YES;    
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

- (BOOL)shouldAutorotate {
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return orientation != UIInterfaceOrientationPortraitUpsideDown;
    }
}

- (BOOL)prepareScrollViewForPage:(int)page
{
    if (page < 0)
        return FALSE;    
    if (page >= currentMaxPages)
        return FALSE;

    // replace the placeholder if necessary
    ContentViewController *controller = [self.viewControllers objectAtIndex:page];
    if ((NSNull *)controller == [NSNull null])
    {
        controller = [[ContentViewController alloc] initWithNibName:@"ContentView" bundle:nil];
        [self.viewControllers replaceObjectAtIndex:page withObject:controller];
        [controller release];
    }
    
    // add the controller's view to the scroll view
    if (controller.view.superview == nil)
    {
        CGRect frame = self.contentView.frame;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0;
        controller.view.frame = frame;
        [self.scrollView addSubview:controller.view];
    }
    return TRUE;
}

- (void) recomputeFrameSize
{
    int page = 0;
    for (ContentViewController *controller in self.viewControllers) {
        if ((NSNull *)controller != [NSNull null]) {
            CGRect frame = self.contentView.frame;
            frame.origin.x = frame.size.width * page;
            frame.origin.y = 0;
            controller.view.frame = frame;
            [controller.webView scalesPageToFit];            
        }
        page++;
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation { 
    self.pageFunctionUsed = YES;
    self.scrollView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    self.scrollView.contentSize = CGSizeMake(self.contentView.frame.size.width * currentMaxPages, self.contentView.frame.size.height);
    [self recomputeFrameSize];
    
    int page = [[self getCurrentPage] intValue];
    ContentViewController *controller = [self.viewControllers objectAtIndex:page-1];
    if ((NSNull *)controller != [NSNull null]) {
        [controller.webView scalesPageToFit];
    }
    [self updateReadingPage];    
}

- (void) dismissAllPopoverControllers {
}

- (void) unloadInvisibleViews
{
    int curPage = [[self getCurrentPage] intValue]-1;
    int page = 0;

    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (ContentViewController *controller in self.viewControllers) {
        if ((NSNull *)controller != [NSNull null] && (page > curPage+2 || page < curPage-2)) {        
            [array addObject:[NSNumber numberWithInt:page]];
        }
        page++;
    }
    
    for (NSNumber *removedPage in array) {
        ContentViewController *controller = [self.viewControllers objectAtIndex:[removedPage intValue]];
        [controller.view removeFromSuperview];
        [self.viewControllers replaceObjectAtIndex:[removedPage intValue] withObject:[NSNull null]];
    }
        
    [array release];
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
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [self setCurrentPage:[NSNumber numberWithInt:page+1]];    
    [self updateReadingPage];    
    [self unloadInvisibleViews];    
}

- (void)initScrollViewWithCurrentPage
{
    [self reloadData];    
    self.scrollView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);    
    [self updateReadingPage];
}

- (void)forceReloadData
{
    if (self.dataDictionary == nil) {
        self.dataDictionary = [Utils readData];        
    }
    
    NSString *language = [self getCurrentLanguage];    
    NSNumber *volume = [[[Utils readData] valueForKey:language] valueForKey:@"Volume"];
    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = language;
    info.volume = volume;
    [info setType:LANGUAGE|VOLUME];
    currentMaxPages = [QueryHelper getMaximumPageValue:info];            
    [info release];
    self.scrollView.contentSize = CGSizeMake(self.contentView.frame.size.width * currentMaxPages, self.contentView.frame.size.height);               
    self.dataDictionary = [Utils readData];        
}

- (void)reloadData {    
    if (self.dataDictionary == nil) {
        self.dataDictionary = [Utils readData];        
    }
    
    NSString *language = [self getCurrentLanguage];    
    NSNumber *oldVolume = [[self.dataDictionary valueForKey:language] valueForKey:@"Volume"];
    NSNumber *newVolume = [[[Utils readData] valueForKey:language] valueForKey:@"Volume"];
    if (currentMaxPages == 0 || [oldVolume intValue] != [newVolume intValue]) {
        ContentInfo *info = [[ContentInfo alloc] init];
        info.language = language;
        info.volume = newVolume;
        [info setType:LANGUAGE|VOLUME];
        currentMaxPages = [QueryHelper getMaximumPageValue:info];            
        [info release];
    }    
    self.scrollView.contentSize = CGSizeMake(self.contentView.frame.size.width * currentMaxPages, self.contentView.frame.size.height);               
    self.dataDictionary = [Utils readData];    
}


-(IBAction)showDictionary:(id)sender {
    
    NSString *selection = [self.contentViewController.webView 
                           stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];        
    //    NSLog(@"%@", [self.htmlView stringByEvaluatingJavaScriptFromString:@"findTextAtRow(4);"]);

    CGRect rect = CGRectMake(self.contentViewController.webView.bounds.size.width/2, self.contentViewController.webView.bounds.size.height, 1, 1);
    
    if(self.dictionaryPopoverController != nil) {
        if ([self.dictionaryPopoverController isPopoverVisible]) {
            [self.dictionaryPopoverController dismissPopoverAnimated:YES];
        } else {
            [self dismissAllPopoverControllers];
            
            [self.dictionaryPopoverController presentPopoverFromRect:rect inView:self.contentViewController.webView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
            self.dictionaryListViewController.searchBar.text = selection;
            [self.dictionaryListViewController handleSearchForTerm:selection];                        
        }
    } else {
        DictionaryListViewController *controller = [[DictionaryListViewController alloc]
                                                    initWithNibName:@"DictionaryListView_iPad"
                                                    bundle:nil];        
        self.dictionaryListViewController = controller;
        self.dictionaryListViewController.title = @"พจนานุกรม บาลี-ไทย";        
        
        UINavigationController *navController = [[UINavigationController alloc] 
                                                 initWithRootViewController:self.dictionaryListViewController];
        UIPopoverController *poc = [[UIPopoverController alloc]
                                    initWithContentViewController:navController];
        [self dismissAllPopoverControllers];
        
        [poc presentPopoverFromRect:rect inView:self.contentViewController.webView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        self.dictionaryListViewController.searchBar.text = selection;        
        [self.dictionaryListViewController handleSearchForTerm:selection];             
        self.dictionaryPopoverController = poc;
        [poc release];
        [controller release];
        [navController release];
    }    
}


#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];    
    [self initScrollViewWithCurrentPage];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *controllers = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < 1000; i++)
    {
        [controllers addObject:[NSNull null]];
    }
    self.viewControllers = controllers;
    [controllers release];                
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithInt:0], @"Thai", 
                          [NSNumber numberWithInt:0], @"Pali",nil];
    self.scrollPostion = dict;
    [dict release];
    
    self.pageSlider.continuous = YES;    
	self.scrollToItem = NO;
    self.scrollToKeyword = NO;    
    self.pageSlider.minimumValue = 1;    
    self.toastText.hidden = YES;
    
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    [self reloadData];
    self.fontSize = [[self.dataDictionary valueForKey:@"FontSize"] intValue];
    
    UIMenuItem *dictionaryMenuItem = [[UIMenuItem alloc] initWithTitle:@"บาลี-ไทย" 
                                                                action:@selector(lookUpDictionary:)];    
    [UIMenuController sharedMenuController].menuItems = [NSArray arrayWithObject:dictionaryMenuItem];
    [dictionaryMenuItem release];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.titleLabel = nil;
    self.pageNumberLabel = nil;
    self.contentView = nil;
    self.dataDictionary = nil;
    self.keywords = nil;
    self.scrollPostion = nil;
    self.pageSlider = nil;
    self.toastText = nil;
    self.scrollView = nil;
    self.viewControllers = nil;
    self.dictionaryPopoverController = nil;
    self.dictionaryListViewController = nil;
}

- (BOOL) canBecomeFirstResponder {
    return YES;
}



@end
