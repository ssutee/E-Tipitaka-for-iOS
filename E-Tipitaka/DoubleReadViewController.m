//
//  DoubleReadViewController.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DoubleReadViewController.h"
#import "ReadViewController.h"
#import "Utils.h"
#import "Item.h"
#import "Content.h"

@implementation DoubleReadViewController

@synthesize sourceLanguage;
@synthesize targetLanguage;
@synthesize keyword;
@synthesize webview1;
@synthesize webview2;
@synthesize slider1;
@synthesize slider2;
@synthesize pageLabel1;
@synthesize pageLabel2;
@synthesize titleLabel1;
@synthesize titleLabel2;
@synthesize backButton1;
@synthesize nextButton1;
@synthesize compareButton1;
@synthesize returnButton1;
@synthesize headerButton1;
@synthesize backButton2;
@synthesize nextButton2;
@synthesize compareButton2;
@synthesize returnButton2;
@synthesize mappingTable;
@synthesize headerButton2;
@synthesize itemOptionsActionSheet;
@synthesize scrollToItem;
@synthesize savedItemNumber;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [mappingTable release];
    [sourceLanguage release];
    [targetLanguage release];
    [keyword release];
    [webview1 release];
    [webview2 release];
    [slider1 release];
    [slider2 release];
    [pageLabel1 release];
    [titleLabel1 release];
    [pageLabel2 release];
    [titleLabel2 release];
    [backButton1 release];
    [nextButton1 release];
    [compareButton1 release];
    [returnButton1 release];
    [backButton2 release];
    [nextButton2 release];
    [compareButton2 release];
    [returnButton2 release];
    [headerButton1 release];
    [headerButton2 release];
    [itemOptionsActionSheet release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) updatePage:(NSString *)language withKeyword:(NSString *)term
{
    NSDictionary *dict = [Utils readData];
    
    NSNumber *volume = [[dict valueForKey:language] valueForKey:@"Volume"];
    NSNumber *page = [[dict valueForKey:language] valueForKey:@"Page"];
    NSNumber *fontSize = [dict valueForKey:@"FontSize"];
    
    NSDictionary *map = [mappingTable valueForKey:language];
    
    UISlider *slider = [map valueForKey:@"slider"];
    UIWebView *webview = [map valueForKey:@"webview"];
    UILabel *pageLabel = [map valueForKey:@"pageLabel"];
    UILabel *titleLabel = [map valueForKey:@"titleLabel"];
    UIBarButtonItem *headerButton = [map valueForKey:@"headerButton"];
    
    
    NSString *newTitle = [ReadViewController createHeaderTitle:volume];          
    
    headerButton.title = [Utils arabic2thai:newTitle];
    
    [ReadViewController updateReadingPage:term 
                                   slider:slider 
                                  webview:webview 
                               titleLabel:titleLabel 
                                pageLabel:pageLabel 
                                 fontSize:[fontSize intValue] 
                                 language:language 
                                   volume:volume 
                                     page:page];
}

- (void) updatePage:(NSString *)language
{
    [self updatePage:language withKeyword:nil];
}

- (void) updatePages
{
    [self updatePage:sourceLanguage withKeyword:keyword];
    [self updatePage:targetLanguage];
}

-(void) showItemOptionsFrom:(UIBarButtonItem *)button withItems:(NSArray *)items 
                     andTag:(NSInteger)tagNumber andTitle:(NSString *)titleName {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
	actionSheet.title = titleName;
	actionSheet.delegate = self;
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.tag = tagNumber;
    
	for (Item *item in items) {
		[actionSheet addButtonWithTitle:
         [Utils arabic2thai:
          [NSString stringWithFormat:@"ข้อที่ %@", item.number]]];
	}
    
	[actionSheet addButtonWithTitle:@"ยกเลิก"];
	[actionSheet setCancelButtonIndex:[items count]];
    
    if ([itemOptionsActionSheet isVisible]) {
        [itemOptionsActionSheet dismissWithClickedButtonIndex:
         [itemOptionsActionSheet cancelButtonIndex] animated:YES];
    }    
    
    [actionSheet showFromBarButtonItem:button animated:YES];
    self.itemOptionsActionSheet = actionSheet;
	[actionSheet release];
}

-(void) doCompare:(NSInteger)buttonIndex from:(NSString *)fromLanguage to:(NSString *)toLanguage
{
    NSDictionary *dict = [Utils readData];
    
	NSNumber *volume = [[dict valueForKey:fromLanguage] valueForKey:@"Volume"];
	NSNumber *page = [[dict valueForKey:fromLanguage] valueForKey:@"Page"];			
	
	NSArray *items = [ReadViewController getItems:fromLanguage forVolume:volume 
                                          forPage:page onlyBegin:YES];
	Item *selectedItem = nil;
	if (items && [items count] > 0) {
		selectedItem = [items objectAtIndex:buttonIndex];
	} else {
		items = [ReadViewController getItems:fromLanguage forVolume:volume forPage:page onlyBegin:NO];
		if (items && [items count] > 0) {
			selectedItem = [items objectAtIndex:buttonIndex];
		}
	}
	
	if (selectedItem) {
		NSArray *comparedItems;
		
		comparedItems = [ReadViewController getItems:toLanguage 
                                           forVolume:volume 
                                           forNumber:selectedItem.number 
                                          forSection:selectedItem.section];
		
		if (comparedItems && [comparedItems count] > 0) {
			Item *comparedItem = [comparedItems objectAtIndex:0];
            savedItemNumber = [comparedItem.number intValue];
            scrollToItem = YES;
            [[dict valueForKey:toLanguage] setValue:volume 
                                                 forKey:@"Volume"];
            [[dict valueForKey:toLanguage] setValue:comparedItem.content.page
                                                           forKey:@"Page"];
            [Utils writeData:dict];
            [self updatePage:toLanguage];
        } else {
            NSString *message = [[NSString alloc] initWithFormat:@"ไม่พบข้อที่ %@", selectedItem.number];                
            NSString *title = nil;
            
            UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,20,260,95)]; 
            textLabel.font = [UIFont systemFontOfSize:18];
            textLabel.textColor = [UIColor whiteColor];
            textLabel.textAlignment = UITextAlignmentCenter;
            textLabel.backgroundColor = [UIColor clearColor];            
            textLabel.text = [Utils arabic2thai:message];
            
            if ([fromLanguage isEqualToString:@"Thai"]) {
                title = [[NSString alloc] initWithFormat:@"พระไตรปิฎก เล่มที่ %@ (ภาษาบาลี)", volume];                
            } else if ([fromLanguage isEqualToString:@"Pali"]) {
                title = [[NSString alloc] initWithFormat:@"พระไตรปิฎก เล่มที่ %@ (ภาษาไทย)", volume];                
            }
            
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:[Utils arabic2thai:title] 
                                                             message:@"\n\n"
                                                            delegate:self cancelButtonTitle:@"ตกลง" 
                                                   otherButtonTitles:nil] autorelease];
            [alert addSubview:textLabel];
            [textLabel release];
            [message release];
            [title release];
            [alert show];            
        }
	}

}

#pragma mark - IBAction

- (IBAction) returnToRead:(id)sender {
    UIBarButtonItem *returnButton = (UIBarButtonItem *)sender;

    NSDictionary *dict = [Utils readData];
    
    if (returnButton.tag == 1) {
        [dict setValue:sourceLanguage forKey:@"Language"];
    } else if (returnButton.tag == 2) {
        [dict setValue:targetLanguage forKey:@"Language"];        
    }
    
    [Utils writeData:dict];
    
    if ([itemOptionsActionSheet isVisible]) {
        [itemOptionsActionSheet dismissWithClickedButtonIndex:
         [itemOptionsActionSheet cancelButtonIndex] animated:YES];
    }     
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction) next:(id)sender
{
    scrollToItem = NO;
    NSDictionary *dict = [Utils readData];
    UIBarButtonItem *nextButton = (UIBarButtonItem *)sender;
    NSNumber *page, *volume;
    NSInteger maxPage = 0;
    if (nextButton.tag == 1) {
        volume = [[dict valueForKey:sourceLanguage] valueForKey:@"Volume"];
        page = [[dict valueForKey:sourceLanguage] valueForKey:@"Page"];        
        maxPage = [ReadViewController getMaximumPageValue:sourceLanguage ofVolume:volume];
        
        if ([page intValue]+1 <= maxPage) {
            [[dict valueForKey:sourceLanguage] setValue:[NSNumber numberWithInt:[page intValue]+1] 
                                                 forKey:@"Page"];
        }
        [Utils writeData:dict];
        [self updatePage:sourceLanguage withKeyword:keyword];
    } else if(nextButton.tag == 2) {
        volume = [[dict valueForKey:targetLanguage] valueForKey:@"Volume"];
        page = [[dict valueForKey:targetLanguage] valueForKey:@"Page"];             
        maxPage = [ReadViewController getMaximumPageValue:targetLanguage ofVolume:volume];
        
        if ([page intValue]+1 <= maxPage) {
            [[dict valueForKey:targetLanguage] setValue:[NSNumber numberWithInt:[page intValue]+1] 
                                                 forKey:@"Page"];
        }
        [Utils writeData:dict];
        [self updatePage:targetLanguage];
    }
}

-(IBAction) back:(id)sender
{
    scrollToItem = NO;
    NSDictionary *dict = [Utils readData];
    UIBarButtonItem *backButton = (UIBarButtonItem *)sender;
    NSNumber *page, *volume;
    if (backButton.tag == 1) {
        volume = [[dict valueForKey:sourceLanguage] valueForKey:@"Volume"];
        page = [[dict valueForKey:sourceLanguage] valueForKey:@"Page"];        
        
        if ([page intValue]-1 >= 1) {
            [[dict valueForKey:sourceLanguage] setValue:[NSNumber numberWithInt:[page intValue]-1] 
                                                 forKey:@"Page"];
        }
        [Utils writeData:dict];
        [self updatePage:sourceLanguage withKeyword:keyword];
    } else if(backButton.tag == 2) {
        volume = [[dict valueForKey:targetLanguage] valueForKey:@"Volume"];
        page = [[dict valueForKey:targetLanguage] valueForKey:@"Page"];             
        
        if ([page intValue]-1 >= 1) {
            [[dict valueForKey:targetLanguage] setValue:[NSNumber numberWithInt:[page intValue]-1] 
                                                 forKey:@"Page"];
        }
        [Utils writeData:dict];
        [self updatePage:targetLanguage];
    } 
}

-(IBAction) sliderValueChanged:(id)sender
{
    scrollToItem = NO;
    UISlider *slider = (UISlider *)sender;
    NSDictionary *dict = [Utils readData];

    NSNumber *volume;
    NSNumber *page = [NSNumber numberWithInt: round(slider.value)];    
    
    UILabel *titleLabel, *pageLabel;
    
    if (slider.tag == 1) {
        volume = [[dict valueForKey:sourceLanguage] valueForKey:@"Volume"];
        [[dict valueForKey:sourceLanguage] setValue:page forKey:@"Page"];
        [Utils writeData:dict];
        titleLabel = [[mappingTable valueForKey:sourceLanguage] valueForKey:@"titleLabel"];
        pageLabel = [[mappingTable valueForKey:sourceLanguage] valueForKey:@"pageLabel"];
        [ReadViewController updatePageTitle:sourceLanguage volume:volume page:page 
                                     slider:slider titleLabel:titleLabel pageLabel:pageLabel];         
    } else if(slider.tag == 2) {
        volume = [[dict valueForKey:targetLanguage] valueForKey:@"Volume"];        
        [[dict valueForKey:targetLanguage] setValue:page forKey:@"Page"];        
        [Utils writeData:dict];        
        titleLabel = [[mappingTable valueForKey:targetLanguage] valueForKey:@"titleLabel"];
        pageLabel = [[mappingTable valueForKey:targetLanguage] valueForKey:@"pageLabel"];
        [ReadViewController updatePageTitle:targetLanguage volume:volume page:page 
                                     slider:slider titleLabel:titleLabel pageLabel:pageLabel];         
    }
}

-(IBAction) startUpdatingPage:(id)sender
{
    scrollToItem = NO;
    UISlider *slider = (UISlider *)sender;
    
    if (slider.tag == 1) {
        [self updatePage:sourceLanguage withKeyword:keyword];
    } else if (slider.tag == 2) {
        [self updatePage:targetLanguage];
    }
}

-(IBAction) compare:(id)sender
{
    UIBarButtonItem * compareButton = (UIBarButtonItem *)sender;
    NSString *fromLanguage;

    if (compareButton.tag == 1) {
        fromLanguage = sourceLanguage;
    } else if (compareButton.tag == 2) {
        fromLanguage = targetLanguage;
    }
    
    NSDictionary *dict = [Utils readData];
    
    NSNumber *volume = [[dict valueForKey:fromLanguage] valueForKey:@"Volume"];
    NSNumber *page = [[dict valueForKey:fromLanguage] valueForKey:@"Page"];
    
    NSArray *items = [ReadViewController getItems:fromLanguage forVolume:volume 
                                          forPage:page onlyBegin:YES];
    if (items && [items count] > 0) {
        [self showItemOptionsFrom:compareButton withItems:items andTag:compareButton.tag 
                         andTitle:@"โปรดเลือกข้อที่ต้องการเทียบเคียง"];
    } else {
        items = [ReadViewController getItems:fromLanguage forVolume:volume forPage:page onlyBegin:NO];
        if (items && [items count] > 0) {
            [self showItemOptionsFrom:compareButton withItems:items andTag:compareButton.tag 
                             andTitle:@"โปรดเลือกข้อที่ต้องการเทียบเคียง"];
        }
    }    
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
//    mWindow = (TapDetectingWindow *)[[UIApplication sharedApplication].windows objectAtIndex:0];
//    mWindow.viewToObserve = self.view;
//    mWindow.controllerThatObserves = self;    
    
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    if (self.sourceLanguage == nil || self.targetLanguage == nil) {
        self.sourceLanguage = @"Thai";
        self.targetLanguage = @"Pali";
    }
    
    self.slider1.tag = 1;
    self.webview1.tag = 1;
    self.webview1.delegate = self;
    NSDictionary *map1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          webview1, @"webview",
                          slider1, @"slider", 
                          pageLabel1, @"pageLabel",
                          titleLabel1, @"titleLabel",
                          headerButton1, @"headerButton",                          
                          backButton1, @"backButton",
                          nextButton1, @"nextButton",
                          compareButton1, @"compareButton",
                          returnButton1, @"returnButton", nil];
    self.slider2.tag = 2;
    self.webview2.tag = 2;
    self.webview2.delegate = self;
    NSDictionary *map2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          webview2, @"webview",
                          slider2, @"slider", 
                          pageLabel2, @"pageLabel",
                          titleLabel2, @"titleLabel",
                          headerButton2, @"headerButton",                                                    
                          backButton2, @"backButton",
                          nextButton2, @"nextButton",
                          compareButton2, @"compareButton",
                          returnButton2, @"returnButton", nil];

    NSDictionary *dict = [[NSDictionary alloc] 
                                 initWithObjectsAndKeys:map1, sourceLanguage, map2, targetLanguage, nil];

    self.mappingTable = dict;
    
    [self updatePages];
    
    [dict release];
    [map1 release];
    [map2 release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.mappingTable = nil;
    self.sourceLanguage = nil;
    self.targetLanguage = nil;
    self.keyword = nil;
    self.webview1 = nil;
    self.webview2 = nil;
    self.slider1 = nil;
    self.slider2 = nil;
    self.pageLabel1 = nil;
    self.pageLabel2 = nil;
    self.titleLabel1 = nil;
    self.titleLabel2 = nil;
    self.backButton1 = nil;
    self.nextButton1 = nil;
    self.compareButton1 = nil;
    self.returnButton1 = nil;    
    self.backButton2 = nil;
    self.nextButton2 = nil;
    self.compareButton2 = nil;
    self.returnButton2 = nil;    
    self.headerButton1 = nil;
    self.headerButton2 = nil;
    self.itemOptionsActionSheet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


#pragma mark -
#pragma mark Action Sheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) {
        [self doCompare:buttonIndex from:sourceLanguage to:targetLanguage];
    } else if (actionSheet.tag == 2) {
        [self doCompare:buttonIndex from:targetLanguage to:sourceLanguage];
    }    
}


#pragma mark - 
#pragma mark Web View Delegate Methods 

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (scrollToItem) {
		[webView stringByEvaluatingJavaScriptFromString:
		 [NSString stringWithFormat:
		  @"var item = document.getElementById(\"i%d\"); \n"
		  " if(item) { \n"
		  "    ScrollToElement(item); \n"
		  " }", savedItemNumber
		  ]];
	}    
}



//#pragma mark -
//#pragma mark Tap Detecting Window Delegate Methods
//
//- (void) userDidTapView:(id)tapPoint {
//    NSLog(@"%@",tapPoint);
//}

@end

