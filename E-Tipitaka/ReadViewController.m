//
//  ReadViewController.m
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ReadViewController.h"
#import "DoubleReadViewController.h"
#import "E_TipitakaAppDelegate.h"
#import "BookListTableViewController.h"
#import "BookmarkAddViewController.h"
#import "BookmarkListViewController.h"
#import "SearchViewController.h"
#import "Item.h"
#import "Utils.h"
#import "Content.h"

//@interface ReadViewController ()
//@property (nonatomic, retain) UIPopoverController *popoverController;
////- (void)configureView;
//@end

@implementation ReadViewController

@synthesize toolbar;
@synthesize titleLabel;
@synthesize pageNumberLabel;
@synthesize htmlView;
@synthesize dataDictionary;
//@synthesize pagesDictionary;
//@synthesize itemsDictionary;
@synthesize alterItems;
@synthesize keywords;
@synthesize scrollToItem;
@synthesize scrollToKeyword;
@synthesize savedItemNumber;
@synthesize fontSize;
//@synthesize popoverController=_myPopoverController;
@synthesize detailItem=_detailItem;
@synthesize searchPopoverController=_searchPopoverController;
@synthesize bookmarkPopoverController=_bookmarkPopoverController;
@synthesize booklistPopoverController;
@synthesize searchButton;
@synthesize languageButton;
@synthesize booklistButton;
@synthesize gotoButton;
@synthesize noteButton;
@synthesize bookmarkButton;
@synthesize titleButton;
@synthesize languageActionSheet;
@synthesize gotoActionSheet;
@synthesize itemOptionsActionSheet;
@synthesize toastText;
@synthesize pageSlider;
@synthesize bottomToolbar;
//@synthesize indicator;

#pragma mark - Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
//- (void)setDetailItem:(id)newDetailItem
//{
//    if (_detailItem != newDetailItem) {
//        [_detailItem release];
//        _detailItem = [newDetailItem retain];
//        
//        // Update the view.
//        [self configureView];
//    }
//    
//    if (self.popoverController != nil) {
//        [self.popoverController dismissPopoverAnimated:YES];
//    }
//    
//    if(_searchPopoverController != nil) {
//        [_searchPopoverController dismissPopoverAnimated:YES];
//    }
//}

//- (void)configureView
//{
//    // Update the user interface for the detail item.
//    
//    // TODO 
//}

//#pragma mark - Split view support

//- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController: (UIPopoverController *)pc
//{
//    barButtonItem.title = @"เลือก";
//    NSMutableArray *items = [[self.toolbar items] mutableCopy];
//    [items insertObject:barButtonItem atIndex:0];
//    [self.toolbar setItems:items animated:YES];
//    [items release];
//    self.popoverController = pc;
//}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
//- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
//{
//    NSMutableArray *items = [[self.toolbar items] mutableCopy];
//    [items removeObjectAtIndex:0];
//    [self.toolbar setItems:items animated:YES];
//    [items release];
//    self.popoverController = nil;
//}
//
//- (void)splitViewController:(UISplitViewController*)svc popoverController:(UIPopoverController*)pc willPresentViewController:(UIViewController *)aViewController
//{
//    [self dismissAllPopoverControllers];
//}

#pragma mark - General Methods

-(void) gotoItem {
	NSString *language = [dataDictionary valueForKey:@"Language"];
	NSMutableDictionary *dict = [dataDictionary valueForKey:language];	
	NSNumber *volume = [dict valueForKey:@"Volume"];	
	
	UIAlertView *itemAlert = [[UIAlertView alloc] initWithTitle:@"ใส่ข้อที่ต้องการ" 
														message:@"\n\n\n"
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"ยกเลิก",nil) 
											  otherButtonTitles:NSLocalizedString(@"ตกลง",nil), nil];
	itemAlert.tag = kGotoItemAlert;
	
	UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,40,260,25)];
	itemLabel.font = [UIFont systemFontOfSize:18];
	itemLabel.textColor = [UIColor whiteColor];
	itemLabel.backgroundColor = [UIColor clearColor];
	itemLabel.shadowColor = [UIColor blackColor];
	itemLabel.shadowOffset = CGSizeMake(0,-1);
	itemLabel.textAlignment = UITextAlignmentCenter;
	
	
	itemLabel.text = [Utils arabic2thai:[NSString stringWithFormat:@"ตั้งแต่ข้อที่ ๑ ถึง %d", 
										 [ReadViewController getMaximumItemValue:language 
                                                                        ofVolume:volume]]];
	[itemAlert addSubview:itemLabel];
	
	UIImageView *itemImage = [[UIImageView alloc] 
							  initWithImage:[UIImage 
											 imageWithContentsOfFile:[[NSBundle mainBundle] 
																	  pathForResource:@"passwordfield" ofType:@"png"]]];
	itemImage.frame = CGRectMake(11,79,262,31);
	[itemAlert addSubview:itemImage];
    
    UITextField *itemField = [UITextField alloc];
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        [itemField initWithFrame:CGRectMake(16, 83, 252, 25)];
    }
    else {
        [itemField initWithFrame:CGRectMake(16, 68, 252, 25)];
    }
    
	itemField.font = [UIFont systemFontOfSize:18];
	itemField.backgroundColor = [UIColor whiteColor];
	itemField.secureTextEntry = NO;
	itemField.keyboardAppearance = UIKeyboardAppearanceAlert;
	itemField.keyboardType = UIKeyboardTypeNumberPad;
	itemField.delegate = self;
	[itemField becomeFirstResponder];
	[itemAlert addSubview:itemField];
	
	[itemAlert setTransform:CGAffineTransformMakeTranslation(0,0)];
	[itemAlert show];
	[itemAlert release];
	[itemField release];
	[itemImage release];
	[itemLabel release];	
}

-(void) gotoPage {
	NSString *language = [dataDictionary valueForKey:@"Language"];
	NSMutableDictionary *dict = [dataDictionary valueForKey:language];	
	NSNumber *volume = [dict valueForKey:@"Volume"];	
	
	UIAlertView *pageAlert = [[UIAlertView alloc] initWithTitle:@"ใส่หน้าที่ต้องการ" 
														message:@"\n\n\n"
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"ยกเลิก",nil) 
											  otherButtonTitles:NSLocalizedString(@"ตกลง",nil), nil];
	pageAlert.tag = kGotoPageAlert;
	
	UILabel *pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(12,40,260,25)];
	pageLabel.font = [UIFont systemFontOfSize:18];
	pageLabel.textColor = [UIColor whiteColor];
	pageLabel.backgroundColor = [UIColor clearColor];
	pageLabel.shadowColor = [UIColor blackColor];
	pageLabel.shadowOffset = CGSizeMake(0,-1);
	pageLabel.textAlignment = UITextAlignmentCenter;
	
	
	pageLabel.text = [Utils arabic2thai:[NSString stringWithFormat:@"ตั้งแต่หน้าที่ ๑ ถึง %d", 
                                         [ReadViewController getMaximumPageValue:language 
                                                                        ofVolume:volume]]];
	[pageAlert addSubview:pageLabel];
	
	UIImageView *pageImage = [[UIImageView alloc] 
							  initWithImage:[UIImage 
											 imageWithContentsOfFile:
                                             [[NSBundle mainBundle] 
                                              pathForResource:@"passwordfield" ofType:@"png"]]];
    
	pageImage.frame = CGRectMake(11,79,262,31);
	[pageAlert addSubview:pageImage];
		
    UITextField *pageField = [UITextField alloc];
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        [pageField initWithFrame:CGRectMake(16, 83, 252, 25)];
    }
    else {
        [pageField initWithFrame:CGRectMake(16, 68, 252, 25)];
    }
    
	pageField.font = [UIFont systemFontOfSize:18];
	pageField.backgroundColor = [UIColor whiteColor];
	pageField.secureTextEntry = NO;
	pageField.keyboardAppearance = UIKeyboardAppearanceAlert;
	pageField.keyboardType = UIKeyboardTypeNumberPad;
	pageField.delegate = self;
	[pageField becomeFirstResponder];
	[pageAlert addSubview:pageField];
	
	[pageAlert setTransform:CGAffineTransformMakeTranslation(0,0)];
	[pageAlert show];
	[pageAlert release];
	[pageField release];
	[pageImage release];
	[pageLabel release];	
}

+(NSArray *) getContents:(NSString *)language forVolume:(NSNumber *)volume {
	return [ReadViewController getContents:language forVolume:volume forPage:nil];
}

+(NSArray *) getContents:(NSString *) language forVolume:(NSNumber *)volume forPage:(NSNumber *)page {
	E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];	
	
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"Content" 
								   inManagedObjectContext:context];	
	[fetchRequest setEntity:entity];
	
	NSPredicate *pred;
	
	if (page == nil) {
		pred = [NSPredicate 
				 predicateWithFormat:@"(lang = %@ && volume = %d)",
				 [language lowercaseString], [volume intValue]];
	} else {
		pred = [NSPredicate 
				 predicateWithFormat:@"(lang = %@ && volume = %d && page = %d)",
				 [language lowercaseString], [volume intValue], [page intValue]];
	}
	
	[fetchRequest setPredicate:pred];
	
	NSError *error;
        
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
	return fetchedObjects;
}

-(NSArray *) getItems:(NSString *)language forVolume:(NSNumber *)volume forNumber:(NSNumber *)number {
	return [self getItems:language forVolume:volume forNumber:number forSection:nil];
}

-(NSArray *) getItems:(NSString *)language forVolume:(NSNumber *)volume forNumber:(NSNumber *)number forSection:(NSNumber *)section {
	E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];	
	
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"Item" 
								   inManagedObjectContext:context];	
	[fetchRequest setEntity:entity];
	
	
	NSPredicate *pred;
	if (section) {
		pred = [NSPredicate 
				predicateWithFormat:@"(number = %d && content.lang = %@ && content.volume = %d && begin = 1 && section = %d)",
				[number intValue],
				[language lowercaseString], 
				[volume intValue],
				[section intValue]];
	} else {
		pred = [NSPredicate 
				predicateWithFormat:@"(number = %d && content.lang = %@ && content.volume = %d && begin = 1)",
				[number intValue],
				[language lowercaseString], 
				[volume intValue]];
	}
	
	[fetchRequest setPredicate:pred];
	
	NSError *error;			
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
		
	return fetchedObjects;
}

-(NSArray *) getItems:(NSString *)language forVolume:(NSNumber *)volume forPage:(NSNumber *)page onlyBegin:(BOOL)begin {
	E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];	
	
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"Item" 
								   inManagedObjectContext:context];	
	[fetchRequest setEntity:entity];
	
	NSPredicate *pred;
	if (page == nil) {
		pred = [NSPredicate 
				predicateWithFormat:@"(content.lang = %@ && content.volume = %d && begin = %d)",
				[language lowercaseString], 
				[volume intValue], begin];		
	} else {
		pred = [NSPredicate 
				predicateWithFormat:@"(content.lang = %@ && content.volume = %d && content.page = %d && begin = %d)",
				[language lowercaseString], 
				[volume intValue],
				[page intValue], begin];		
	}

	
	[fetchRequest setPredicate:pred];
	NSSortDescriptor *sortByNumber = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortByNumber]];
	[sortByNumber release];
	
	NSError *error;			
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
	return fetchedObjects;
}

-(NSArray *) getItems:(NSString *)language forVolume:(NSNumber *)volume onlyBegin:(BOOL)begin {
	return [self getItems:language forVolume:volume forPage:nil onlyBegin:begin];
}

+(NSInteger) getMaximumItemValue:(NSString *)language ofVolume:(NSNumber *)volume {
    NSDictionary *itemsDictionary = [Utils readItems];
    NSInteger n=0;
    for (NSNumber *i in [[itemsDictionary valueForKey:language] objectAtIndex:[volume intValue]-1]) {
        if ([i intValue] > n) {
            n = [i intValue];
        }
    }
	return n;
}

+(NSInteger) getMaximumPageValue:(NSString *)language ofVolume:(NSNumber *)volume {
    NSDictionary *pagesDictionary = [Utils readPages];
    NSInteger n = [[[pagesDictionary valueForKey:language] objectAtIndex:[volume intValue]-1] intValue];
    return n;
}

-(NSArray *) getItemsFromContent:(Content *)content {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	
	for(Item *item in content.items) {
		if ([item.begin boolValue]) {
			[array addObject:item];
		}
	}
	if ([array count] == 0) {
		for (Item *item in content.items) {
			[array addObject:item];
		}
	}
	
	NSSortDescriptor *sortDescriptor;
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	NSArray *sortedItems = [array sortedArrayUsingDescriptors:sortDescriptors];
	
	[sortDescriptor release];
	[array release];
	
	return sortedItems;
	
}

-(void) showItemOptions:(NSArray *)items withTag:(NSInteger)tagNumber withTitle:(NSString *)titleName {
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
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {        
        [actionSheet showFromToolbar:toolbar];
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([self.itemOptionsActionSheet isVisible]) {
            [self.itemOptionsActionSheet dismissWithClickedButtonIndex:
             [self.itemOptionsActionSheet cancelButtonIndex] animated:YES];
        }
        if (tagNumber == kItemOptionsActionSheet) {
            [actionSheet showFromBarButtonItem:gotoButton animated:YES];
        }
        else if (tagNumber == kBookmarkOptionsActionSheet) {
            [actionSheet showFromBarButtonItem:noteButton animated:YES];
        }
    }
    self.itemOptionsActionSheet = actionSheet;
    
	[actionSheet release];
	
}

-(void) updatePageTitle:(NSString *)language volume:(NSNumber *) volume page:(NSNumber *) page {
    NSInteger maxPage = [ReadViewController getMaximumPageValue:language ofVolume:volume];
    
    if (pageSlider.maximumValue != maxPage) {
        pageSlider.maximumValue = maxPage;
    }
    pageSlider.value = [page floatValue];
    
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
	[self updateReadingPage:keywords];
}

-(void) updateReadingPage:(NSString *)query {
	if(!dataDictionary)
		return;

	NSString *language = [dataDictionary valueForKey:@"Language"];
	NSDictionary *dict = [dataDictionary valueForKey:language];
	
	NSNumber *page = [dict valueForKey:@"Page"];
	NSNumber *volume = [dict valueForKey:@"Volume"];
	
    [self updatePageTitle:language volume:volume page:page];
	
	NSString *newTitle = [NSString alloc];
	if([volume intValue] <= 8) {
		newTitle = [newTitle initWithFormat:@"%@ เล่มที่ %d", @"พระวินัยปิฎก", [volume intValue]];
	} else if([volume intValue] <= 33) {
		newTitle = [newTitle initWithFormat:@"%@ เล่มที่ %d", @"พระสุตตันตปิฎก", [volume intValue] - 8];
	} else {
		newTitle = [newTitle initWithFormat:@"%@ เล่มที่ %d", @"พระอภิธรรมปิฎก", [volume intValue] - 33];		
	}

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [(UIButton *)self.navigationItem.titleView setTitle:[Utils arabic2thai:newTitle] forState:UIControlStateNormal];
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        for(UIBarItem *item in self.toolbar.items) {
            if (item.tag == 5) {
                item.title = [Utils arabic2thai:newTitle];
            }
        }
    }
    
	[newTitle release];
	
	NSArray *fetchedObjects = [ReadViewController getContents:language forVolume:volume forPage:page];
	
	if(fetchedObjects == nil) {
		NSLog(@"Whoops, couldn't fetch");
	} else {		
		if ([fetchedObjects count] > 0) {
			Content *content = [fetchedObjects objectAtIndex:0];			
			NSString *text = [content.text stringByReplacingOccurrencesOfString:@"\n"
																	 withString:@"<br>"];
			text = [text stringByReplacingOccurrencesOfString:@"\t" 
												   withString:@"&nbsp;&nbsp;"];
			if(query) {
				self.keywords = [NSString stringWithString:query];
				
				NSArray *tokens = [self.keywords componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				
				for(NSString *token in tokens) {
					token = [token stringByReplacingOccurrencesOfString:@"+" withString:@" "];

                    //must use UTF8 for replacing Thai text
                    const char *orig = [text UTF8String];
                    const char *with = [[NSString 
                                       stringWithFormat:@"<font color=\"#0000FF\" id=\"keywords\" style=\"background-color:yellow;\">%@</font>", token] UTF8String];
                    const char *rep = [token UTF8String];
                    char * result = [Utils replace:orig pattern:rep replacement:with];
                    text = [NSString stringWithUTF8String:result];
                    free(result);
				}
			}
			
			for (Item *item in content.items) {
				if ([item.begin boolValue] == YES) {
					NSString *tmp = [[NSString alloc] initWithFormat:@"[%@]", [Utils arabic2thai:[item.number stringValue]]];
					
					text = [text stringByReplacingOccurrencesOfString:tmp 
														   withString:[NSString
																	   stringWithFormat:@"<font id=\"i%@\" color=\"#FF0000\">%@</font>", item.number, tmp]];
					
					[tmp release];
				}
			}
			
			NSString *html = [[NSString alloc] 
							  initWithFormat:
							  @"<html> \n"
							  "<head> \n"
							  "<style type=\"text/css\"> \n"
							  "body {font-family:arial; font-size:%d; margin: 5; padding: 5;} \n"
							  "</style> \n"
							  "<script> \n"
							  "function ScrollToElement(theElement){ \n"
							  "   var selectedPosX = 0; \n"
							  "	  var selectedPosY = 0; \n"  
							  "   while(theElement != null){ \n"
							  "      selectedPosX += theElement.offsetLeft; \n"
							  "      selectedPosY += theElement.offsetTop; \n"
							  "      theElement = theElement.offsetParent; \n"
							  "   } \n"
							  "   window.scrollTo(selectedPosX,selectedPosY); \n"
							  "} \n"
							  "</script>"
							  "</head> \n"
							  "<body>%@</body> \n"
							  "</html>", self.fontSize, text];
			[htmlView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://www.etipitaka.com"]];
			[html release];
		}
	}
    [Utils writeData:dataDictionary];
}

-(NSString *) convertContenttoHtml:(Content *)content query:(NSString *)query {
    return nil;
}


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

-(void) resetScrollPositions {
	thaiScrollPosition = 0;
	paliScrollPosition = 0;
}

- (void)reloadData {
    self.dataDictionary = [Utils readData];
}

- (void) swapLanguage {
    if (self.dataDictionary == nil) {
        [self reloadData];
    }
    
	NSString *language = [dataDictionary valueForKey:@"Language"];
	NSNumber *paliVolume = [[dataDictionary valueForKey:@"Pali"] valueForKey:@"Volume"];
	NSNumber *thaiVolume = [[dataDictionary valueForKey:@"Thai"] valueForKey:@"Volume"];
	
//    NSLog(@"pali=%@ thai=%@", paliVolume, thaiVolume);
    
	if ([language isEqualToString:@"Thai"]) {
		// save scroll position for Thai
		thaiScrollPosition = [[htmlView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
		// change language to Pali
		[dataDictionary setValue:@"Pali" forKey:@"Language"];
		if ([paliVolume intValue] != [thaiVolume intValue]) {
			// change Pali volume to Thai volume
			[(NSDictionary *)[dataDictionary valueForKey:@"Pali"] 
			 setValue:[NSNumber numberWithInt:[thaiVolume intValue]] forKey:@"Volume"];
		}
	} else {
		// save scroll position for Pali
		paliScrollPosition = [[htmlView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
		// change language to Thai
		[dataDictionary setValue:@"Thai" forKey:@"Language"];
		if ([paliVolume intValue] != [thaiVolume intValue]) {
			// change Thai volume to Pali volume
			[(NSDictionary *)[dataDictionary valueForKey:@"Thai"] 
			 setValue:[NSNumber numberWithInt:[paliVolume intValue]] forKey:@"Volume"];
		}				
	}
	// update page
	[self updateReadingPage];	
}

- (void) compareLanguage {    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        NSString *language = [dataDictionary valueForKey:@"Language"];
        NSNumber *volume = [[dataDictionary valueForKey:language] valueForKey:@"Volume"];
        NSNumber *page = [[dataDictionary valueForKey:language] valueForKey:@"Page"];
        
        NSArray *items = [self getItems:language forVolume:volume forPage:page onlyBegin:YES];
        if (items && [items count] > 0) {
            [self showItemOptions:items 
                          withTag:kItemOptionsActionSheet withTitle:@"โปรดเลือกข้อที่ต้องการเทียบเคียง"];
        } else {
            items = [self getItems:language forVolume:volume forPage:page onlyBegin:NO];
            if (items && [items count] > 0) {
                [self showItemOptions:items 
                              withTag:kItemOptionsActionSheet withTitle:@"โปรดเลือกข้อที่ต้องการเทียบเคียง"];
            }
        }     
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        DoubleReadViewController *controller = [[DoubleReadViewController alloc] 
                                                initWithNibName:@"DoubleReadView_iPad" bundle:nil];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release], controller = nil;     
    }    
}

- (void) doCompare:(NSInteger)buttonIndex {
	NSString *language = [dataDictionary valueForKey:@"Language"];
	NSNumber *volume = [[dataDictionary valueForKey:language] valueForKey:@"Volume"];
	NSNumber *page = [[dataDictionary valueForKey:language] valueForKey:@"Page"];			
	
	NSArray *items = [self getItems:language forVolume:volume forPage:page onlyBegin:YES];
	Item *selectedItem = nil;
	if (items && [items count] > 0) {
		selectedItem = [items objectAtIndex:buttonIndex];
	} else {
		items = [self getItems:language forVolume:volume forPage:page onlyBegin:NO];
		if (items && [items count] > 0) {
			selectedItem = [items objectAtIndex:buttonIndex];
		}
	}
	
	if (selectedItem) {
		NSArray *comparedItems;
		NSString *targetLanguage;
		
		if ([language isEqualToString:@"Thai"]) {
			targetLanguage = @"Pali";
		} else {
			targetLanguage = @"Thai";
		}
		
		comparedItems = [self getItems:targetLanguage 
							 forVolume:volume 
							 forNumber:selectedItem.number 
							forSection:selectedItem.section];
		
		if (comparedItems && [comparedItems count] > 0) {
			Item *comparedItem = [comparedItems objectAtIndex:0];
			savedItemNumber = [comparedItem.number intValue];
			[dataDictionary setValue:targetLanguage forKey:@"Language"];
			[[dataDictionary valueForKey:targetLanguage] setValue:volume 
														   forKey:@"Volume"];
			[[dataDictionary valueForKey:targetLanguage] setValue:comparedItem.content.page
														   forKey:@"Page"];
			self.scrollToItem = YES;
            self.scrollToKeyword = NO;
            
			[self updateReadingPage];
		}
	}	
}

- (void) saveBookmark:(NSInteger)buttonIndex {
	NSString *language = [dataDictionary valueForKey:@"Language"];
	NSNumber *volume = [[dataDictionary valueForKey:language] valueForKey:@"Volume"];
	NSNumber *page = [[dataDictionary valueForKey:language] valueForKey:@"Page"];			
	
	NSArray *items = [self getItems:language forVolume:volume forPage:page onlyBegin:YES];
	if (!items || [items count] == 0) {
		items = [self getItems:language forVolume:volume forPage:page onlyBegin:NO];
	}		
	
	if (items && [items count] > 0) {
		BookmarkAddViewController *controller = [[BookmarkAddViewController alloc] 
												 initWithNibName:@"BookmarkAddViewController" bundle:nil];
		controller.readViewController = self;
		Item *item = [items objectAtIndex:buttonIndex];
		controller.selectedItem = item;
		
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [[self navigationController] pushViewController:controller animated:YES];
        }
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UINavigationController *navController = [[UINavigationController alloc] 
                                                     initWithRootViewController:controller];
            navController.modalInPopover = YES;
            UIPopoverController *poc = [[UIPopoverController alloc]
                                        initWithContentViewController:navController];
            controller.popoverController = poc;
            if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
                [poc presentPopoverFromRect:CGRectMake(309, 82, 151, 29) 
                                     inView:self.view 
                   permittedArrowDirections:UIPopoverArrowDirectionUp 
                                   animated:YES];
            } else {
                [poc presentPopoverFromRect:CGRectMake(277, 82, 151, 29) 
                                     inView:self.view 
                   permittedArrowDirections:UIPopoverArrowDirectionUp 
                                   animated:YES];                
            }
            
            [navController release];
        }

		[controller release], controller = nil;
	}
}

- (void) selectItem:(NSInteger)buttonIndex {
	self.scrollToItem = YES;
    self.scrollToKeyword = NO;
    self.keywords = nil;
    
	Item *item = (Item *)[self.alterItems objectAtIndex:buttonIndex];
	NSString *language = [dataDictionary valueForKey:@"Language"];
	NSMutableDictionary *dict = [dataDictionary valueForKey:language];
	[dict setValue:item.content.page forKey:@"Page"];
	[dataDictionary setValue:dict forKey:language];
	[self updateReadingPage];	
}

- (void) dismissAllPopoverControllers {
//    if (_myPopoverController != nil && [_myPopoverController isPopoverVisible]) {
//        [_myPopoverController dismissPopoverAnimated:YES];
//    }
    if (_searchPopoverController != nil && [_searchPopoverController isPopoverVisible]) {
        [_searchPopoverController dismissPopoverAnimated:YES];
    }
    if (_bookmarkPopoverController != nil && [_bookmarkPopoverController isPopoverVisible]) {
        [_bookmarkPopoverController dismissPopoverAnimated:YES];
    }
    if (booklistPopoverController != nil && [booklistPopoverController isPopoverVisible]) {
        [booklistPopoverController dismissPopoverAnimated:YES];
    }
    if (languageActionSheet != nil && [languageActionSheet isVisible]) {
        [languageActionSheet 
         dismissWithClickedButtonIndex:[languageActionSheet cancelButtonIndex] animated:YES];
    }
    if (gotoActionSheet != nil && [gotoActionSheet isVisible]) {
        [gotoActionSheet
         dismissWithClickedButtonIndex:[gotoActionSheet cancelButtonIndex] animated:YES];
    }
    if (itemOptionsActionSheet != nil && [itemOptionsActionSheet isVisible]) {
        [itemOptionsActionSheet
         dismissWithClickedButtonIndex:[itemOptionsActionSheet cancelButtonIndex] animated:YES];
    }
}

- (void) showToast {
    toastText.hidden = NO;
    
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
    
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:fireDate                      
                                              interval:1                      
                                                target:self                      
                                              selector:@selector(hideToast:)                      
                                              userInfo:nil
                                               repeats:NO];
	[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [timer release];
}

-(void) hideToast:(NSTimer *)theTimer {
    toastText.hidden = YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
    return NO;
}

/*
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {               
        [self.navigationController setNavigationBarHidden:TRUE animated:FALSE]; 
        [[UIApplication sharedApplication] setStatusBarHidden:TRUE 
                                                withAnimation:UIStatusBarAnimationNone];
    }
    else
    {
        [self.navigationController setNavigationBarHidden:FALSE animated:FALSE];
        [[UIApplication sharedApplication] setStatusBarHidden:FALSE 
                                                withAnimation:UIStatusBarAnimationNone];
    }
}
*/


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation { 
    [self updateReadingPage];
}

#pragma mark -
#pragma mark IBAction Methods

-(IBAction)increaseFontSize:(id)sender {
    self.fontSize += 2;
    [dataDictionary setValue:[NSNumber numberWithInt:self.fontSize] forKey:@"FontSize"];
    [self updateReadingPage];
}

-(IBAction)decreaseFontSize:(id)sender {
    self.fontSize -= 2;
    [dataDictionary setValue:[NSNumber numberWithInt:self.fontSize] forKey:@"FontSize"];    
    [self updateReadingPage];    
}

- (IBAction) titleTap:(id) sender
{
	BookListTableViewController *controller = [[BookListTableViewController alloc] 
											   initWithNibName:@"BookListTableViewController" bundle:nil];
	if([((NSString *)[dataDictionary valueForKey:@"Language"]) isEqualToString:@"Thai"]) {
		controller.title = @"เลือกเล่ม (ภาษาไทย)";
	} else {
		controller.title = @"เลือกเล่ม (ภาษาบาลี)";
	}
	
	[[self navigationController] pushViewController:controller animated:YES];
	[controller release], controller = nil;	
}

-(IBAction)gotoButtonClicked:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [gotoActionSheet showFromToolbar:toolbar];
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([gotoActionSheet isVisible]) {
            [gotoActionSheet dismissWithClickedButtonIndex:[gotoActionSheet cancelButtonIndex] 
                                                      animated:YES];
        } else {
            [self dismissAllPopoverControllers];
            [gotoActionSheet showFromBarButtonItem:gotoButton animated:YES];
        }
    }
}

-(IBAction)languageButtonClicked:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [languageActionSheet showFromToolbar:toolbar];
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {  
        if ([languageActionSheet isVisible]) {
            [languageActionSheet dismissWithClickedButtonIndex:[languageActionSheet cancelButtonIndex] 
                                                      animated:YES];
        } else {
            [self dismissAllPopoverControllers];            
            [languageActionSheet showFromBarButtonItem:languageButton animated:YES];
        }
    }
}

-(IBAction)nextButtonClicked:(id)sender {
    self.scrollToItem = NO;
    self.scrollToKeyword = NO;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self dismissAllPopoverControllers];
    }

    NSString *language = [dataDictionary valueForKey:@"Language"];
    NSMutableDictionary *dict = [dataDictionary valueForKey:language];
    
    NSNumber *page = [dict valueForKey:@"Page"];
    NSNumber *volume = [dict valueForKey:@"Volume"];
    
    if ([page intValue] < [ReadViewController getMaximumPageValue:language ofVolume:volume]) {
        // reset scroll position
        if ([language isEqualToString:@"Thai"]) {
            thaiScrollPosition = 0;
        } else {
            paliScrollPosition = 0;
        }
        
        page = [NSNumber numberWithInt:[page intValue]+1];
        
        [dict setValue:page forKey:@"Page"];
        
        [dataDictionary setValue:dict forKey:language];
        [self updateReadingPage];
    } 
}  

-(IBAction)backButtonClicked:(id)sender {
    self.scrollToItem = NO;
    self.scrollToKeyword = NO;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self dismissAllPopoverControllers];
    }

    NSString *language = [dataDictionary valueForKey:@"Language"];
    NSMutableDictionary *dict = [dataDictionary valueForKey:language];
    
    NSNumber *page = [dict valueForKey:@"Page"];
    if ([page intValue] > 1) {
        // reset scroll position
        if ([language isEqualToString:@"Thai"]) {
            thaiScrollPosition = 0;
        } else {
            paliScrollPosition = 0;
        }
        
        page = [NSNumber numberWithInt:[page intValue]-1];
        
        [dict setValue:page forKey:@"Page"];
        
        [dataDictionary setValue:dict forKey:language];
        [self updateReadingPage];			
    }
}

-(IBAction)noteButtonClicked:(id)sender {

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([self.itemOptionsActionSheet isVisible]) {
            [self.itemOptionsActionSheet dismissWithClickedButtonIndex:
             [self.itemOptionsActionSheet cancelButtonIndex] animated:YES];
            return;
        } else {
            [self dismissAllPopoverControllers];
        }
    }
	
	/*
	BookmarkAddViewController *controller = [[BookmarkAddViewController alloc] 
											   initWithNibName:@"BookmarkAddViewController" bundle:nil];	
	[[self navigationController] pushViewController:controller animated:YES];
	[controller release], controller = nil;
	 */

	NSString *language = [dataDictionary valueForKey:@"Language"];
	NSNumber *volume = [[dataDictionary valueForKey:language] valueForKey:@"Volume"];
	NSNumber *page = [[dataDictionary valueForKey:language] valueForKey:@"Page"];			
	
	NSArray *items = [self getItems:language forVolume:volume forPage:page onlyBegin:YES];
	if (items && [items count] > 0) {
		[self showItemOptions:items 
                      withTag:kBookmarkOptionsActionSheet 
                    withTitle:@"โปรดเลือกข้อที่ต้องการจดบันทึก"];
	} else {
		items = [self getItems:language forVolume:volume forPage:page onlyBegin:NO];
		if (items && [items count] > 0) {
			[self showItemOptions:items 
                          withTag:kBookmarkOptionsActionSheet 
                        withTitle:@"โปรดเลือกข้อที่ต้องการจดบันทึก"];
		}
	}
}

-(void)updateLanguageButtonTitle {
	NSString *language = [dataDictionary valueForKey:@"Language"];
	if ([language isEqualToString:@"Thai"]) {
		self.navigationItem.leftBarButtonItem.title = @"บาลี";
	} else {
		self.navigationItem.leftBarButtonItem.title = @"ไทย";		
	}
}

-(IBAction)toggleLanguage:(id)sender {
	[self swapLanguage];
    [self updateLanguageButtonTitle];
}

//-(void)presentSearchPopover {
//    if (_searchPopoverController != nil && [_searchPopoverController isPopoverVisible]) {
//        [self dismissAllPopoverControllers];
//        _searchPopoverController.popoverContentSize = CGSizeMake(580, 500);
//        
//        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
//            [_searchPopoverController presentPopoverFromRect:CGRectMake(309, 82, 151, 29) 
//                                                      inView:self.view 
//                                    permittedArrowDirections:UIPopoverArrowDirectionUp 
//                                                    animated:YES];
//        } else {
//            [_searchPopoverController presentPopoverFromRect:CGRectMake(277, 82, 151, 29) 
//                                                      inView:self.view 
//                                    permittedArrowDirections:UIPopoverArrowDirectionUp 
//                                                    animated:YES];                
//        }            
//    }
//}

-(IBAction)showSearchView:(id)sender {    
    if(_searchPopoverController != nil) {
        if ([_searchPopoverController isPopoverVisible]) {
            [_searchPopoverController dismissPopoverAnimated:YES];
        } else {
            [self dismissAllPopoverControllers];

            _searchPopoverController.popoverContentSize = CGSizeMake(660, 600);            
            [_searchPopoverController presentPopoverFromBarButtonItem:searchButton 
                                             permittedArrowDirections:UIPopoverArrowDirectionDown 
                                                             animated:NO];
            
//            if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
//                [_searchPopoverController presentPopoverFromRect:CGRectMake(309, 82, 151, 29) 
//                                     inView:self.view 
//                   permittedArrowDirections:UIPopoverArrowDirectionUp 
//                                   animated:YES];
//            } else {
//                [_searchPopoverController presentPopoverFromRect:CGRectMake(277, 82, 151, 29) 
//                                     inView:self.view 
//                   permittedArrowDirections:UIPopoverArrowDirectionUp 
//                                   animated:YES];                
//            }            
        }
    } 
    else {
        SearchViewController *searchViewController = [[SearchViewController alloc] init];
        searchViewController.title = @"ค้นหา";
        searchViewController.readViewController = self;
        UINavigationController *navController = [[UINavigationController alloc] 
                                                 initWithRootViewController:searchViewController];
        UIPopoverController *poc = [[UIPopoverController alloc]
                                    initWithContentViewController:navController];
        [self dismissAllPopoverControllers];

        poc.popoverContentSize = CGSizeMake(660, 600);

        [poc presentPopoverFromBarButtonItem:searchButton 
                    permittedArrowDirections:UIPopoverArrowDirectionDown 
                                    animated:YES];        

        
//        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
//            [poc presentPopoverFromRect:CGRectMake(309, 82, 151, 29) 
//                                 inView:self.view 
//               permittedArrowDirections:UIPopoverArrowDirectionUp 
//                               animated:YES];
//        } else {
//            [poc presentPopoverFromRect:CGRectMake(277, 82, 151, 29) 
//                                 inView:self.view 
//               permittedArrowDirections:UIPopoverArrowDirectionUp 
//                               animated:YES];                
//        }
        
        self.searchPopoverController = poc;
        [poc release];
        [searchViewController release];
        [navController release];
    }
}

-(IBAction)showBookmarkListView:(id)sender {
    if(_bookmarkPopoverController != nil) {
        if ([_bookmarkPopoverController isPopoverVisible]) {
            [_bookmarkPopoverController dismissPopoverAnimated:YES];
        } else {
            [self dismissAllPopoverControllers];
            [_bookmarkPopoverController presentPopoverFromBarButtonItem:bookmarkButton
                                               permittedArrowDirections:UIPopoverArrowDirectionAny
                                                               animated:YES];
        }
    }
    else {
        BookmarkListViewController *bookmarkListViewController = [[BookmarkListViewController alloc] 
                                                                  init];
        bookmarkListViewController.readViewController = self;
        UINavigationController *navController = [[UINavigationController alloc] 
                                                 initWithRootViewController:bookmarkListViewController];
        UIPopoverController *poc = [[UIPopoverController alloc]
                                    initWithContentViewController:navController];
        [self dismissAllPopoverControllers];
        [poc presentPopoverFromBarButtonItem:bookmarkButton
                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                    animated:YES];
        self.bookmarkPopoverController = poc;
        [poc release];
        [bookmarkListViewController release];
        [navController release];
    }
}

-(IBAction)showBooklistTableView:(id)sender {
    if(booklistPopoverController != nil) {
        if ([booklistPopoverController isPopoverVisible]) {
            [booklistPopoverController dismissPopoverAnimated:YES];
        } else {
            [self dismissAllPopoverControllers];
            [booklistPopoverController presentPopoverFromBarButtonItem:booklistButton
                                              permittedArrowDirections:UIPopoverArrowDirectionAny 
                                                              animated:YES];
        }
    } else {
        BookListTableViewController *booklistTableViewController = [[BookListTableViewController alloc] 
                                                                    init];
        UINavigationController *navController = [[UINavigationController alloc] 
                                                 initWithRootViewController:booklistTableViewController];
        UIPopoverController *poc = [[UIPopoverController alloc]
                                    initWithContentViewController:navController];
        [self dismissAllPopoverControllers];
        [poc presentPopoverFromBarButtonItem:booklistButton 
                    permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        self.booklistPopoverController = poc;
        [poc release];
        [booklistTableViewController release];
        [navController release];
    }
}

-(IBAction)sliderValueChanged:(UISlider *)sender {
    self.scrollToItem = NO;
    self.scrollToKeyword = NO;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self dismissAllPopoverControllers];
    }
    
    NSString *language = [dataDictionary valueForKey:@"Language"];
    NSMutableDictionary *dict = [dataDictionary valueForKey:language];
    
    NSNumber *volume = [dict valueForKey:@"Volume"];

    // reset scroll position
    if ([language isEqualToString:@"Thai"]) {
        thaiScrollPosition = 0;
    } else {
        paliScrollPosition = 0;
    }
    
    NSNumber *page = [NSNumber numberWithInt: round(sender.value)];
    
    [dict setValue:page forKey:@"Page"];
    
    [dataDictionary setValue:dict forKey:language];
    
    [self updatePageTitle:language volume:volume page:page];
}

-(IBAction) startUpdatingPage:(id)sender {
    [self updateReadingPage];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self reloadData];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        showToolbar = NO;
        [toolbar setHidden:YES];
        
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            self.htmlView.frame = CGRectMake(0, 20, 480, 219);
        } else {
            self.htmlView.frame = CGRectMake(0, 20, 320, 367);
        }      
        [self updateLanguageButtonTitle];        
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // TODO for iPad
    }
      
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[Utils writeData:dataDictionary];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];

//    self.pagesDictionary = [Utils readPages];
//    self.itemsDictionary = [Utils readItems];
    
    mWindow = (TapDetectingWindow *)[[UIApplication sharedApplication].windows objectAtIndex:0];
    mWindow.viewToObserve = htmlView;
    mWindow.controllerThatObserves = self;	
	
    pageSlider.continuous = YES;
    
	self.scrollToItem = NO;
    self.scrollToKeyword = NO;
    
    pageSlider.minimumValue = 1;
    
    toastText.hidden = YES;
    //indicator.hidden = YES;
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIBarButtonItem *selectButton = [[UIBarButtonItem alloc]
                                         initWithTitle:@"เลือก" 
                                         style:UIBarButtonItemStyleBordered
                                         target:self 
                                         action:@selector(titleTap:)];
        self.navigationItem.rightBarButtonItem = selectButton;
        [selectButton release];
        
        UIButton *titleNavLabel = [UIButton buttonWithType:UIButtonTypeCustom];
        titleNavLabel.showsTouchWhenHighlighted = YES;
        [titleNavLabel setTitle:@"อ่าน" forState:UIControlStateNormal];
        titleNavLabel.frame = CGRectMake(0, 0, 230, 44);
        
        titleNavLabel.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [titleNavLabel addTarget:self action:@selector(titleTap:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.titleView = titleNavLabel;	
        
        UIBarButtonItem *langButton = [[UIBarButtonItem alloc]
                                           initWithTitle:@""
                                           style:UIBarButtonItemStyleBordered
                                           target:self 
                                           action:@selector(toggleLanguage:)];
        self.navigationItem.leftBarButtonItem = langButton;
        [langButton release];	
        [self reloadData];	
        
        NSString *language = [dataDictionary valueForKey:@"Language"];
        if ([language isEqualToString:@"Thai"]) {
            self.navigationItem.leftBarButtonItem.title = @"บาลี";
        } else {
            self.navigationItem.leftBarButtonItem.title = @"ไทย";		
        }        
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self reloadData];	
    }
    
    
    self.fontSize = [[dataDictionary valueForKey:@"FontSize"] intValue];
    
	[self updateReadingPage];
    
    UIActionSheet *actionSheet;
    
    // create action sheet for language menu    
	actionSheet = [[UIActionSheet alloc] init];
	actionSheet.title = @"โปรดเลือกคำสั่งที่ต้องการ";
	actionSheet.delegate = self;
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.tag = kLanguageActionSheet;
	[actionSheet addButtonWithTitle:@"สลับภาษา"];
	[actionSheet addButtonWithTitle:@"เทียบเคียง"];
	[actionSheet addButtonWithTitle:@"ยกเลิก"];
	[actionSheet setCancelButtonIndex:2];    
    self.languageActionSheet = actionSheet;    
	[actionSheet release];
    
    // create action sheet for goto menu
	actionSheet = [[UIActionSheet alloc] init];	
	actionSheet.title = @"โปรดเลือกคำสั่งที่ต้องการ";
	actionSheet.delegate = self;
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	actionSheet.tag = kGotoActionSheet;
	[actionSheet addButtonWithTitle:@"อ่านหน้าที่"];
	[actionSheet addButtonWithTitle:@"อ่านข้อที่"];
	[actionSheet addButtonWithTitle:@"ยกเลิก"];
	[actionSheet setCancelButtonIndex:2];
    self.gotoActionSheet = actionSheet;
	[actionSheet release];    
    
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    [self dismissAllPopoverControllers];
    
    [searchPopoverController release];
    self.searchPopoverController = nil;
    [bookmarkPopoverController release];
    self.bookmarkPopoverController = nil;
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
//    [[NSNotificationCenter defaultCenter] removeObserver:self 
//                                                    name:UIKeyboardDidHideNotification object:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.toolbar = nil;
	self.titleLabel = nil;
    self.pageNumberLabel = nil;
    self.pageSlider = nil;
	self.htmlView = nil;
	self.dataDictionary = nil;
//    self.pagesDictionary = nil;
//    self.itemsDictionary = nil;
//    self.popoverController = nil;
    self.searchPopoverController = nil;
    self.bookmarkPopoverController = nil;
    self.searchButton = nil;
    self.languageButton = nil;    
    self.gotoButton = nil;
    self.noteButton = nil;
    self.bookmarkButton = nil;    
    self.titleButton = nil;
    self.languageActionSheet = nil;
    self.gotoActionSheet = nil;
    self.itemOptionsActionSheet = nil;
    self.toastText = nil;
    self.bottomToolbar = nil;
    //self.indicator = nil;
}


- (void)dealloc {
	[toolbar release];
	[titleLabel release];
    [pageNumberLabel release];
    [pageSlider release];
	[htmlView release];
	[dataDictionary release];
//    [pagesDictionary release];
//    [itemsDictionary release];
	[alterItems release];
	[keywords release];
//    [_myPopoverController release];
    [_detailItem release];
    [_searchPopoverController release];
    [_bookmarkPopoverController release];
    [booklistPopoverController release];
    [searchButton release];
    [languageButton release];
    [booklistButton release];
    [gotoButton release];
    [noteButton release];
    [bookmarkButton release];
    [titleButton release];
    [languageActionSheet release];
    [gotoActionSheet release];
    [itemOptionsActionSheet release];
    [toastText release];
    [bottomToolbar release];
    //[indicator release];
    [super dealloc];
}


#pragma mark - 
#pragma mark Text Field Delegate Methods 

- (void)textFieldDidEndEditing:(UITextField *)textField {
	
}

#pragma mark - 
#pragma mark Alert View Delegate Methods 

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex != [alertView cancelButtonIndex]) {
		NSString *language = [dataDictionary valueForKey:@"Language"];
		NSMutableDictionary *dict = [dataDictionary valueForKey:language];
		
		NSNumber *volume = [dict valueForKey:@"Volume"];
		
		for(UIView *subview in [alertView subviews]) {
			if([subview isKindOfClass:[UITextField class]]) {
				NSString *inputText = ((UITextField *)subview).text;
				if ([inputText length] > 0) {
					if ([inputText intValue]) {
						if(alertView.tag == kGotoPageAlert) {
							NSInteger maxPage = [ReadViewController getMaximumPageValue:language 
                                                                               ofVolume:volume];
							if ([inputText intValue] > 0 && [inputText intValue] <= maxPage) {
								NSNumber *newPage = [NSNumber numberWithInt:[inputText intValue]];
								[dict setValue:newPage forKey:@"Page"];
								[dataDictionary setValue:dict forKey:language];
								[self updateReadingPage];
							}

						}
						else {
							NSInteger maxItem = [ReadViewController getMaximumItemValue:language 
                                                                               ofVolume:volume];
							if([inputText intValue] > 0 && [inputText intValue] <= maxItem) {
								NSNumber *newNumber = [NSNumber numberWithInt:[inputText intValue]];
								NSArray *results = [self getItems:language forVolume:volume forNumber:newNumber];
																
								self.alterItems = [[NSArray alloc] initWithArray:results];
								
								savedItemNumber = [inputText intValue];
								if ([results count] > 1) {                                    
									UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
									actionSheet.tag = kSelectItemActionSheet;
									actionSheet.title = [Utils arabic2thai: 
														 [NSString stringWithFormat:@"ข้อที่ %@ พบมากกว่าหนึ่งหน้า", newNumber]];
									actionSheet.delegate = self;
									actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
									for (Item *item in results) {
										[actionSheet addButtonWithTitle:
										 [Utils arabic2thai:[NSString stringWithFormat:@"หน้าที่ %@", item.content.page]]];
									}                                    
                                    [actionSheet addButtonWithTitle:@"ยกเลิก"];
                                    [actionSheet setCancelButtonIndex:[results count]];
                                    
                                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                                        [actionSheet showFromToolbar:toolbar];
                                    }
                                    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                                        [actionSheet showFromRect:CGRectMake(60, 0, 10, 74) 
                                                           inView:self.view animated:YES];                                        
                                        self.itemOptionsActionSheet = actionSheet;
                                    }

									[actionSheet release];
									
								} else if ([results count] == 1) {
									self.scrollToItem = YES;
                                    self.scrollToKeyword = NO;
                                    self.keywords = nil;
                                    
									Item *item = [results objectAtIndex:0];
									[dict setValue:item.content.page forKey:@"Page"];
									[dataDictionary setValue:dict forKey:language];
									[self updateReadingPage];
								} 
							}
						}
					}
				} else {
					//NSLog(@"No input");
				}
			} 
		}
	} else {
		//NSLog(@"Cancel");
	}

}


#pragma mark - 
#pragma mark Web View Delegate Methods 

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	//NSLog(@"isItem: %d", isItem);
	//NSLog(@"firstCalled: %d", firstCalled);    
    
    if (self.scrollToItem) {
		[htmlView stringByEvaluatingJavaScriptFromString:
		 [NSString stringWithFormat:
		  @"var item = document.getElementById(\"i%d\"); \n"
		  " if(item) { \n"
		  "    ScrollToElement(item); \n"
		  " }", savedItemNumber
		  ]];
		self.scrollToItem = NO;
	}
	else if (self.scrollToKeyword) {
		[htmlView stringByEvaluatingJavaScriptFromString:
		 @"var keywords = document.getElementById(\"keywords\"); \n"
		 " if(keywords) { \n"
		 "    ScrollToElement(keywords); \n"
		 " }"
		 ];
		self.scrollToKeyword = NO;
	} 
	else {
		NSString *language = [dataDictionary valueForKey:@"Language"];
		if ([language isEqualToString:@"Pali"]) {
			[htmlView stringByEvaluatingJavaScriptFromString:
			 [NSString stringWithFormat:@"window.scrollTo(0,%d);", paliScrollPosition]];
		} else {			
			[htmlView stringByEvaluatingJavaScriptFromString:
			 [NSString stringWithFormat:@"window.scrollTo(0,%d);", thaiScrollPosition]];
		}
	}
}


#pragma mark -
#pragma mark Action Sheet Delegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if(actionSheet.tag == kGotoActionSheet) {
		if (buttonIndex == 0) {
			[self gotoPage];
		} else if (buttonIndex == 1) {
			[self gotoItem];
		}
	} else if (actionSheet.tag == kSelectItemActionSheet) {
        if (buttonIndex != [actionSheet cancelButtonIndex]) {
            [self selectItem:buttonIndex];
        }
	} else if (actionSheet.tag == kLanguageActionSheet) {
		if (buttonIndex == 0) {
			[self swapLanguage];
            [self updateLanguageButtonTitle];
		} else if (buttonIndex == 1) {
			[self compareLanguage];
		}
	} else if (actionSheet.tag == kItemOptionsActionSheet) {
		[self doCompare:buttonIndex];
        [self updateLanguageButtonTitle];
	} else if (actionSheet.tag == kBookmarkOptionsActionSheet) {
        if (buttonIndex != [actionSheet cancelButtonIndex]) {
            [self saveBookmark:buttonIndex];
        }
	}
	//NSLog(@"%d %d", actionSheet.tag, buttonIndex);
}

#pragma mark -
#pragma mark Tap Detecting Window Delegate Methods

- (void) userDidTapWebView:(id)tapPoint {
    
    CGRect rect = [htmlView frame];
    
    float w = rect.size.width;
    float x = [[tapPoint objectAtIndex:0] floatValue];
    
    if(x <= 100) {
        [self backButtonClicked:nil];
        return;
    } 
    else if(x >= w - 100) {
        [self nextButtonClicked:nil];
        return;
    } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // toggle bottom bar and slider
        bottomToolbar.hidden = !bottomToolbar.hidden;
        pageSlider.hidden = !pageSlider.hidden;
        
        CGRect oldRect = self.htmlView.frame;
        CGRect newRect;
        if (bottomToolbar.hidden) {
            newRect = CGRectMake(oldRect.origin.x, 
                                 oldRect.origin.y-30, 
                                 oldRect.size.width, 
                                 oldRect.size.height+44+30);
        } else {
            newRect = CGRectMake(oldRect.origin.x, 
                                 oldRect.origin.y+30, 
                                 oldRect.size.width, 
                                 oldRect.size.height-44-30);            
        }
        self.htmlView.frame = newRect;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return;
    }
    
	showToolbar = !showToolbar;
    
    UIView *transView = [self.tabBarController.view.subviews objectAtIndex:0];
    UIView *tabBar = [self.tabBarController.view.subviews objectAtIndex:1];
    if (showToolbar) {
        tabBar.hidden = TRUE;
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            transView.frame = CGRectMake(0, 0, 480, 320);
            self.htmlView.frame = CGRectMake(0, 20, 480, 224);
        } else {        
            transView.frame = CGRectMake(0, 0, 320, 480);
            self.htmlView.frame = CGRectMake(0, 20, 320, 372);
        }
    } else {
        tabBar.hidden = FALSE;
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            transView.frame = CGRectMake(0, 0, 480, 271);
            self.htmlView.frame = CGRectMake(0, 20, 480, 219);
        } else {
            transView.frame = CGRectMake(0, 0, 320, 431);
            self.htmlView.frame = CGRectMake(0, 20, 320, 367);
        }
    }
	toolbar.hidden = !showToolbar;
}


@end



