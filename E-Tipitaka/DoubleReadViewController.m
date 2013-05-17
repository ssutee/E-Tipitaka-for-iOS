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
#import "ContentInfo.h"
#import "QueryHelper.h"

@implementation DoubleReadViewController

@synthesize sourceLanguage;
@synthesize targetLanguage;
@synthesize keywords;
@synthesize compareButton1;
@synthesize returnButton1;
@synthesize headerButton1;
@synthesize compareButton2;
@synthesize returnButton2;
@synthesize mappingTable;
@synthesize headerButton2;
@synthesize itemOptionsActionSheet;
@synthesize scrollToItem;
@synthesize savedItemNumber;

@synthesize sourceController=_sourceController;
@synthesize targetController=_targetController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

//- (void) updatePage:(NSString *)language withKeyword:(NSString *)term
//{
//    NSDictionary *dict = [Utils readData];
//    
//    NSNumber *volume = [[dict valueForKey:language] valueForKey:@"Volume"];
//    NSNumber *page = [[dict valueForKey:language] valueForKey:@"Page"];
//    NSNumber *fontSize = [dict valueForKey:@"FontSize"];
//    
//    NSDictionary *map = [mappingTable valueForKey:language];
//    
//    UISlider *slider = [map valueForKey:@"slider"];
//    UIWebView *webview = [map valueForKey:@"webview"];
//    UILabel *pageLabel = [map valueForKey:@"pageLabel"];
//    UILabel *titleLabel = [map valueForKey:@"titleLabel"];
//    UIBarButtonItem *headerButton = [map valueForKey:@"headerButton"];
//    
//    
//    NSString *newTitle = [ReadViewController createHeaderTitle:volume];          
//    
//    headerButton.title = [Utils arabic2thai:newTitle];
//    
//    [ReadViewController updateReadingPage:term 
//                                   slider:slider 
//                                  webview:webview 
//                               titleLabel:titleLabel 
//                                pageLabel:pageLabel 
//                                 fontSize:[fontSize intValue] 
//                                 language:language 
//                                   volume:volume 
//                                     page:page];
//}

//- (void) updatePage:(NSString *)language
//{
//    [self updatePage:language withKeyword:nil];
//}
//
//- (void) updatePages
//{
//    [self updatePage:sourceLanguage withKeyword:keyword];
//    [self updatePage:targetLanguage];
//}

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
}

-(void) doCompare:(NSInteger)buttonIndex from:(NSString *)fromLanguage to:(NSString *)toLanguage inLanguage:(NSInteger)side
{
    NSDictionary *dict = [Utils readData];
    
	NSNumber *volume = [[dict valueForKey:fromLanguage] valueForKey:@"Volume"];
	NSNumber *page = [[dict valueForKey:fromLanguage] valueForKey:@"Page"];			
	
    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = fromLanguage;
    info.volume = volume;
    info.page = page;
    info.begin = YES;
    [info setType:LANGUAGE|VOLUME|PAGE|BEGIN];
    
	NSArray *items = [QueryHelper getItems:info];
	Item *selectedItem = nil;
	if (items && [items count] > 0) {
		selectedItem = [items objectAtIndex:buttonIndex];
	} else {
        info.begin = NO;
		items = [QueryHelper getItems:info];
		if (items && [items count] > 0) {
			selectedItem = [items objectAtIndex:buttonIndex];
		}
	}
	
	if (selectedItem) {
		NSArray *comparedItems;
		info.language = toLanguage;
        info.volume = volume;
        info.itemNumber = selectedItem.number;
        info.section = selectedItem.section;
        [info setType:LANGUAGE|VOLUME|ITEM_NUMBER|SECTION];
		comparedItems = [QueryHelper getItems:info];
		if (comparedItems && [comparedItems count] > 0) {
			Item *comparedItem = [comparedItems objectAtIndex:0];
            savedItemNumber = [comparedItem.number intValue];
            scrollToItem = YES;
            [[dict valueForKey:toLanguage] setValue:volume 
                                                 forKey:@"Volume"];
            [[dict valueForKey:toLanguage] setValue:comparedItem.content.page
                                                           forKey:@"Page"];
            [Utils writeData:dict];
            
            if (side == kSourceLanguageSide) {
                [self.targetController reloadData];
                self.targetController.savedItemNumber = savedItemNumber;
                self.targetController.scrollToItem = YES;
                [self.targetController updateReadingPage];
            } 
            else if (side == kTargetLanguageSide) {
                [self.sourceController reloadData];
                self.sourceController.savedItemNumber = savedItemNumber;                
                self.sourceController.scrollToItem = YES;
                [self.sourceController updateReadingPage];                
            }
            
            
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
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Utils arabic2thai:title] 
                                                             message:@"\n\n"
                                                            delegate:self cancelButtonTitle:@"ตกลง" 
                                                   otherButtonTitles:nil];
            [alert addSubview:textLabel];
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


-(IBAction) compare:(id)sender
{
    UIBarButtonItem * compareButton = (UIBarButtonItem *)sender;
    NSString *fromLanguage = nil;

    if (compareButton.tag == 1) {
        fromLanguage = sourceLanguage;
    } else if (compareButton.tag == 2) {
        fromLanguage = targetLanguage;
    }
    
    NSDictionary *dict = [Utils readData];
    
    NSNumber *volume = [[dict valueForKey:fromLanguage] valueForKey:@"Volume"];
    NSNumber *page = [[dict valueForKey:fromLanguage] valueForKey:@"Page"];

    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = fromLanguage;
    info.volume = volume;
    info.page = page;
    info.begin = YES;
    [info setType:LANGUAGE|VOLUME|PAGE|BEGIN];
        
    NSArray *items = [QueryHelper getItems:info];
    if (items && [items count] > 0) {
        [self showItemOptionsFrom:compareButton withItems:items andTag:compareButton.tag 
                         andTitle:@"โปรดเลือกข้อที่ต้องการเทียบเคียง"];
    } 
    else {
        info.begin = NO;        
        items = [QueryHelper getItems:info];
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
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGRect frame = self.view.frame;    
    self.sourceController.view.frame = CGRectMake(0, 0, (frame.size.width/2)-1, frame.size.height);
    self.targetController.view.frame = CGRectMake((frame.size.width/2)+1, 0, (frame.size.width/2)-1, frame.size.height);    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];    
    
    CGRect frame = self.view.frame;    
    self.sourceController.view.frame = CGRectMake(0, 0, (frame.size.width/2)-1, frame.size.height);
    self.targetController.view.frame = CGRectMake((frame.size.width/2)+1, 0, (frame.size.width/2)-1, frame.size.height);    
    
    
    [self.view addSubview:self.sourceController.view];
    [self.view addSubview:self.targetController.view];
    
    if (self.sourceLanguage == nil || self.targetLanguage == nil) {
        self.sourceLanguage = @"Thai";
        self.targetLanguage = @"Pali";
    }
    
    [self.sourceController setCurrentLanguage:self.sourceLanguage];
    [self.targetController setCurrentLanguage:self.targetLanguage];
    
    self.sourceController.scrollToItem = YES;
    self.sourceController.savedItemNumber = self.savedItemNumber;
    self.targetController.scrollToItem = YES;
    self.targetController.savedItemNumber = self.savedItemNumber;
    
    self.sourceController.keywords = self.keywords;
    
    self.compareButton1.tag = kSourceLanguageSide;
    self.compareButton2.tag = kTargetLanguageSide;
    
    
    NSDictionary *map1 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          headerButton1, @"headerButton",                          
                          compareButton1, @"compareButton",
                          returnButton1, @"returnButton", nil];
    NSDictionary *map2 = [[NSDictionary alloc] initWithObjectsAndKeys:
                          headerButton2, @"headerButton",                                                    
                          compareButton2, @"compareButton",
                          returnButton2, @"returnButton", nil];

    NSDictionary *dict = [[NSDictionary alloc] 
                                 initWithObjectsAndKeys:map1, sourceLanguage, map2, targetLanguage, nil];

    self.mappingTable = dict;
    
    [self.sourceController reloadData];
    [self.targetController reloadData];
    
    [self.sourceController initScrollViewWithCurrentPage];
    [self.targetController initScrollViewWithCurrentPage];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.mappingTable = nil;
    self.sourceLanguage = nil;
    self.targetLanguage = nil;
    self.keywords = nil;
    self.compareButton1 = nil;
    self.returnButton1 = nil;    
    self.compareButton2 = nil;
    self.returnButton2 = nil;    
    self.headerButton1 = nil;
    self.headerButton2 = nil;
    self.itemOptionsActionSheet = nil;
    
    self.sourceController = nil;
    self.targetController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
//    return YES;
}

- (BOOL)shouldAutorotate {
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    return UIInterfaceOrientationIsLandscape(orientation);
}

#pragma mark -
#pragma mark Action Sheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kSourceLanguageSide) {
        [self doCompare:buttonIndex from:sourceLanguage to:targetLanguage inLanguage:kSourceLanguageSide];
    } else if (actionSheet.tag == kTargetLanguageSide) {
        [self doCompare:buttonIndex from:targetLanguage to:sourceLanguage inLanguage:kTargetLanguageSide];
    }    
}


@end

