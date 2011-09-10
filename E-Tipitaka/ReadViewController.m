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
#import "DictionaryListViewController.h"
#import "SearchViewController.h"
#import "Item.h"
#import "Utils.h"
#import "Content.h"
#import "ContentInfo.h"
#import "QueryHelper.h"
#import "ContentViewController.h"

//@interface ReadViewController ()
//@property (nonatomic, retain) UIPopoverController *popoverController;
////- (void)configureView;
//@end

@implementation ReadViewController

@synthesize toolbar;
@synthesize titleLabel;
@synthesize pageNumberLabel;
@synthesize htmlView;
@synthesize contentView;
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
@synthesize dictionaryPopoverController;
@synthesize dictionaryListViewController;
@synthesize contentViewController;
@synthesize searchButton;
@synthesize languageButton;
@synthesize booklistButton;
@synthesize gotoButton;
@synthesize noteButton;
@synthesize bookmarkButton;
@synthesize titleButton;
@synthesize dictionaryButton;
@synthesize languageActionSheet;
@synthesize gotoActionSheet;
@synthesize itemOptionsActionSheet;
@synthesize toastText;
@synthesize pageSlider;
@synthesize bottomToolbar;
//@synthesize indicator;

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
	
    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = language;
    info.volume = volume;
    [info setType:LANGUAGE|VOLUME];
	itemLabel.text = [Utils arabic2thai:[NSString stringWithFormat:@"ตั้งแต่ข้อที่ ๑ ถึง %d", [QueryHelper getMaximumItemValue:info]]];
    [info release];
    
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
	
	ContentInfo *info = [[ContentInfo alloc] init];
    info.language = language;
    info.volume = volume;
    [info setType:LANGUAGE|VOLUME];
	pageLabel.text = [Utils arabic2thai:[NSString stringWithFormat:@"ตั้งแต่หน้าที่ ๑ ถึง %d", [QueryHelper getMaximumPageValue:info]]];
    [info release];
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
            [actionSheet showFromBarButtonItem:languageButton animated:YES];
        }
        else if (tagNumber == kBookmarkOptionsActionSheet) {
            [actionSheet showFromBarButtonItem:noteButton animated:YES];
        }
    }
    self.itemOptionsActionSheet = actionSheet;
    
	[actionSheet release];
	
}

+(void) updatePageTitle:(NSString *)language volume:(NSNumber *)volume 
                   page:(NSNumber *)page slider:(UISlider *)slider 
             titleLabel:(UILabel *)label1 pageLabel:(UILabel *)label2 {

    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = language;
    info.volume = volume;
    [info setType:LANGUAGE|VOLUME];
    NSInteger maxPage = [QueryHelper getMaximumPageValue:info];
    [info release];
    
    if (slider.maximumValue != maxPage) {
        slider.maximumValue = maxPage;
    }
    slider.value = [page floatValue];
    
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
    
    label1.text = [Utils arabic2thai:newLabel1];
    label2.text = [Utils arabic2thai:newLabel2];
    
	[newLabel1 release];
    [newLabel2 release];    
}

+(void) updateWebView:(UIWebView *)webview withContent:(Content *)content fontSize:(NSInteger)size
         andKeywords:(NSString *)query {
    NSString *text = [content.text stringByReplacingOccurrencesOfString:@"\n"
                                                             withString:@"<br>"];
    text = [text stringByReplacingOccurrencesOfString:@"\t" 
                                           withString:@"&nbsp;&nbsp;"];
    if(query) {
        NSArray *tokens = [query componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
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
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"page" ofType:@"html"];
    NSString *template = [NSString stringWithContentsOfFile:filePath 
                                                  encoding:NSUTF8StringEncoding error:nil];
    NSString *html = [[NSString alloc] 
                      initWithFormat:template, size, text];
    [webview loadHTMLString:html baseURL:[NSURL URLWithString:@"http://www.etipitaka.com"]];
    [html release];

}

+(NSString *) createHeaderTitle:(NSNumber *)volume {
	NSString *newTitle = [NSString alloc];
	if([volume intValue] <= 8) {
		newTitle = [newTitle initWithFormat:@"%@ เล่มที่ %d", @"พระวินัยปิฎก", [volume intValue]];
	} else if([volume intValue] <= 33) {
		newTitle = [newTitle initWithFormat:@"%@ เล่มที่ %d", @"พระสุตตันตปิฎก", [volume intValue] - 8];
	} else {
		newTitle = [newTitle initWithFormat:@"%@ เล่มที่ %d", @"พระอภิธรรมปิฎก", [volume intValue] - 33];		
	}
    [newTitle autorelease];
    return  newTitle;
}

-(void) updateReadingPage {
	if(!dataDictionary)
		return;

	NSString *language = [dataDictionary valueForKey:@"Language"];
	NSDictionary *dict = [dataDictionary valueForKey:language];
	
	NSNumber *page = [dict valueForKey:@"Page"];
	NSNumber *volume = [dict valueForKey:@"Volume"];    
    
	NSString *newTitle = [ReadViewController createHeaderTitle:volume];    
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
        
    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = language;
    info.volume = volume;
    info.page = page;
    [info setType:(LANGUAGE|VOLUME|PAGE)];
    NSArray *fetchedObjects = [QueryHelper getContents:info];
    [info release];    
    
	if(fetchedObjects == nil) {
		NSLog(@"Whoops, couldn't fetch");
	} else {		
		if ([fetchedObjects count] > 0) {
            contentViewController.content = [fetchedObjects objectAtIndex:0];
            contentViewController.fontSize = fontSize;
            contentViewController.scrollToHighlightText = NO;
            contentViewController.scrollToItemNumber = NO;
            if (self.scrollToItem) {
                self.scrollToItem = NO;
                contentViewController.itemNumber = self.savedItemNumber;
                contentViewController.scrollToItemNumber = YES;
            } else if (self.scrollToKeyword) {
                self.scrollToKeyword = NO;                
                contentViewController.highlightText = self.keywords;
                contentViewController.scrollToHighlightText = YES;
            } else {
                if ([language isEqualToString:@"Thai"]) {
                    contentViewController.scrollPosition = thaiScrollPosition;                    
                } else if ([language isEqualToString:@"Pali"]) {
                    contentViewController.scrollPosition = paliScrollPosition;                    
                } else {
                    contentViewController.scrollPosition = 0;
                }
            }
            [contentViewController update];
		}
	}
    
    [ReadViewController updateReadingPage:self.keywords slider:self.pageSlider webview:self.htmlView
                               titleLabel:self.titleLabel pageLabel:self.pageNumberLabel
                                 fontSize:self.fontSize language:language volume:volume page:page];
    
    [Utils writeData:dataDictionary];
}

+(void) updateReadingPage:(NSString *)query slider:(UISlider *)slider webview:(UIWebView *)webview
               titleLabel:(UILabel *)label1 pageLabel:(UILabel *)label2 fontSize:(NSInteger)size 
                 language:(NSString *)language volume:(NSNumber *)volume page:(NSNumber *)page {

    [ReadViewController updatePageTitle:language volume:volume 
                                   page:page slider:slider 
                             titleLabel:label1 
                              pageLabel:label2];
    
//    ContentInfo *info = [[ContentInfo alloc] init];
//    info.language = language;
//    info.volume = volume;
//    info.page = page;
//    [info setType:(LANGUAGE|VOLUME|PAGE)];
//    NSArray *fetchedObjects = [QueryHelper getContents:info];
//    [info release];    
//	
//	if(fetchedObjects == nil) {
//		NSLog(@"Whoops, couldn't fetch");
//	} else {		
//		if ([fetchedObjects count] > 0) {
//			Content *content = [fetchedObjects objectAtIndex:0];	
//            [ReadViewController updateWebView:webview withContent:content 
//                                     fontSize:size andKeywords:query];
//		}
//	}
}


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
    NSString *language = [dataDictionary valueForKey:@"Language"];
    NSNumber *volume = [[dataDictionary valueForKey:language] valueForKey:@"Volume"];
    NSNumber *page = [[dataDictionary valueForKey:language] valueForKey:@"Page"];
    
    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = language;
    info.volume = volume;
    info.page = page;
    info.begin = YES;    
    [info setType:(LANGUAGE|VOLUME|PAGE|BEGIN)];
    NSArray *items = [QueryHelper getItems:info];
    if (items && [items count] > 0) {
        [self showItemOptions:items 
                      withTag:kItemOptionsActionSheet withTitle:@"โปรดเลือกข้อที่ต้องการเทียบเคียง"];
    } else {
        info.begin = NO;
        items = [QueryHelper getItems:info];
        if (items && [items count] > 0) {
            [self showItemOptions:items 
                          withTag:kItemOptionsActionSheet withTitle:@"โปรดเลือกข้อที่ต้องการเทียบเคียง"];
        }
    }
    [info release];
}

- (void) doCompare:(NSInteger)buttonIndex {
	NSString *sourceLanguage = [[NSString alloc] initWithString:[dataDictionary valueForKey:@"Language"]];
	NSNumber *volume = [[dataDictionary valueForKey:sourceLanguage] valueForKey:@"Volume"];
	NSNumber *page = [[dataDictionary valueForKey:sourceLanguage] valueForKey:@"Page"];			
	
    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = sourceLanguage;
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
		NSString *targetLanguage;
		
		if ([sourceLanguage isEqualToString:@"Thai"]) {
			targetLanguage = @"Pali";
		} else {
			targetLanguage = @"Thai";
		}
        info.language = targetLanguage;
        info.volume = volume;
        info.itemNumber = selectedItem.number;
        info.section = selectedItem.section;
        [info setType:LANGUAGE|VOLUME|ITEM_NUMBER|SECTION];
        comparedItems = [QueryHelper getItems:info];
		
		if (comparedItems && [comparedItems count] > 0) {
			Item *comparedItem = [comparedItems objectAtIndex:0];
			savedItemNumber = [comparedItem.number intValue];
            
			self.scrollToItem = YES;
            self.scrollToKeyword = NO;
    
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                // change language
                [dataDictionary setValue:targetLanguage forKey:@"Language"];
                [[dataDictionary valueForKey:targetLanguage] setValue:volume 
                                                               forKey:@"Volume"];
                [[dataDictionary valueForKey:targetLanguage] setValue:comparedItem.content.page
                                                               forKey:@"Page"];                
                [self updateReadingPage];
            } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [[dataDictionary valueForKey:targetLanguage] setValue:volume 
                                                               forKey:@"Volume"];
                [[dataDictionary valueForKey:targetLanguage] setValue:comparedItem.content.page
                                                               forKey:@"Page"];                
                [Utils writeData:dataDictionary];
                
                DoubleReadViewController *controller = [[DoubleReadViewController alloc] 
                                                        initWithNibName:@"DoubleReadView_iPad" bundle:nil];                
                controller.sourceLanguage = sourceLanguage;
                controller.targetLanguage = targetLanguage;
                
                if (self.keywords) {
                    NSString *str = [[NSString alloc] initWithString:self.keywords];
                    controller.keyword = str;
                    [str release];
                }
                
                controller.savedItemNumber = [comparedItem.number intValue];
                controller.scrollToItem = YES;

                [self.navigationController pushViewController:controller animated:YES];
                [controller release], controller = nil;                
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
            
            if ([sourceLanguage isEqualToString:@"Thai"]) {
                title = [[NSString alloc] initWithFormat:@"พระไตรปิฎก เล่มที่ %@ (ภาษาบาลี)", volume];                
            } else if ([sourceLanguage isEqualToString:@"Pali"]) {
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
    [info release];
	[sourceLanguage release];
}

- (void) saveBookmark:(NSInteger)buttonIndex {
	NSString *language = [dataDictionary valueForKey:@"Language"];
	NSNumber *volume = [[dataDictionary valueForKey:language] valueForKey:@"Volume"];
	NSNumber *page = [[dataDictionary valueForKey:language] valueForKey:@"Page"];			
	
    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = language;
    info.volume = volume;
    info.page = page;
    info.begin = YES;
    [info setType:LANGUAGE|VOLUME|PAGE|BEGIN];
    NSArray *items = [QueryHelper getItems:info];
    
	if (!items || [items count] == 0) {
        info.begin = NO;
        items = [QueryHelper getItems:info];
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
            
            [poc presentPopoverFromRect:self.pageNumberLabel.frame
                                 inView:self.view 
               permittedArrowDirections:UIPopoverArrowDirectionUp 
                               animated:YES];
            [navController release];
        }

		[controller release], controller = nil;
	}
    [info release];    
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
    if (_searchPopoverController != nil && [_searchPopoverController isPopoverVisible]) {
        [_searchPopoverController dismissPopoverAnimated:YES];
    }
    if (_bookmarkPopoverController != nil && [_bookmarkPopoverController isPopoverVisible]) {
        [_bookmarkPopoverController dismissPopoverAnimated:YES];
    }
    if (booklistPopoverController != nil && [booklistPopoverController isPopoverVisible]) {
        [booklistPopoverController dismissPopoverAnimated:YES];
    }
    if (dictionaryPopoverController != nil && [dictionaryPopoverController isPopoverVisible]) {
        [dictionaryPopoverController dismissPopoverAnimated:YES];
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
    
    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = language;
    info.volume = volume;
    [info setType:LANGUAGE|VOLUME];
    
    if ([page intValue] < [QueryHelper getMaximumPageValue:info]) {
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
    
    [info release];    
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
	
	NSString *language = [dataDictionary valueForKey:@"Language"];
	NSNumber *volume = [[dataDictionary valueForKey:language] valueForKey:@"Volume"];
	NSNumber *page = [[dataDictionary valueForKey:language] valueForKey:@"Page"];			
	
    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = language;
    info.volume = volume;
    info.page = page;
    info.begin = YES;
    [info setType:LANGUAGE|VOLUME|PAGE|BEGIN];
    NSArray *items = [QueryHelper getItems:info];
    [info release];
    
	if (items && [items count] > 0) {
		[self showItemOptions:items 
                      withTag:kBookmarkOptionsActionSheet 
                    withTitle:@"โปรดเลือกข้อที่ต้องการจดบันทึก"];
	} else {
        info.begin = NO;
        items = [QueryHelper getItems:info];
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
        booklistTableViewController.readViewController = self;
        

        booklistTableViewController.title = @"พระไตรปิฎก บาลีสยามรัฐ ๔๕ เล่ม";
        
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

-(IBAction)showDictionary:(id)sender {
    
    NSString *selection = [self.htmlView
                           stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];        
//    NSLog(@"%@", [self.htmlView stringByEvaluatingJavaScriptFromString:@"findTextAtRow(4);"]);

    if(dictionaryPopoverController != nil) {
        if ([dictionaryPopoverController isPopoverVisible]) {
            [dictionaryPopoverController dismissPopoverAnimated:YES];
        } else {
            [self dismissAllPopoverControllers];
            [dictionaryPopoverController presentPopoverFromBarButtonItem:dictionaryButton
                                              permittedArrowDirections:UIPopoverArrowDirectionAny 
                                                              animated:YES];  
            dictionaryListViewController.searchBar.text = selection;
            [dictionaryListViewController handleSearchForTerm:selection];                        
        }
    } else {
        DictionaryListViewController *controller = [[DictionaryListViewController alloc]
                                                            initWithNibName:@"DictionaryListView_iPad"
                                                            bundle:nil];        
        self.dictionaryListViewController = controller;
        dictionaryListViewController.title = @"พจนานุกรม บาลี-ไทย";        
        
        UINavigationController *navController = [[UINavigationController alloc] 
                                                 initWithRootViewController:dictionaryListViewController];
        UIPopoverController *poc = [[UIPopoverController alloc]
                                    initWithContentViewController:navController];
        [self dismissAllPopoverControllers];
        [poc presentPopoverFromBarButtonItem:dictionaryButton 
                    permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];   
        dictionaryListViewController.searchBar.text = selection;        
        [dictionaryListViewController handleSearchForTerm:selection];             
        self.dictionaryPopoverController = poc;
        [poc release];
        [controller release];
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
    
    [ReadViewController updatePageTitle:language volume:volume page:page 
                                 slider:self.pageSlider titleLabel:self.titleLabel 
                              pageLabel:pageNumberLabel];
}

-(IBAction) startUpdatingPage:(id)sender {
    [self updateReadingPage];
}

-(BOOL) canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(lookUpDictionary:)) {
        
        NSString *selection = [self.htmlView 
                               stringByEvaluatingJavaScriptFromString:@"window.getSelection().toString()"];
        return ([allTrim(selection) length] != 0);
    }
    return [super canPerformAction:action withSender:sender];
}

-(void) lookUpDictionary:(id)sender
{
    [self showDictionary:nil];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[Utils writeData:dataDictionary];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
        
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
    [self updateReadingPage];
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];

    ContentViewController *controller = [[ContentViewController alloc] initWithNibName:@"ContentView" bundle:nil];
    self.contentViewController = controller;
    [controller release];
    contentViewController.view.frame = CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height);
    [contentView addSubview:contentViewController.view];
      
    // lookup dictionary menu
    UIMenuItem *dictionaryMenuItem = [[UIMenuItem alloc] initWithTitle:@"บาลี-ไทย" 
                                                          action:@selector(lookUpDictionary:)];
    [UIMenuController sharedMenuController].menuItems = [NSArray arrayWithObject:dictionaryMenuItem];
    [dictionaryMenuItem release];    
    
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
    
    

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"E_Tipitaka.sqlite"];
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] 
                               stringByAppendingPathComponent:@"E_Tipitaka.sqlite"];
    
    
    NSNumber *sourceFileSize = [[fileManager attributesOfItemAtPath:defaultDBPath error:NULL] 
                                objectForKey:NSFileSize];
    NSNumber *targetFileSize = [[fileManager attributesOfItemAtPath:writableDBPath error:NULL] 
                                objectForKey:NSFileSize];
    
    NSError *error;    
    BOOL dbExists = [fileManager fileExistsAtPath:writableDBPath];        
    if (!dbExists || (dbExists && [sourceFileSize intValue] > [targetFileSize intValue])) {
        if (dbExists) {            
            if (![fileManager removeItemAtPath:writableDBPath error:&error]) {
                NSLog(@"Failed to delete existing database file, %@, %@", error, [error userInfo]);
            }
        }
        
        UIAlertView *dbAlert = [[[UIAlertView alloc] 
                                 initWithTitle:@"โปรดรอซักครู่\nโปรแกรมกำลังสร้างฐานข้อมูลเริ่มต้น" 
                                 message:nil
                                 delegate:self 
                                 cancelButtonTitle:nil 
                                 otherButtonTitles:nil, nil] autorelease];
        
        [dbAlert show];

        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        // Adjust the indicator so it is up a few pixels from the bottom of the alert
        indicator.center = CGPointMake(dbAlert.bounds.size.width / 2, dbAlert.bounds.size.height - 50);
        [indicator startAnimating];
        [dbAlert addSubview:indicator];
        [indicator release];        
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSError *error;
            [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                [dbAlert dismissWithClickedButtonIndex:0 animated:YES];
            });
            [self updateReadingPage];
        });                     
    } else {
        [self updateReadingPage];
    }
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
    self.contentView = nil;
	self.dataDictionary = nil;
//    self.pagesDictionary = nil;
//    self.itemsDictionary = nil;
//    self.popoverController = nil;
    self.searchPopoverController = nil;
    self.bookmarkPopoverController = nil;
    self.dictionaryPopoverController = nil;
    self.searchButton = nil;
    self.languageButton = nil;    
    self.gotoButton = nil;
    self.noteButton = nil;
    self.bookmarkButton = nil;    
    self.titleButton = nil;
    self.dictionaryButton = nil;
    self.languageActionSheet = nil;
    self.gotoActionSheet = nil;
    self.itemOptionsActionSheet = nil;
    self.toastText = nil;
    self.bottomToolbar = nil;
    //self.indicator = nil;
    self.dictionaryListViewController = nil;
    self.contentViewController = nil;
}


- (void)dealloc {
	[toolbar release];
	[titleLabel release];
    [pageNumberLabel release];
    [pageSlider release];
	[htmlView release];
    [contentView release];
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
    [dictionaryPopoverController release];
    [searchButton release];
    [languageButton release];
    [booklistButton release];
    [gotoButton release];
    [noteButton release];
    [bookmarkButton release];
    [titleButton release];
    [dictionaryButton release];
    [languageActionSheet release];
    [gotoActionSheet release];
    [itemOptionsActionSheet release];
    [toastText release];
    [bottomToolbar release];
    //[indicator release];
    [dictionaryListViewController release];
    [contentViewController release];
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
        ContentInfo *info = [[ContentInfo alloc] init];
        
        if (alertView.tag == kGotoItemAlert || alertView.tag == kGotoPageAlert) {
            for(UIView *subview in [alertView subviews]) {
                if([subview isKindOfClass:[UITextField class]]) {
                    NSString *inputText = ((UITextField *)subview).text;
                    if ([inputText length] > 0) {
                        if ([inputText intValue]) {
                            if(alertView.tag == kGotoPageAlert) {
                                info.language = language;
                                info.volume = volume;
                                NSInteger maxPage = [QueryHelper getMaximumPageValue:info];
                                if ([inputText intValue] > 0 && [inputText intValue] <= maxPage) {
                                    NSNumber *newPage = [NSNumber numberWithInt:[inputText intValue]];
                                    [dict setValue:newPage forKey:@"Page"];
                                    [dataDictionary setValue:dict forKey:language];
                                    [self updateReadingPage];
                                }
                                
                            }
                            else if(alertView.tag == kGotoItemAlert) {
                                info.language = language;
                                info.volume = volume;
                                NSInteger maxItem = [QueryHelper getMaximumItemValue:info];
                                if([inputText intValue] > 0 && [inputText intValue] <= maxItem) {
                                    NSNumber *newNumber = [NSNumber numberWithInt:[inputText intValue]];
                                    info.language = language;
                                    info.volume = volume;
                                    info.itemNumber = newNumber;
                                    [info setType:LANGUAGE|VOLUME|ITEM_NUMBER];
                                    NSArray *results = [QueryHelper getItems:info];
                                    
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
                                            [actionSheet showFromBarButtonItem:self.gotoButton 
                                                                      animated:YES];
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
            [info release];
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

- (void) userDidTapView:(id)tapPoint {
    
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



