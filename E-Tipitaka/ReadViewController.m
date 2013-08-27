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
#import "ImportListViewController.h"
#import "Bookmark.h"
#import "History.h"
#import "Content.h"
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
#import "ZipArchive.h"
#import <Socialize/Socialize.h>
#import "CommentViewController.h"
#import "ExportTool.h"

@interface ReadViewController()<SocializeServiceDelegate, ImportListViewControllerDelegate, UIGestureRecognizerDelegate>
{
    BOOL _isDownloadingDatabase;
}
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) SZActionBar *actionBar;
@property (nonatomic, strong) UIActionSheet *fontColorActionSheet;

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
@synthesize importFilePopoverController=_importFilePopoverController;
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
@synthesize dataToolsActionSheet = _dataToolsActionSheet;
@synthesize toastText;
@synthesize pageSlider=_pageSlider;
@synthesize bottomToolbar;
@synthesize HUD = _HUD;
@synthesize actionBar = _actionBar;
@synthesize fontColorActionSheet = _fontColorActionSheet;

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

-(void)setActionBar:(SZActionBar *)actionBar
{
    if (![[_actionBar.entity name] isEqualToString:[actionBar.entity name]]) {
        _actionBar = actionBar;
    }
}

#pragma mark - MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [self.HUD removeFromSuperview];
	self.HUD = nil;
}

#pragma mark - General Methods


-(void) prepareDatabaseByDownloadingFromInternet
{
    _isDownloadingDatabase = NO;
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
        _isDownloadingDatabase = YES;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"E_Tipitaka.sqlite"];
        
        NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *compressedDBPath = [cacheDirectory stringByAppendingPathComponent:@"E_Tipitaka.sqlite.zip"];
        NSError *error = nil;
        
        if (![fileManager removeItemAtPath:writableDBPath error:&error]) {
            NSLog(@"Failed to delete existing database file, %@, %@", [error localizedDescription], [error userInfo]);
        }
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://download.watnapahpong.org/data/etipitaka/ios/E_Tipitaka.sqlite.zip"]];
        AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:compressedDBPath shouldResume:YES];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.HUD hide:YES afterDelay:2];
                    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"คำเตือน" message:@"ก่อนเปิดโปรแกรมอีกครั้ง\nให้กดปุ่ม Home สองครั้งติดต่อกัน\nแล้วเลือกปิดโปรแกรมที่รันค้างอยู่ทั้งหมดก่อน\nไม่เช่นนั้นโปรแกรมอาจเปิดไม่ขึ้น" delegate:self cancelButtonTitle:@"เริ่มต้นใหม่" otherButtonTitles:nil];
                    alerView.tag = kQuitAlert;
                    [alerView show];
                });
            });
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_dialog_alert.png"]];
            self.HUD.mode = MBProgressHUDModeCustomView;
            self.HUD.labelText = @"Connection Failed";
            [self.HUD hide:YES afterDelay:2];
            NSLog(@"%@", [error localizedDescription]);
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Conection Failed" message:error.localizedDescription delegate:self cancelButtonTitle:@"Exit" otherButtonTitles:nil];
            alerView.tag = kQuitAlert;
            [alerView show];
        }];

        [operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
            float progress = 1.0f * totalBytesReadForFile / totalBytesExpectedToReadForFile;
            self.HUD.progress = progress;
            NSLog(@"%f", progress);
        }];
        
        self.HUD.mode = MBProgressHUDModeDeterminate;
        self.HUD.labelText = @"กำลังดาวน์โหลดฐานข้อมูล";
        self.HUD.progress = 0.0f;
        [self.HUD show:YES];
        [operation start];        
    }
    
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
                @autoreleasepool {
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
                }                            
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.HUD hide:YES];                
                [self reloadData];
                [self updateReadingPage];
            });
        });        
    }
    
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
        
        UIAlertView *dbAlert = [[UIAlertView alloc] 
                                 initWithTitle:@"โปรดรอซักครู่\nโปรแกรมกำลังสร้างฐานข้อมูลเริ่มต้น" 
                                 message:nil
                                 delegate:self 
                                 cancelButtonTitle:nil 
                                 otherButtonTitles:nil, nil];
        
        [dbAlert show];
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        // Adjust the indicator so it is up a few pixels from the bottom of the alert
        indicator.center = CGPointMake(dbAlert.bounds.size.width / 2, dbAlert.bounds.size.height - 50);
        [indicator startAnimating];
        [dbAlert addSubview:indicator];
        
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
//    Reachability *reachability = [Reachability reachabilityForInternetConnection];
//    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    
    NSString *entityName;
    
    if ([[self getCurrentLanguage] isEqualToString:@"Thai"]) {
        entityName = [[NSString alloc] initWithFormat:@"พระไตรปิฎก (ภาษาไทย) เล่มที่ %@ หน้าที่ %@", 
                     [self getCurrentVolume], [self getCurrentPage]];
    } else {
        entityName = [[NSString alloc] initWithFormat:@"พระไตรปิฎก (ภาษาบาลี) เล่มที่ %@ หน้าที่ %@", 
                     [self getCurrentVolume], [self getCurrentPage]];        
    }
    
    // http://www.etipitaka.com/read?language=thai&number=1&volume=1
    
    SocializeEntity *entity = [SocializeEntity entityWithKey:[NSString stringWithFormat:@"http://www.etipitaka.com/read?language=%@&number=%@&volume=%@", [[self getCurrentLanguage] lowercaseString], [self getCurrentPage], [self getCurrentVolume]] name:entityName];

    [self.actionBar removeFromSuperview];
    self.actionBar = [SZActionBar defaultActionBarWithFrame:CGRectZero entity:entity viewController:self];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {        
        self.actionBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        self.actionBar.frame = CGRectMake(0, self.view.bounds.size.height-bottomToolbar.bounds.size.height-SOCIALIZE_ACTION_PANE_HEIGHT, self.view.bounds.size.width, SOCIALIZE_ACTION_PANE_HEIGHT);
    } else {
        self.actionBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;        
        self.actionBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, SOCIALIZE_ACTION_PANE_HEIGHT);
    }

    if (bottomToolbar && bottomToolbar.hidden) {
        self.actionBar.hidden = YES;
    }
    
    [self.view addSubview:self.actionBar];
    
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
}

-(void) gotoPage {
    GotoPageCommand *command = [[GotoPageCommand alloc] initWithController:self];
    [command execute];
}

-(void) showItemOptions:(NSArray *)items withTag:(NSInteger)tagNumber withTitle:(NSString *)titleName {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
	
	actionSheet.title = titleName;
	actionSheet.delegate = self;
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
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
}

- (void) doCompare:(NSInteger)buttonIndex {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && UIInterfaceOrientationIsPortrait(orientation)) {
        UIAlertView *alert = [[UIAlertView alloc] 
                              initWithTitle:@"การเทียบเคียงไม่สามารถใช้ในแนวตั้ง" message:@"กรุณาหมุนจอเป็นแนวนอน" 
                              delegate:nil cancelButtonTitle:@"ตกลง" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
	NSString *sourceLanguage = [self.dataDictionary valueForKey:@"Language"];
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
                    controller.keywords = self.keywords;
                }
                
                controller.savedItemNumber = [comparedItem.number intValue];
                controller.scrollToItem = YES;

                [self.navigationController pushViewController:controller animated:YES];
                controller = nil;                
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

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[Utils arabic2thai:title] 
                                                             message:@"\n\n"
                                                            delegate:self cancelButtonTitle:@"ตกลง" 
                                                   otherButtonTitles:nil];
            [alert addSubview:textLabel];
            [alert show];
        }
	}
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
        }
		controller = nil;
	}
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
    if (self.importFilePopoverController != nil && [self.importFilePopoverController isPopoverVisible]) {
        [self.importFilePopoverController dismissPopoverAnimated:YES];
    }
    if (dictionaryPopoverController != nil && [dictionaryPopoverController isPopoverVisible]) {
        [dictionaryPopoverController dismissPopoverAnimated:YES];
    }
    if (self.languageActionSheet != nil && [self.languageActionSheet isVisible]) {
        [self.languageActionSheet 
         dismissWithClickedButtonIndex:[self.languageActionSheet cancelButtonIndex] animated:YES];
    }
    if (self.fontColorActionSheet != nil && [self.fontColorActionSheet isVisible]) {
        [self.fontColorActionSheet
         dismissWithClickedButtonIndex:[self.fontColorActionSheet cancelButtonIndex] animated:YES];
    }

    if (gotoActionSheet != nil && [gotoActionSheet isVisible]) {
        [gotoActionSheet
         dismissWithClickedButtonIndex:[gotoActionSheet cancelButtonIndex] animated:YES];
    }
    if (itemOptionsActionSheet != nil && [itemOptionsActionSheet isVisible]) {
        [itemOptionsActionSheet
         dismissWithClickedButtonIndex:[itemOptionsActionSheet cancelButtonIndex] animated:YES];
    }
    if (self.dataToolsActionSheet != nil && [self.dataToolsActionSheet isVisible]) {
        [self.dataToolsActionSheet dismissWithClickedButtonIndex:[self.dataToolsActionSheet cancelButtonIndex] animated:YES];
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

- (BOOL)shouldAutorotate {
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return orientation != UIInterfaceOrientationPortraitUpsideDown;
    }
}

- (void)exportData {
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.labelText = @"กำลังนำข้อมูลออก";
    [self.HUD show:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [ExportTool exportData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.HUD hide:YES];
        });
    });
}

- (void)importData {
    if(self.importFilePopoverController != nil) {
        if ([self.importFilePopoverController isPopoverVisible]) {
            [self.importFilePopoverController dismissPopoverAnimated:YES];
        } else {
            [self dismissAllPopoverControllers];
            [self.importFilePopoverController presentPopoverFromBarButtonItem:self.dataToolsButton
                                              permittedArrowDirections:UIPopoverArrowDirectionAny
                                                              animated:YES];
        }
    } else {
        ImportListViewController *importListViewController = [[ImportListViewController alloc] init];
        importListViewController.title = @"เลือกไฟล์ที่ต้องการนำเข้า";
        importListViewController.delegate = self;
        UINavigationController *navController = [[UINavigationController alloc]
                                                 initWithRootViewController:importListViewController];
        UIPopoverController *poc = [[UIPopoverController alloc]
                                    initWithContentViewController:navController];
        [self dismissAllPopoverControllers];
        [poc presentPopoverFromBarButtonItem:self.dataToolsButton
                    permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        self.booklistPopoverController = poc;
    }
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
	controller = nil;	
}

- (IBAction)showComments:(id)sender
{
    CommentViewController *controller = [[CommentViewController alloc] initWithNibName:@"CommentViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];    
    controller = nil;
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
        self.delegate = searchViewController;
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
    }
}

- (void)tap:(UITapGestureRecognizer *)recognizer
{
    NSLog(@"%@", recognizer);
}

-(IBAction)dataTools:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.dataToolsActionSheet showFromToolbar:toolbar];
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if ([self.dataToolsActionSheet isVisible]) {
            [self.dataToolsActionSheet dismissWithClickedButtonIndex:[self.dataToolsActionSheet cancelButtonIndex] animated:YES];
        } else {
            [self dismissAllPopoverControllers];
            [self.dataToolsActionSheet showFromBarButtonItem:self.dataToolsButton animated:YES];
        }
    }
}

-(IBAction)fontColor:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.fontColorActionSheet showFromToolbar:toolbar];
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if ([self.fontColorActionSheet isVisible]) {
            [self.fontColorActionSheet dismissWithClickedButtonIndex:[self.fontColorActionSheet cancelButtonIndex]
                                                           animated:YES];
        } else {
            [self dismissAllPopoverControllers];
            [self.fontColorActionSheet showFromBarButtonItem:self.fontColorButton animated:YES];
        }
    }

}

- (void)changeFontColor:(NSInteger)index
{
    NSUserDefaults *userDefaults =  [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:[NSNumber numberWithInteger:index] forKey:@"FontColorIndex"];
    [userDefaults synchronize];
    [self updateReadingPage];
}

#pragma mark -
#pragma mark View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    
    [self prepareDatabaseByDownloadingFromInternet];
    
    mWindow = (TapDetectingWindow *)[[UIApplication sharedApplication].windows objectAtIndex:0];
    
    mWindow.viewToObserve = self.contentView;
    mWindow.controllerThatObserves = self;
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;

    self.toolbar.translucent = NO;
    self.toolbar.barStyle = UIBarStyleBlackOpaque;
    
    self.bottomToolbar.translucent = NO;
    self.bottomToolbar.barStyle = UIBarStyleBlackOpaque;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {

        toolbar.hidden = YES;
        
        UIBarButtonItem *selectButton = [[UIBarButtonItem alloc]
                                         initWithTitle:@"เลือก" 
                                         style:UIBarButtonItemStyleBordered
                                         target:self 
                                         action:@selector(titleTap:)];
        self.navigationItem.rightBarButtonItem = selectButton;
        
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
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	actionSheet.tag = kLanguageActionSheet;
	[actionSheet addButtonWithTitle:@"สลับภาษา"];
	[actionSheet addButtonWithTitle:@"เทียบเคียง"];
	[actionSheet addButtonWithTitle:@"ยกเลิก"];
	[actionSheet setCancelButtonIndex:2];    
    self.languageActionSheet = actionSheet;    
    
    // create action sheet for goto menu
	actionSheet = [[UIActionSheet alloc] init];	
	actionSheet.title = @"โปรดเลือกคำสั่งที่ต้องการ";
	actionSheet.delegate = self;
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	actionSheet.tag = kGotoActionSheet;
	[actionSheet addButtonWithTitle:@"อ่านหน้าที่"];
	[actionSheet addButtonWithTitle:@"อ่านข้อที่"];
	[actionSheet addButtonWithTitle:@"ยกเลิก"];
	[actionSheet setCancelButtonIndex:2];
    self.gotoActionSheet = actionSheet;
    
    // create action sheet for data tools
    actionSheet = [[UIActionSheet alloc] init];
    actionSheet.title = @"โปรดเลือกคำสั่งที่ต้องการ";
    actionSheet.delegate = self;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = kDataToolsActionSheet;
    [actionSheet addButtonWithTitle:@"นำข้อมูลเข้า"];
    [actionSheet addButtonWithTitle:@"นำข้อมูลออก"];
    self.dataToolsActionSheet = actionSheet;
    
    // create action sheet for font color
	actionSheet = [[UIActionSheet alloc] init];
	actionSheet.title = @"โปรดเลือกสีอักษรที่ต้องการ";
	actionSheet.delegate = self;
	actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	actionSheet.tag = kFontColorActionSheet;
	[actionSheet addButtonWithTitle:@"ดำ"];
	[actionSheet addButtonWithTitle:@"ขาว"];
	[actionSheet addButtonWithTitle:@"น้ำตาล"];
	[actionSheet addButtonWithTitle:@"ยกเลิก"];
	[actionSheet setCancelButtonIndex:3];
    self.fontColorActionSheet = actionSheet;
    
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    [self dismissAllPopoverControllers];
    
    self.searchPopoverController = nil;
    self.bookmarkPopoverController = nil;
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [self setDataToolsButton:nil];
    [super viewDidUnload];
	self.toolbar = nil;
    self.searchPopoverController = nil;
    self.bookmarkPopoverController = nil;
    self.importFilePopoverController = nil;
    self.booklistPopoverController = nil;
    self.searchButton = nil;
    self.languageButton = nil;    
    self.gotoButton = nil;
    self.noteButton = nil;
    self.bookmarkButton = nil;    
    self.titleButton = nil;
    self.dictionaryButton = nil;
    self.languageActionSheet = nil;
    self.fontColorActionSheet = nil;
    self.gotoActionSheet = nil;
    self.itemOptionsActionSheet = nil;
    self.dataToolsActionSheet = nil;
    self.bottomToolbar = nil;
    self.alterItems = nil;
    self.actionBar = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        UIView *transView = [self.tabBarController.view.subviews objectAtIndex:0];
        NSLog(@"%@", self.tabBarController.tabBar);
        UIView *tabBar = self.tabBarController.tabBar;
        if (tabBar.hidden) {
            tabBar.hidden = FALSE;
            transView.frame = CGRectMake(0, 0, transView.frame.size.width, transView.frame.size.height - tabBar.frame.size.height);
            self.contentView.frame = CGRectMake(0, self.contentView.frame.origin.y, self.contentView.frame.size.width, self.contentView.frame.size.height + toolbar.frame.size.height);
            toolbar.hidden = YES;
            self.actionBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, SOCIALIZE_ACTION_PANE_HEIGHT);
            showToolbar = NO;
        }                
        [self updateLanguageButtonTitle];        
    }
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:kFacebookSharingKey] isEqualToString:@"No"] && ![SZFacebookUtils isLinked] && !_isDownloadingDatabase) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Facebook Login Request" message:@"คุณต้องใช้การแบ่งปันข้อมูลแบบออนไลน์ผ่าน Facebook หรือไม่?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertView.tag = kFacebookAlert;
        [alertView show];
    }
        
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
                        [info setType:LANGUAGE|VOLUME|ITEM_NUMBER];                        
                        self.savedItemNumber = [inputText intValue];
                        info.itemNumber = [NSNumber numberWithInt:inputText.intValue];
                        NSArray *items = [QueryHelper getItems:info];
                        NSArray *array = [[NSArray alloc] initWithArray:items];
                        self.alterItems = array;

                        if ([items count] > 1) {                                    
                            GotoMoreItemsCommand *command = [[GotoMoreItemsCommand alloc] initWithController:self];
                            command.items = items;
                            command.itemNumber = [NSNumber numberWithInt:[inputText intValue]];
                            [command execute];
                        } else if ([items count] == 1) {
                            self.scrollToItem = YES;
                            self.scrollToKeyword = NO;
                            self.keywords = nil;                            
                            Item *item = [items objectAtIndex:0];
                            [self changePage:item.content.page];
                        } 
                    }
                }
            }
        } else if(alertView.tag == kFacebookAlert) {
            [Socialize storeConsumerKey:@"da599d2b-0d97-4ae0-992e-f413e589a53e"];
            [Socialize storeConsumerSecret:@"df7e464e-466e-47bb-b8f8-b06026f1543a"];
            [SZFacebookUtils setAppId:@"173041622753730"];
        }

    } else if (alertView.tag == kFacebookAlert) {
        [[NSUserDefaults standardUserDefaults] setValue:@"No" forKey:kFacebookSharingKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
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
	} else if (actionSheet.tag == kDataToolsActionSheet) {
        if (buttonIndex == 0) {
            [self importData];
        } else if (buttonIndex == 1) {
            [self exportData];
        }
    } else if (actionSheet.tag == kFontColorActionSheet) {
        [self changeFontColor:buttonIndex];
    }
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
        if (bottomToolbar.hidden) {
            self.actionBar.hidden = NO;
            self.actionBar.frame = CGRectMake(0, self.view.bounds.size.height-88, self.view.bounds.size.width, SOCIALIZE_ACTION_PANE_HEIGHT);
        } else {
            self.actionBar.hidden = YES;
        }
        bottomToolbar.hidden = !bottomToolbar.hidden;        
        _pageSlider.hidden = !_pageSlider.hidden;        
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGRect oldRect = self.contentView.frame;
        CGRect newRect;
        if (bottomToolbar.hidden) {
            newRect = CGRectMake(oldRect.origin.x,
                                 oldRect.origin.y-30,
                                 oldRect.size.width,
                                 oldRect.size.height+44+30+44);
        } else {
            newRect = CGRectMake(oldRect.origin.x,
                                 oldRect.origin.y+30,
                                 oldRect.size.width,
                                 oldRect.size.height-44-30-44);
        }
        self.contentView.frame = newRect;
    } else {
        showToolbar = !showToolbar;
        toolbar.hidden = !showToolbar;
    }
}

#pragma mark - ImportListViewControllerDelegate

- (void)impotListViewControllerDidFinish:(ImportListViewController *)controller {
    [self dismissAllPopoverControllers];
}

@end



