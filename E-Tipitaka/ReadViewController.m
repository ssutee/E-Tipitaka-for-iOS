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
#import "UITextInputAlertView.h"
#import "Command.h"
#import "JSONKit.h"
#import "MBProgressHUD.h"
#import "ASIHTTPRequest.h"
#import "ZipArchive.h"

@interface ReadViewController()

@property (nonatomic, retain) MBProgressHUD *HUD;

@end

@implementation ReadViewController

@synthesize toolbar;
@synthesize titleLabel=_titleLabel;
@synthesize pageNumberLabel=_pageNumberLabel;
@synthesize contentView=_contentView;
@synthesize alterItems;
@synthesize searchPopoverController=_searchPopoverController;
@synthesize bookmarkPopoverController=_bookmarkPopoverController;
@synthesize booklistPopoverController;
@synthesize dictionaryPopoverController;
@synthesize dictionaryListViewController;
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
@synthesize pageSlider=_pageSlider;
@synthesize bottomToolbar;
@synthesize HUD = _HUD;

#pragma mark - Getter/Setter Methods

-(MBProgressHUD *)HUD
{
    if (_HUD == nil) {
        if (self.tabBarController) {
            _HUD = [[MBProgressHUD alloc] initWithView:self.tabBarController.view];
            [self.tabBarController.view addSubview:_HUD];
        } else if (self.navigationController) {
            _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
            [self.navigationController.view addSubview:_HUD];
        } else {
            _HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:_HUD];
        }
        _HUD.dimBackground = YES;
        _HUD.delegate = self;
    }
    return _HUD;
}

#pragma mark - MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [self.HUD removeFromSuperview];
	self.HUD = nil;
}

#pragma mark - General Methods


-(void) request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes
{
    float progress = 1.0f * ([request partialDownloadSize]+[request totalBytesRead])/([request contentLength]+[request partialDownloadSize]);    
    self.HUD.progress = progress;
    NSLog(@"%f", progress);
}

-(void) prepareDatabaseByDownloadingFromInternet
{
    ContentInfo *thaiInfo = [[ContentInfo alloc] init];
    ContentInfo *paliInfo = [[ContentInfo alloc] init];    
    thaiInfo.language = @"Thai";
    thaiInfo.volume = [NSNumber numberWithInt:1];
    thaiInfo.page = [NSNumber numberWithInt:1];
    [thaiInfo setType:(LANGUAGE|VOLUME|PAGE)];
    
    paliInfo.language = @"Pali";
    paliInfo.volume = [NSNumber numberWithInt:1];
    paliInfo.page = [NSNumber numberWithInt:1];    
    [paliInfo setType:(LANGUAGE|VOLUME|PAGE)];
    
    NSArray *thaiContents = [QueryHelper getContents:thaiInfo];
    NSArray *paliContents = [QueryHelper getContents:paliInfo];
    
    if(!thaiContents.count || !paliContents.count) {      
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"E_Tipitaka.sqlite"];
        
        NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *compressedDBPath = [cacheDirectory stringByAppendingPathComponent:@"E_Tipitaka.sqlite.zip"];
        NSError *error = nil;
        
        if (![fileManager removeItemAtPath:writableDBPath error:&error]) {
            NSLog(@"Failed to delete existing database file, %@, %@", [error localizedDescription], [error userInfo]);
        }
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://download.watnapahpong.org/data/etipitaka/ios/E_Tipitaka.sqlite.zip"]];
        request.allowResumeForFileDownloads = YES;
        request.allowCompressedResponse = YES;
        request.downloadDestinationPath = compressedDBPath;
        request.temporaryFileDownloadPath = [compressedDBPath stringByAppendingPathExtension:@"download"];
        request.showAccurateProgress = YES;
        request.downloadProgressDelegate = self;
        
        self.HUD.mode = MBProgressHUDModeDeterminate;
        self.HUD.labelText = @"กำลังดาว์นโหลดฐานข้อมูล";
        self.HUD.progress = 0.0f;
        [self.HUD show:YES];
        [request startAsynchronous];
        [request setCompletionBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                ZipArchive *za = [[ZipArchive alloc] init];            
                if ([za UnzipOpenFile:compressedDBPath]) {
                    self.HUD.mode = MBProgressHUDModeIndeterminate;
                    self.HUD.labelText = @"กำลังขยายฐานข้อมูล";
                    if ([za UnzipFileTo:documentsDirectory overWrite:YES]) {
                        NSError *error = nil;
                        if(![fileManager removeItemAtPath:compressedDBPath error:&error]) {
                            NSLog(@"Failed to delete compressed database file, %@, %@", [error localizedDescription], [error userInfo]);
                        }
                        self.HUD.labelText = @"Completed";
                        self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                        self.HUD.mode = MBProgressHUDModeCustomView;
                    }
                }
                [za release];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.HUD hide:YES];                    
                    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Completed" message:@"To complete the process, please restart the program again." delegate:self cancelButtonTitle:@"Exit" otherButtonTitles:nil];    
                    alerView.tag = kQuitAlert;
                    [alerView show];            
                    [alerView release];
                });                
            });
        }];

        [request setFailedBlock:^{
            self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_dialog_alert.png"]];
            self.HUD.mode = MBProgressHUDModeCustomView;        
            self.HUD.labelText = @"Connection Failed";            
            [self.HUD hide:YES];   
            NSLog(@"%@", [request.error localizedDescription]);
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Conection Failed" message:[request.error localizedDescription] delegate:self cancelButtonTitle:@"Exit" otherButtonTitles:nil];    
            alerView.tag = kQuitAlert;
            [alerView show];            
            [alerView release];
        }];
    }
    
    [thaiInfo release];
    [paliInfo release];    
}


- (void)mergeChanges:(NSNotification *)notification
{
    E_TipitakaAppDelegate *application = [[UIApplication sharedApplication] delegate];
    [application.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:notification.object];    
}

// this method is too slow
-(void) prepareDatabaseByPopulatingFromJSONFiles {
    ContentInfo *thaiInfo = [[ContentInfo alloc] init];
    ContentInfo *paliInfo = [[ContentInfo alloc] init];    
    thaiInfo.language = @"Thai";
    thaiInfo.volume = [NSNumber numberWithInt:1];
    thaiInfo.page = [NSNumber numberWithInt:1];
    [thaiInfo setType:(LANGUAGE|VOLUME|PAGE)];

    paliInfo.language = @"Pali";
    paliInfo.volume = [NSNumber numberWithInt:1];
    paliInfo.page = [NSNumber numberWithInt:1];    
    [paliInfo setType:(LANGUAGE|VOLUME|PAGE)];
    
    NSArray *thaiContents = [QueryHelper getContents:thaiInfo];
    NSArray *paliContents = [QueryHelper getContents:paliInfo];

    if(![thaiContents count] || ![paliContents count]) {      
        [self.HUD show:YES];
        self.HUD.mode = MBProgressHUDModeDeterminate;
        self.HUD.labelText = @"โปรแกรมกำลังสร้างฐานข้อมูลเริ่มต้น";
        self.HUD.progress = 0.0f;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            E_TipitakaAppDelegate *application = [[UIApplication sharedApplication] delegate];        
            NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
            NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:resourcePath];            
            NSArray *files = [dirEnum allObjects];
            int jsonFileCount = 0;
            for (NSString *file in files) {
                if ([[file pathExtension] isEqualToString:@"json"]) {
                    jsonFileCount += 1;
                }
            }
            for (NSString *file in files) {
                if (![[file pathExtension] isEqualToString:@"json"]) { continue; }
                self.HUD.progress += 1.0f/ jsonFileCount;                
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] init];
                [ctx setUndoManager:nil];
                [ctx setPersistentStoreCoordinator:[application persistentStoreCoordinator]];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:ctx];
                
                NSError *error = nil;
                NSString *jsonString = [NSString stringWithContentsOfFile:[resourcePath stringByAppendingPathComponent:file] encoding:NSUTF8StringEncoding error:&error];
                id jsonObject = [jsonString objectFromJSONString];
                for (NSString *key in jsonObject) {
                    NSArray *pageValues = [[jsonObject objectForKey:key] objectForKey:@"value"];
                    Content *content = [NSEntityDescription insertNewObjectForEntityForName:@"Content" inManagedObjectContext:ctx];
                    content.page = [NSNumber numberWithInt:[key intValue]];
                    content.text = [pageValues objectAtIndex:1];
                    content.volume = [pageValues objectAtIndex:0];;
                    content.lang = [pageValues objectAtIndex:2];
                    for (NSArray *itemValues in [[jsonObject objectForKey:key] objectForKey:@"items"]) {
                        Item *item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:ctx];
                        item.section = [itemValues objectAtIndex:0];
                        item.sut = [itemValues objectAtIndex:1];
                        item.number = [itemValues objectAtIndex:2];
                        item.begin = [itemValues objectAtIndex:3];
                        item.content = content;
                    }
                }
                error = nil;
                if (![ctx save:&error]) {
                    NSLog(@"%@", [error localizedDescription]);
                }
                [ctx release];                    
                [pool drain];                            
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.HUD hide:YES];                
                [self reloadData];
                [self updateReadingPage];
            });
        });        
    }
    
    [thaiInfo release];
    [paliInfo release];
}

// this method was rejected by AppStore
-(void) prepareDatabaseByCopyingFromBundle {
    
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
                [self reloadData];
                [self updateReadingPage];
            });
        });                     
    } 
}


-(void) updateReadingPage
{
    [super updateReadingPage];

	NSString *newTitle = [Utils createHeaderTitle:[self getCurrentVolume]];    
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
    
}

-(void) gotoItem {
    GotoItemCommand *command = [[GotoItemCommand alloc] initWithController:self];
    [command execute];
    [command release];
}

-(void) gotoPage {
    GotoPageCommand *command = [[GotoPageCommand alloc] initWithController:self];
    [command execute];
    [command release];
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


-(void) resetScrollPositions {    
    for (NSString *key in [self.scrollPostion allKeys]) {
        [self.scrollPostion setValue:[NSNumber numberWithInt:0] forKey:key];
    }
}

- (void) swapLanguage {
    if (self.dataDictionary == nil) {
        [self reloadData];
    }
    
	NSString *language = [self.dataDictionary valueForKey:@"Language"];
	NSNumber *paliVolume = [[self.dataDictionary valueForKey:@"Pali"] valueForKey:@"Volume"];
	NSNumber *thaiVolume = [[self.dataDictionary valueForKey:@"Thai"] valueForKey:@"Volume"];
    
    int position = [[self.contentViewController.webView
                     stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
    
    [self.scrollPostion setValue:[NSNumber numberWithInt:position] forKey:language];
    
	if ([language isEqualToString:@"Thai"]) {
		// change language to Pali
		[self.dataDictionary setValue:@"Pali" forKey:@"Language"];
		if ([paliVolume intValue] != [thaiVolume intValue]) {
			// change Pali volume to Thai volume
			[(NSDictionary *)[self.dataDictionary valueForKey:@"Pali"] 
			 setValue:[NSNumber numberWithInt:[thaiVolume intValue]] forKey:@"Volume"];
		}
	} else {
		// change language to Thai
		[self.dataDictionary setValue:@"Thai" forKey:@"Language"];
		if ([paliVolume intValue] != [thaiVolume intValue]) {
			// change Thai volume to Pali volume
			[(NSDictionary *)[self.dataDictionary valueForKey:@"Thai"] 
			 setValue:[NSNumber numberWithInt:[paliVolume intValue]] forKey:@"Volume"];
		}				
	}
	// update page
	[self updateReadingPage];	
}

- (void) compareLanguage {    
    NSString *language = [self.dataDictionary valueForKey:@"Language"];
    NSNumber *volume = [[self.dataDictionary valueForKey:language] valueForKey:@"Volume"];
    NSNumber *page = [[self.dataDictionary valueForKey:language] valueForKey:@"Page"];
    
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
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && UIInterfaceOrientationIsPortrait(orientation)) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:@"การเทียบเคียงไม่สามารถใช้ในแนวตั้ง" message:@"กรุณาหมุนจอเป็นแนวนอน" 
                              delegate:nil cancelButtonTitle:@"ตกลง" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        return;
    }
    
	NSString *sourceLanguage = [[NSString alloc] initWithString:[self.dataDictionary valueForKey:@"Language"]];
	NSNumber *volume = [[self.dataDictionary valueForKey:sourceLanguage] valueForKey:@"Volume"];
	NSNumber *page = [[self.dataDictionary valueForKey:sourceLanguage] valueForKey:@"Page"];			
	
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
			self.savedItemNumber = [comparedItem.number intValue];
            
			self.scrollToItem = YES;
            self.scrollToKeyword = NO;
    
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                // change language
                [self.dataDictionary setValue:targetLanguage forKey:@"Language"];
                [[self.dataDictionary valueForKey:targetLanguage] setValue:volume 
                                                               forKey:@"Volume"];
                [[self.dataDictionary valueForKey:targetLanguage] setValue:comparedItem.content.page
                                                               forKey:@"Page"];                
                [self updateReadingPage];
            } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [[self.dataDictionary valueForKey:targetLanguage] setValue:volume 
                                                               forKey:@"Volume"];
                [[self.dataDictionary valueForKey:targetLanguage] setValue:comparedItem.content.page
                                                               forKey:@"Page"];                
                [Utils writeData:self.dataDictionary];
                
                DoubleReadViewController *controller = [[DoubleReadViewController alloc] 
                                                        initWithNibName:@"DoubleReadView_iPad" bundle:nil];                

                controller.sourceLanguage = sourceLanguage;
                controller.targetLanguage = targetLanguage;
                
                if (self.keywords) {
                    NSString *str = [[NSString alloc] initWithString:self.keywords];
                    controller.keywords = str;
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
    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = [self getCurrentLanguage];
    info.volume = [self getCurrentVolume];
    info.page = [self getCurrentPage];
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
            [poc release];
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
	NSString *language = [self.dataDictionary valueForKey:@"Language"];
	NSMutableDictionary *dict = [self.dataDictionary valueForKey:language];
	[dict setValue:item.content.page forKey:@"Page"];
	[self.dataDictionary setValue:dict forKey:language];
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
    
    if (self.languageActionSheet != nil && [self.languageActionSheet isVisible]) {
        [self.languageActionSheet 
         dismissWithClickedButtonIndex:[self.languageActionSheet cancelButtonIndex] animated:YES];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
    return NO;
}

#pragma mark -
#pragma mark IBAction Methods

- (IBAction) titleTap:(id) sender
{
	BookListTableViewController *controller = [[BookListTableViewController alloc] 
											   initWithNibName:@"BookListTableViewController" bundle:nil];
	if([((NSString *)[self.dataDictionary valueForKey:@"Language"]) isEqualToString:@"Thai"]) {
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
        [self.languageActionSheet showFromToolbar:toolbar];
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {  
        
        if ([self.languageActionSheet isVisible]) {
            [self.languageActionSheet dismissWithClickedButtonIndex:[self.languageActionSheet cancelButtonIndex] 
                                                      animated:YES];
        } else {
            [self dismissAllPopoverControllers];            
            [self.languageActionSheet showFromBarButtonItem:self.languageButton animated:YES];
        }
    }
}

-(IBAction)nextButtonClicked:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self dismissAllPopoverControllers];
    }
    [super nextButtonClicked:sender];
}  

-(IBAction)backButtonClicked:(id)sender {    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self dismissAllPopoverControllers];
    }
    [super backButtonClicked:sender];
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
	
	NSString *language = [self.dataDictionary valueForKey:@"Language"];
	NSNumber *volume = [[self.dataDictionary valueForKey:language] valueForKey:@"Volume"];
	NSNumber *page = [[self.dataDictionary valueForKey:language] valueForKey:@"Page"];			
	
    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = language;
    info.volume = volume;
    info.page = page;
    info.begin = YES;
    [info setType:LANGUAGE|VOLUME|PAGE|BEGIN];
    NSArray *items = [QueryHelper getItems:info];
    
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
    [info release];
}

-(void)updateLanguageButtonTitle {
	NSString *language = [self.dataDictionary valueForKey:@"Language"];
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
    
    NSString *selection = [self.contentViewController.webView 
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

#pragma mark -
#pragma mark View lifecycle

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        showToolbar = NO;
        self.toolbar.hidden = YES;
        
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            self.contentView.frame = CGRectMake(0, 20, 480, 219);            
        } else {
            self.contentView.frame = CGRectMake(0, 20, 320, 367);   
        }      
        [self updateLanguageButtonTitle];        
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];

    [self prepareDatabaseByDownloadingFromInternet];
    
    mWindow = (TapDetectingWindow *)[[UIApplication sharedApplication].windows objectAtIndex:0];
    mWindow.viewToObserve = self.contentView;
    mWindow.controllerThatObserves = self;	            
    
    // lookup dictionary popup menu
    UIMenuItem *dictionaryMenuItem = [[UIMenuItem alloc] initWithTitle:@"บาลี-ไทย" 
                                                                action:@selector(lookUpDictionary:)];    
    [UIMenuController sharedMenuController].menuItems = [NSArray arrayWithObject:dictionaryMenuItem];
    [dictionaryMenuItem release];
        
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {

        toolbar.hidden = YES;
        
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
        
        NSString *language = [self.dataDictionary valueForKey:@"Language"];
        if ([language isEqualToString:@"Thai"]) {
            self.navigationItem.leftBarButtonItem.title = @"บาลี";
        } else {
            self.navigationItem.leftBarButtonItem.title = @"ไทย";		
        }        
    }     
    
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
    [super viewDidUnload];
	self.toolbar = nil;
    self.searchPopoverController = nil;
    self.bookmarkPopoverController = nil;
    self.booklistPopoverController = nil;
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
    self.bottomToolbar = nil;
    self.dictionaryListViewController = nil;
    
    self.alterItems = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIView *transView = [self.tabBarController.view.subviews objectAtIndex:0];
        if (showToolbar) {
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                transView.frame = CGRectMake(0, 0, 480, 320);
                self.contentView.frame = CGRectMake(0, 20, 480, 224);
            } else {        
                transView.frame = CGRectMake(0, 0, 320, 480);
                self.contentView.frame = CGRectMake(0, 20, 320, 372);
            }
        } else {
            if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
                transView.frame = CGRectMake(0, 0, 480, 271);
                self.contentView.frame = CGRectMake(0, 20, 480, 219);
            } else {
                transView.frame = CGRectMake(0, 0, 320, 431);
                self.contentView.frame = CGRectMake(0, 20, 320, 367);
            }
        }
    }
    
}

- (void)dealloc {
    
	[toolbar release];    
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
    [bottomToolbar release];
    [dictionaryListViewController release];

    [alterItems release];
    [_HUD release];
    
    [super dealloc];
}

#pragma mark - 
#pragma mark Text Field Delegate Methods 

- (void)textFieldDidEndEditing:(UITextField *)textField {
	
}

#pragma mark - 
#pragma mark Alert View Delegate Methods 

- (void)changePage:(NSNumber *)page
{
    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = [self getCurrentLanguage];
    info.volume = [self getCurrentVolume];
    NSInteger maxPage = [QueryHelper getMaximumPageValue:info];
    if ([page intValue] > 0 && [page intValue] <= maxPage) {                                
        [self setCurrentPage:page];        
        [self updateReadingPage];
    }    
    [info release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == kQuitAlert) {
        exit(0);
    }
    
	if (buttonIndex != [alertView cancelButtonIndex]) {        
        if (alertView.tag == kGotoItemAlert || alertView.tag == kGotoPageAlert) {
            NSString *inputText = ((UITextInputAlertView *)alertView).field.text;
            if ([inputText length] > 0 && [inputText intValue]) {
                if(alertView.tag == kGotoPageAlert) {
                    [self changePage:[NSNumber numberWithInt:[inputText intValue]]];
                }
                else if(alertView.tag == kGotoItemAlert) {
                    ContentInfo *info = [[ContentInfo alloc] init];                    
                    info.language = [self getCurrentLanguage];
                    info.volume = [self getCurrentVolume];
                    NSInteger maxItem = [QueryHelper getMaximumItemValue:info];
                    if([inputText intValue] <= maxItem) {
                        self.savedItemNumber = [inputText intValue];                        
                        info.itemNumber = [NSNumber numberWithInt:[inputText intValue]];
                        [info setType:LANGUAGE|VOLUME|ITEM_NUMBER];
                        NSArray *items = [QueryHelper getItems:info];
                        
                        NSArray *array = [[NSArray alloc] initWithArray:items];
                        self.alterItems = array;
                        [array release];                        

                        if ([items count] > 1) {                                    
                            GotoMoreItemsCommand *command = [[GotoMoreItemsCommand alloc] initWithController:self];
                            command.items = items;
                            command.itemNumber = [NSNumber numberWithInt:[inputText intValue]];
                            [command execute];
                            [command release];
                        } else if ([items count] == 1) {
                            self.scrollToItem = YES;
                            self.scrollToKeyword = NO;
                            self.keywords = nil;                            
                            Item *item = [items objectAtIndex:0];
                            [self changePage:item.content.page];
                        } 
                    }
                    [info release];                                
                }
            } 
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
    
    CGRect rect = [_contentView frame];
    
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
        _pageSlider.hidden = !_pageSlider.hidden;
        
        CGRect oldRect = self.contentView.frame;
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
        self.contentView.frame = newRect;
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
            self.contentView.frame = CGRectMake(0, 20, 480, 224);
        } else {        
            transView.frame = CGRectMake(0, 0, 320, 480);
            self.contentView.frame = CGRectMake(0, 20, 320, 372);
        }
    } else {
        tabBar.hidden = FALSE;
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            transView.frame = CGRectMake(0, 0, 480, 271);
            self.contentView.frame = CGRectMake(0, 20, 480, 219);
        } else {
            transView.frame = CGRectMake(0, 0, 320, 431);
            self.contentView.frame = CGRectMake(0, 20, 320, 367);
        }
    }
	toolbar.hidden = !showToolbar;
}


@end



