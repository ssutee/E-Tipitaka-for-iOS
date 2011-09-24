//
//  SearchViewController.m
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchViewController.h"
#import "ReadViewController.h"
#import "E_TipitakaAppDelegate.h"
#import "Content.h"
#import "Item.h"
#import "History.h"
#import "Utils.h"
#import "SearchHistoryViewController.h"

@implementation SearchViewController

@synthesize table;
@synthesize search;
@synthesize progressBar;
@synthesize results;
@synthesize categories;
@synthesize clickedItems;
@synthesize keywords;
@synthesize scope;
@synthesize readViewController;

-(IBAction)toggleLanguage:(id)sender {
    if(self.search.selectedScopeButtonIndex == kThaiScope) {
        self.search.selectedScopeButtonIndex = kPaliScope;
        self.scope = kPaliScope;
        self.search.placeholder = @"ภาษาบาลี";
        self.navigationItem.title = @"ค้นหา (บาลี)";        
        self.navigationItem.leftBarButtonItem.title = @"ไทย";
    } else if(self.search.selectedScopeButtonIndex == kPaliScope) {
        self.search.selectedScopeButtonIndex = kThaiScope;
        self.scope = kThaiScope;
        self.search.placeholder = @"ภาษาไทย";
        self.navigationItem.title = @"ค้นหา (ไทย)";        
        self.navigationItem.leftBarButtonItem.title = @"บาลี";
    }
	self.search.text = @"";
	[self resetSearch];
	[table reloadData];
    
}

-(IBAction)showSearchHistory:(id)sender {
	SearchHistoryViewController *controller = [[SearchHistoryViewController alloc] 
											   initWithNibName:@"SearchHistoryViewController" bundle:nil];
    controller.navigationItem.title = @"ประวัติค้นหา";
    if(self.scope == kThaiScope) {
        controller.language = @"Thai";        
    } else {
        controller.language = @"Pali";
    }
    
	[[self navigationController] pushViewController:controller animated:YES];
	[controller release], controller = nil;
}

-(void) resetSearch {
	
	NSString *string = [[NSString alloc] initWithString:@""];
	self.keywords = nil;
	self.keywords = string;
	[string release];
	
	NSMutableArray *array = [[NSMutableArray alloc] init];
	self.categories = array;
	
	//[array addObject:@"1"];
	//[array addObject:@"2"];
	//[array addObject:@"3"];	
	
	[array release];

    [self.clickedItems removeAllObjects];
    
	NSMutableArray *value0 = [[NSMutableArray alloc] init];
	NSMutableArray *value1 = [[NSMutableArray alloc] init];
	NSMutableArray *value2 = [[NSMutableArray alloc] init];
	NSMutableArray *value3 = [[NSMutableArray alloc] init];
	
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] 
								 initWithObjectsAndKeys:
								 @"0", value0, @"1", value1, @"2", value2, @"3", value3, nil ];
	//self.results = nil;
	self.results = dict;

	[value0 release];
	[value1 release];
	[value2 release];
	[value3 release];
	
	[dict release];
	
	[table reloadData];
	self.progressBar.hidden = YES;
}

-(void) loadHistory:(History *)history {
    [self resetSearch];

	NSString *string = [[NSString alloc] initWithString:history.keywords];
	self.keywords = string;
	[string release];    
    
    NSMutableArray *array1 = [[NSMutableArray alloc] init];
    NSMutableArray *array2 = [[NSMutableArray alloc] init];
    NSMutableArray *array3 = [[NSMutableArray alloc] init];
    
    // sort contents in history
    NSSortDescriptor *volumeDescriptor;
    volumeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"volume" ascending:YES];
    NSSortDescriptor *pageDescriptor;
    pageDescriptor = [[NSSortDescriptor alloc] initWithKey:@"page" ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:volumeDescriptor,pageDescriptor,nil];
    NSArray *sortedContents = [history.contents sortedArrayUsingDescriptors:sortDescriptors];
    
    [volumeDescriptor release];    
    [pageDescriptor release];
    
    for (Content *content in sortedContents) {
        NSInteger volume = [content.volume intValue];
        if (volume <=8) {
            [array1 addObject:content];
        } else if(volume <=33) {
            [array2 addObject:content];
        } else {
            [array3 addObject:content];
        }
    }
    
    [results setValue:array1 forKey:@"1"];
    [results setValue:array2 forKey:@"2"];
    [results setValue:array3 forKey:@"3"];
        
    NSMutableArray *newKeys = [[NSMutableArray alloc] init];
    NSMutableArray *array0 = [[NSMutableArray alloc] init];
    
    [newKeys addObject:@"0"];
    if(array1 && [array1 count] > 0) {
        [newKeys addObject:@"1"];
        [array0 addObject:[NSNumber numberWithInt:[array1 count]]];
    } else {
        [array0 addObject:[NSNumber numberWithInt:0]];
    }
    
    if(array2 && [array2 count] > 0) {
        [newKeys addObject:@"2"];					
        [array0 addObject:[NSNumber numberWithInt:[array2 count]]];					
    } else {
        [array0 addObject:[NSNumber numberWithInt:0]];
    }
    
    if(array3 && [array3 count] > 0) {
        [newKeys addObject:@"3"];					
        [array0 addObject:[NSNumber numberWithInt:[array3 count]]];					
    } else {
        [array0 addObject:[NSNumber numberWithInt:0]];
    }    
    
    [results setValue:array0 forKey:@"0"];
    self.categories = newKeys;
    
    if([array1 count]+[array2 count]+[array3 count] == 0) {
        notFound = YES;
    } else {
        notFound = NO;
    }    
    
    [table reloadData];
    
    [array0 release];
    [array1 release];
    [array2 release];
    [array3 release];        
    [newKeys release];
}

-(void) handleSearchForTerm:(NSString *)searchTerm {
	[self resetSearch];
	self.search.userInteractionEnabled = NO;
	self.search.alpha = 0.8;
	self.progressBar.hidden = NO;
	self.progressBar.progress = 0.0;

    self.navigationItem.leftBarButtonItem.enabled = NO;

    self.navigationItem.rightBarButtonItem.enabled = NO;
	
	NSString *string = [[NSString alloc] initWithString:searchTerm];
	self.keywords = string;
	[string release];
	
	NSArray *tokens = [searchTerm componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];			
		NSManagedObjectContext *context = [appDelegate managedObjectContext];
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        

        History *history = nil;
        if (isNewKeywords) {
            history = [NSEntityDescription
                       insertNewObjectForEntityForName:@"History" inManagedObjectContext:context];        
            history.keywords = [NSString stringWithString:self.keywords];
			
            if(scope == kThaiScope) {
				history.lang = @"thai";
			}
			else {
				history.lang = @"pali";
			}
            history.created = [NSDate date];
        }
		
        NSEntityDescription *entity = [NSEntityDescription 
									   entityForName:@"Content" 
									   inManagedObjectContext:context];

		[fetchRequest setEntity:entity];
		
		for (int i=1; i<=45; i++) {
			NSMutableArray *predicateArgs = [[NSMutableArray alloc] init];
			NSPredicate *pred;
			NSString *predicateFormat = [NSString stringWithString:@"(volume = %d"];
			[predicateArgs addObject:[NSNumber numberWithInt:i]];
			
			for(NSString *token in tokens) {
				predicateFormat = [predicateFormat stringByAppendingString:@" && text CONTAINS %@"];
				[predicateArgs addObject:[token 
										  stringByReplacingOccurrencesOfString:@"+" 
										  withString:@" "]];
			}
			predicateFormat = [predicateFormat stringByAppendingString:@" && lang = %@)"];
			
			if(scope == kThaiScope) {
				[predicateArgs addObject:@"thai"];
			}
			else {
				[predicateArgs addObject:@"pali"];
			}
			pred = [NSPredicate
					predicateWithFormat:predicateFormat argumentArray:predicateArgs];
			
			[predicateArgs release];

			[fetchRequest setPredicate:pred];

			NSError *error;			
			NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
			
			NSMutableArray *array1 = [[NSMutableArray alloc] initWithArray:[results valueForKey:@"1"]];
			NSMutableArray *array2 = [[NSMutableArray alloc] initWithArray:[results valueForKey:@"2"]];
			NSMutableArray *array3 = [[NSMutableArray alloc] initWithArray:[results valueForKey:@"3"]];
			
			if(fetchedObjects == nil) {
				NSLog(@"Whoops, couldn't fetch: %@", [error localizedDescription]);
			} else {
				
				if ([fetchedObjects count] > 0) {
					
					if (i>=1 && i<=8) {
						for(Content *content in fetchedObjects) {
                            if (isNewKeywords && history) {
                                [history addContentsObject:content];
                                [content addHistoriesObject:history];
                            }
							[array1 addObject:content];
						}
					} else if (i>=9 && i<=33) {
						for(Content *content in fetchedObjects) {
                            if (isNewKeywords && history) {
                                [history addContentsObject:content];
                                [content addHistoriesObject:history];
                            }
							[array2 addObject:content];
						}
					} else {
						for(Content *content in fetchedObjects) {
                            if (isNewKeywords && history) {
                                [history addContentsObject:content];
                                [content addHistoriesObject:history];
                            }
							[array3 addObject:content];
						}
					}
					
					[results setValue:array1 forKey:@"1"];
					[results setValue:array2 forKey:@"2"];
					[results setValue:array3 forKey:@"3"];
					
				} 
			}

			NSMutableArray *newKeys = [[NSMutableArray alloc] init];
			NSMutableArray *array0 = [[NSMutableArray alloc] init];
			//NSLog(@"%d", i);
			if(i == 45) {
				[newKeys addObject:@"0"];
				if(array1 && [array1 count] > 0) {
					//NSLog(@"key 1: %d", [array1 count]);
					[newKeys addObject:@"1"];
					[array0 addObject:[NSNumber numberWithInt:[array1 count]]];
				} else {
					[array0 addObject:[NSNumber numberWithInt:0]];
				}

				if(array2 && [array2 count] > 0) {
					//NSLog(@"key 2: %d", [array2 count]);
					[newKeys addObject:@"2"];					
					[array0 addObject:[NSNumber numberWithInt:[array2 count]]];					
				} else {
					[array0 addObject:[NSNumber numberWithInt:0]];
				}

				if(array3 && [array3 count] > 0) {
					//NSLog(@"key 3: %d", [array3 count]);
					[newKeys addObject:@"3"];					
					[array0 addObject:[NSNumber numberWithInt:[array3 count]]];					
				} else {
					[array0 addObject:[NSNumber numberWithInt:0]];
				}
                
                if([array1 count]+[array2 count]+[array3 count] == 0) {
                    notFound = YES;
                } else {
                    notFound = NO;
                }
                
                NSError *error;
                if (![context save:&error]) {
                    NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                }
			}
			[results setValue:array0 forKey:@"0"];
			self.categories = newKeys;
			[newKeys release];
			[array0 release];
			[array1 release];
			[array2 release];
			[array3 release];
			
			
			dispatch_async(dispatch_get_main_queue(), ^{
				self.progressBar.progress += (1.0/45.0);
				if (i == 45) {
					//search.hidden = NO;
					self.search.userInteractionEnabled = YES;
					self.search.alpha = 1.0;
					self.progressBar.hidden = YES;

                    self.navigationItem.leftBarButtonItem.enabled = YES;                    

                    self.navigationItem.rightBarButtonItem.enabled = YES;
					[table reloadData];
				} 

			});
		}	
		[fetchRequest release];
	});
	
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

- (void)viewWillAppear:(BOOL)animated {
    self.contentSizeForViewInPopover = CGSizeMake(660.0, 600.0);
    [super viewWillAppear:animated];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 4.0f);
    progressBar.transform = transform;
    
    self.contentSizeForViewInPopover = CGSizeMake(660.0, 600.0);

    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    self.clickedItems = array;
    [array release];

    UIBarButtonItem *languageButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@""
                                       style:UIBarButtonItemStyleBordered
                                       target:self 
                                       action:@selector(toggleLanguage:)];
    self.navigationItem.leftBarButtonItem = languageButton;
    [languageButton release];	            

    
	UIBarButtonItem *historyButton = [[UIBarButtonItem alloc]
									   initWithTitle:@"ประวัติค้นหา"
									   style:UIBarButtonItemStyleBordered
									   target:self 
									   action:@selector(showSearchHistory:)];
	self.navigationItem.rightBarButtonItem = historyButton;
	[historyButton release];	    
	
    
	if (self.search.selectedScopeButtonIndex == kThaiScope) {
		self.search.placeholder = @"ภาษาไทย";
        self.navigationItem.leftBarButtonItem.title = @"บาลี";
        self.navigationItem.title = @"ค้นหา (ไทย)";
        //self.title = @"ค้นหา (ไทย)";
	} else {
		self.search.placeholder = @"ภาษาบาลี";
        self.navigationItem.leftBarButtonItem.title = @"ไทย";                
        self.navigationItem.title = @"ค้นหา (บาลี)";        
        //self.title = @"ค้นหา (บาลี)";
	}
    
	self.search.showsCancelButton = NO;	
    
    for(int i =0; i<[search.subviews count]; i++) {
        if([[search.subviews objectAtIndex:i] isKindOfClass:[UITextField class]])
            [(UITextField*)[search.subviews objectAtIndex:i] setFont:[UIFont systemFontOfSize:20]];
    }
	
	[self resetSearch];
	
	[table reloadData];
	
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.search = nil;
	self.table = nil;
	self.progressBar = nil;
	self.categories = nil;
	self.results = nil;
	self.keywords = nil;
    self.readViewController = nil;
    self.clickedItems = nil;
}


- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self 
//                                                    name:UIKeyboardDidHideNotification 
//                                                  object:nil];
	[table release];
	[search release];
	[progressBar release];
	[categories release];
    [clickedItems release];
	[results release];
	[keywords release];
    [readViewController release];
    [super dealloc];
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

#pragma mark - 
#pragma mark Table View Delegate Methods 
- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
	NSUInteger section = [indexPath section];
	
	[search resignFirstResponder]; 

	isSearching = NO;
	[tableView reloadData];
	
	if(section == 0) {
		return nil;
	}

	return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
    NSString *item = [[NSString alloc] initWithFormat:@"%d:%d",section,row];
    
    if (![self.clickedItems containsObject:item]) {
        [self.clickedItems addObject:item];
    }
	
    [item release];
    
	NSString *category = [categories objectAtIndex:section];
	NSArray *resultSection = [results objectForKey:category];	

	Content *content = [resultSection objectAtIndex:row];
		
	NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithDictionary:[Utils readData]];
	NSDictionary *dict = [[NSDictionary alloc] 
						  initWithObjectsAndKeys:content.page, @"Page",
						  content.volume, @"Volume", nil];
	
	if(scope == kThaiScope) {
		[plistDict setValue:@"Thai" forKey:@"Language"];
		[plistDict setValue:dict forKey:@"Thai"];
	} else {
		[plistDict setValue:@"Pali" forKey:@"Language"];		
		[plistDict setValue:dict forKey:@"Pali"];
	}
	
	[Utils writeData:plistDict];
	
	[dict release];	
	[plistDict release];
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UINavigationController* firstNavController = [self.tabBarController.viewControllers objectAtIndex:0];
        ReadViewController* readController = [firstNavController.viewControllers objectAtIndex:0];
        [readController reloadData];
        readController.keywords = self.keywords;        
        readController.scrollToKeyword = YES;
        // no need to call updateReadingPage because the viewDidAppear handles it
        self.tabBarController.selectedIndex = 0;
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.readViewController reloadData];
        self.readViewController.keywords = self.keywords;
        self.readViewController.scrollToKeyword = YES;        
        [self.readViewController updateReadingPage];
        [self.readViewController dismissAllPopoverControllers];
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView { 
	if (isSearching) {
		return nil;
	}
	
	NSMutableArray *index = [[NSMutableArray alloc] init];	
	[index autorelease];
	for(NSString *category in self.categories) {
		if (category == @"0") {
			[index addObject:UITableViewIndexSearch];
		} else if (category == @"1") {
			[index addObject:@"วิ."];
		} else if (category == @"2") {
			[index addObject:@"สุต."];
		} else if (category == @"3") {
			[index addObject:@"อภิ."];
		}
	}
	return index;
}

- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	if(index == 0) {
		[tableView setContentOffset:CGPointZero animated:NO];
		return NSNotFound;
	}
	else {
		return index;
	}

}

#pragma mark - 
#pragma mark Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [categories count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSString *category = [categories objectAtIndex:section];
	NSArray *resultSection = [results objectForKey:category];
    if (section == 0 && notFound) {
        return [resultSection count]+2;
    }
	return [resultSection count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { 
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];

    if (notFound && section == 0 && (row == 3 || row == 4)) {
        return 80;
    } else if(!notFound && section == 0) {
        return 60;
    }
    return 40;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	
	NSString *category = [categories objectAtIndex:section];
	NSArray *resultSection = [results objectForKey:category];
	
	static NSString *SectionsTableIdentifier = @"SectionsTableIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SectionsTableIdentifier];
	
	if(cell == nil) {
        if (section == 0 && (row == 3 || row == 4)) {
            cell = [[[UITableViewCell alloc]
                     initWithStyle:UITableViewCellStyleDefault
                     reuseIdentifier:SectionsTableIdentifier] autorelease];
        } else {
            cell = [[[UITableViewCell alloc]
                     initWithStyle:UITableViewCellStyleSubtitle 
                     reuseIdentifier:SectionsTableIdentifier] autorelease];
        }
	}
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:22];
    cell.textLabel.textAlignment = UITextAlignmentLeft;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:20];
    cell.detailTextLabel.text = nil;
    
	if (section > 0) {
		Content *content = [resultSection objectAtIndex:row];
		NSString *text = [[NSString alloc] 
                          initWithFormat:@"เล่มที่ %@ หน้าที่ %@", content.volume, content.page];
		cell.textLabel.text = [Utils arabic2thai:text];
		[text release];

	} else {
		NSString *label;
        NSMutableArray *tmp = [[NSMutableArray alloc] init];
        NSString *s;
		if(row == 0) {
            s = [NSString stringWithString:@"เล่มที่"];
            [tmp removeAllObjects];
            for (Content *content in [results valueForKey:@"1"]) {
                if (![tmp containsObject:content.volume]) {
                    [tmp addObject:content.volume];
                    s = [NSString stringWithFormat:@"%@ %@", s, content.volume];
                }
            }
			label = [[NSString alloc] initWithFormat:@"พบในพระวินัยปิฎก %@ หน้า จาก %d เล่ม", 
                     [resultSection objectAtIndex:row], [tmp count]];
			cell.textLabel.text = [Utils arabic2thai:label];
            if ([tmp count] > 0) {
                cell.detailTextLabel.text = [Utils arabic2thai:s];            
            }
			[label release];
            
			
		} else if(row == 1) {
            s = [NSString stringWithString:@"เล่มที่"];            
            [tmp removeAllObjects];
            for (Content *content in [results valueForKey:@"2"]) {
                if (![tmp containsObject:content.volume]) {
                    [tmp addObject:content.volume];
                    s = [NSString stringWithFormat:@"%@ %@", s, content.volume];                    
                }
            }
			label = [[NSString alloc] initWithFormat:@"พบในพระสุตตันตปิฎก %@ หน้า จาก %d เล่ม", 
                     [resultSection objectAtIndex:row], [tmp count]];
			cell.textLabel.text = [Utils arabic2thai:label];
            if ([tmp count] > 0) {
                cell.detailTextLabel.text = [Utils arabic2thai:s];            
            } 
			[label release];			
		} else if(row == 2) {
            s = [NSString stringWithString:@"เล่มที่"];             
            [tmp removeAllObjects];
            for (Content *content in [results valueForKey:@"3"]) {
                if (![tmp containsObject:content.volume]) {
                    [tmp addObject:content.volume];
                    s = [NSString stringWithFormat:@"%@ %@", s, content.volume];                    
                }
            }
			label = [[NSString alloc] initWithFormat:@"พบในพระอภิธรรมปิฎก %@ หน้า จาก %d เล่ม", 
                     [resultSection objectAtIndex:row], [tmp count]];
			cell.textLabel.text = [Utils arabic2thai:label];
            if ([tmp count] > 0) {
                cell.detailTextLabel.text = [Utils arabic2thai:s];            
            }
			[label release];
		} else if(row == 3) {
            
            cell.textLabel.font = [UIFont systemFontOfSize:44];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.text = [NSString stringWithFormat:@"ไม่พบคำว่า \"%@\"", keywords];
        } else if(row == 4) {
            cell.textLabel.font = [UIFont systemFontOfSize:44];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            if (scope == kThaiScope) {
                cell.textLabel.text = @"ในพระไตรปิฎก (ภาษาไทย)";
            } else {
                cell.textLabel.text = @"ในพระไตรปิฎก (ภาษาบาลี)";                
            }
        }
        [tmp release], tmp = nil;
	}
    
    
    
	return cell;			
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *category = [categories objectAtIndex:section];
	int count = 0;
	if (category == @"0") {
		if([results valueForKey:@"1"]) {
			count += [[results valueForKey:@"1"] count];
		}
		if([results valueForKey:@"2"]) {
			count += [[results valueForKey:@"2"] count];
		}
		if([results valueForKey:@"3"]) {
			count += [[results valueForKey:@"3"] count];
		}
		NSString *label = [[NSString alloc] 
                           initWithFormat:@"ผลลัพธ์คำว่า \"%@\" พบทั้งหมด %d หน้า", self.keywords, count];
		NSString *newLabel = [[NSString alloc] initWithString:[Utils arabic2thai:label]];
		[newLabel autorelease];
		[label release];
		return newLabel;		
	}
	if (category == @"1") {
		//NSString *label = [[NSString alloc] initWithFormat:@"พระวินัยปิฎก (%d หน้า)", [[results valueForKey:category] count]];
		//[label autorelease];
		//return label;
		return @"พระวินัยปิฎก";
	}
	if (category == @"2") {
		//NSString *label = [[NSString alloc] initWithFormat:@"พระสุตตันตปิฎก (%d หน้า)", [[results valueForKey:category] count]];
		//[label autorelease];
		//return label;
		return @"พระสุตตันตปิฎก";
	}
	if (category == @"3") {
		//NSString *label = [[NSString alloc] initWithFormat:@"พระอภิธรรมปิฎก (%d หน้า)", [[results valueForKey:category] count]];
		//[label autorelease];
		//return label;
		return @"พระอภิธรรมปิฎก";
	}
	
	return category;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath { 

	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
    NSString *item = [[NSString alloc] initWithFormat:@"%d:%d",section,row];
    
    if ([self.clickedItems containsObject:item]) {
        [cell setBackgroundColor:[UIColor colorWithRed:.8 green:.8 blue:.8 alpha:1]];
    } else {
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    [item release];
}

#pragma mark - 
#pragma mark Search Bar Delegate Methods 
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	NSString *searchTerm = [[searchBar text] 
							stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	if ([searchTerm length] > 0) {
		E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];			
		NSManagedObjectContext *context = [appDelegate managedObjectContext];
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription 
                                       entityForName:@"History" 
                                       inManagedObjectContext:context];	
        [fetchRequest setEntity:entity];
        
        NSString *lang;
        if(scope == kThaiScope) {
            lang = @"thai";
        }
        else {
            lang = @"pali";
        }        
        NSPredicate *pred = [NSPredicate 
                             predicateWithFormat:
                             @"(keywords == %@ && lang == %@)", searchTerm, lang];
        [fetchRequest setPredicate:pred];
        
        NSError *error;			
        NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];        
        
        [fetchRequest release];
        
        if (fetchedObjects && [fetchedObjects count] == 0) {
            isNewKeywords = YES;
        } else {
            isNewKeywords = NO;
            // TODO: restore results from history
            //NSLog(@"this keywords was already used to search.");
        }
        [self handleSearchForTerm:searchTerm];
        [searchBar resignFirstResponder]; 
	}
	
}

- (void) searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
	scope = selectedScope;
	if (scope == kThaiScope) {
		searchBar.placeholder = @"ภาษาไทย";
        self.navigationItem.title = @"ค้นหา (ไทย)";        
	} else {
		searchBar.placeholder = @"ภาษาบาลี";
        self.navigationItem.title = @"ค้นหา (บาลี)";        
	}	
}


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar { 
	isSearching = YES; 
	//[self.navigationController setNavigationBarHidden:YES animated:YES];
	[searchBar setShowsCancelButton:YES animated:YES];
    
    for(UIView *subView in searchBar.subviews){
        if([subView isKindOfClass:[UIButton class]]){
            [(UIButton*)subView setTitle:@"ยกเลิก" forState:UIControlStateNormal];
        }
    }
    
    
	[table reloadData];
	
	// display black view
	//self.blackView = [[UIView alloc] initWithFrame:CGRectMake(0, 88, 320, 380)];
	//[blackView setBackgroundColor:[UIColor blackColor]];
	//[blackView setAlpha:0.8];
	//[table addSubview:blackView];
	
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
	//[self.navigationController setNavigationBarHidden:NO animated:YES];
	[searchBar setShowsCancelButton:NO animated:YES];
	
	//[blackView removeFromSuperview];


}

- (void) searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
	SearchHistoryViewController *controller = [[SearchHistoryViewController alloc] 
											   initWithNibName:@"SearchHistoryViewController" bundle:nil];
    controller.navigationItem.title = @"ประวัติค้นหา";
    if(self.scope == kThaiScope) {
        controller.language = @"Thai";        
    } else {
        controller.language = @"Pali";
    }

	[[self navigationController] pushViewController:controller animated:YES];
	[controller release], controller = nil;
	
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	self.search.text = @"";
	//[self resetSearch];
	//[table reloadData];
	[searchBar resignFirstResponder];
}

@end
