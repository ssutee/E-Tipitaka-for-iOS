//
//  BookmarkListViewController.m
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookmarkListViewController.h"
#import "BookmarkEditViewController.h"
#import "E_TipitakaAppDelegate.h"
#import "ReadViewController.h"
#import "Bookmark.h"
#import "Item.h"
#import "Content.h"
#import "Utils.h"

@implementation EditBookmarkButton

@synthesize section;
@synthesize row;

@end


@implementation BookmarkListViewController

@synthesize bookmarkData;
@synthesize language;
@synthesize readViewController;

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

- (void)reloadData {
	NSMutableArray *array1 = [[NSMutableArray alloc] init];
	NSMutableArray *array2 = [[NSMutableArray alloc] init];
	NSMutableArray *array3 = [[NSMutableArray alloc] init];	
	
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] 
								 initWithObjectsAndKeys:
								 array1, kVinaiKey, 
								 array2, kSuttanKey, 
								 array3, kAbhidhumKey, nil];
	[array1 release];
	[array2 release];
	[array3 release];
	
	self.bookmarkData = dict;
	
	[dict release];
	
	E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];	
	
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"Bookmark" 
								   inManagedObjectContext:context];	
	[fetchRequest setEntity:entity];
	NSPredicate *pred = [NSPredicate 
					   predicateWithFormat:@"(item.content.lang = %@)",
					   [self.language lowercaseString]];
	
	[fetchRequest setPredicate:pred];
	
	NSError *error;			
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	
	[fetchRequest release];
	
	if (fetchedObjects) {
		NSSortDescriptor *sortDescriptor;
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"item.content.volume" ascending:YES];
		NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
		NSArray *sortedBookmarks = [fetchedObjects sortedArrayUsingDescriptors:sortDescriptors];
		[sortDescriptor release];
		
		for(Bookmark *bookmark in sortedBookmarks) {
			NSNumber *volume = bookmark.item.content.volume;
			if ([volume intValue] <= 8) {
				[[self.bookmarkData valueForKey:kVinaiKey] addObject:bookmark];
			} else if ([volume intValue] > 8 && [volume intValue] <= 33) {
				[[self.bookmarkData valueForKey:kSuttanKey] addObject:bookmark];					
			} else {
				[[self.bookmarkData valueForKey:kAbhidhumKey] addObject:bookmark];					
			}
			
			//NSLog(@"%@",bookmark.item.content.volume);
		}			
	}
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark IBAction

-(IBAction)toggleEdit:(id)sender {
	[self.tableView setEditing:!self.tableView.editing animated:YES];
	if (self.tableView.editing) {
		[self.navigationItem.rightBarButtonItem setTitle:@"สำเร็จ"];
		[self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
	} else {
		[self.navigationItem.rightBarButtonItem setTitle:@"ลบ"];
		[self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleBordered];
	}
}

-(IBAction)toggleLanguage:(id)sender {
	NSString *newLanguage;	
	if([self.language isEqualToString:@"Thai"]) {
		newLanguage = [[NSString alloc] initWithString:@"Pali"];
		self.language = newLanguage;
		[newLanguage release];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.navigationItem.title = @"ภาษาบาลี";		
        }
		[self.navigationItem.leftBarButtonItem setTitle:@"ไทย"];
	} else {
		newLanguage = [[NSString alloc] initWithString:@"Thai"];		
		self.language = newLanguage;
		[newLanguage release];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.navigationItem.title = @"ภาษาไทย";		
        }
		[self.navigationItem.leftBarButtonItem setTitle:@"บาลี"];		
	}
	[self reloadData];

}

-(IBAction)editBookmark:(id)sender {
    EditBookmarkButton *button = (EditBookmarkButton *)sender;
    
	BookmarkEditViewController *controller = [[BookmarkEditViewController alloc] 
											   initWithNibName:@"BookmarkEditViewController" 
                                              bundle:nil];
    
    controller.navigationItem.title = @"แก้ไขการจดจำ";

    if (button.section == 0) {
        controller.bookmark = [[self.bookmarkData valueForKey:kVinaiKey] objectAtIndex:button.row];
    } else if (button.section == 1) {
        controller.bookmark = [[self.bookmarkData valueForKey:kSuttanKey] objectAtIndex:button.row];        
    } else if (button.section == 2) {
        controller.bookmark = [[self.bookmarkData valueForKey:kAbhidhumKey] objectAtIndex:button.row];                
    }     
        
	[[self navigationController] pushViewController:controller animated:YES];
	[controller release], controller = nil;    
    
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 500.0);

    self.title = @"รายการบันทึก";
    
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
								   initWithTitle:@"ลบ"
								   style:UIBarButtonItemStyleBordered
								   target:self 
								   action:@selector(toggleEdit:)];
	self.navigationItem.rightBarButtonItem = editButton;
	[editButton release];

	UIBarButtonItem *languageButton = [[UIBarButtonItem alloc]
								   initWithTitle:@"บาลี"
								   style:UIBarButtonItemStyleBordered
								   target:self 
								   action:@selector(toggleLanguage:)];
	self.navigationItem.leftBarButtonItem = languageButton;
	[languageButton release];
	
	NSDictionary *plistDict = [Utils readData];
	
	NSString *text = [[NSString alloc] initWithString:[plistDict valueForKey:@"Language"]];
	self.language = text;
	[text release];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if ([self.language isEqualToString:@"Thai"]) {
            self.navigationItem.title = @"ภาษาไทย";
        } else {
            self.navigationItem.title = @"ภาษาบาลี";
        }
    }
	
    [super viewDidLoad];	
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self reloadData];
	[self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
	self.bookmarkData = nil;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0) {
		return [[self.bookmarkData valueForKey:kVinaiKey] count];
	} else if (section == 1) {
		return [[self.bookmarkData valueForKey:kSuttanKey] count];		
	} else if (section == 2) {
		return [[self.bookmarkData valueForKey:kAbhidhumKey] count];		
	}
    return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = indexPath.row;
	NSUInteger section = indexPath.section;
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	Bookmark *bookmark;
	
	if (section == 0) {
		bookmark = [[self.bookmarkData valueForKey:kVinaiKey] objectAtIndex:row];
	} else if (section == 1) {
		bookmark = [[self.bookmarkData valueForKey:kSuttanKey] objectAtIndex:row];		
	} else if (section == 2) {
		bookmark = [[self.bookmarkData valueForKey:kAbhidhumKey] objectAtIndex:row];		
	}
	
	if (bookmark) {
		NSString *text = [[NSString alloc] 
						  initWithFormat:@"เล่มที่ %@ หน้าที่ %@ ข้อที่ %@", 
						  bookmark.item.content.volume,
						  bookmark.item.content.page,
						  bookmark.item.number];
		cell.textLabel.text = [Utils arabic2thai:text];
		[text release];
		cell.detailTextLabel.text = bookmark.text;
        EditBookmarkButton *button = [[EditBookmarkButton alloc] init];

        UIImage *image = [UIImage imageNamed:@"ic_menu_edit.png"];
        
        
        button.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
        [button setImage:image forState:UIControlStateNormal];
        
        [button setSection:section];
        [button setRow:row];

        //[button setTitle:@"แก้ไข" forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(editBookmark:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
        
        [button release];
        
	}
    cell.textLabel.font = [UIFont boldSystemFontOfSize:22];    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:20];  
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		if ([[self.bookmarkData valueForKey:kVinaiKey] count] > 0) {
			return kVinaiKey;
		}
		return @"";
	} else if (section == 1) {
		if ([[self.bookmarkData valueForKey:kSuttanKey] count] > 0) {
			return kSuttanKey;
		}
		return @"";
	} else if (section == 2) {
		if ([[self.bookmarkData valueForKey:kAbhidhumKey] count] > 0) {
			return kAbhidhumKey;
		}
		return @"";
	}
	return @"Unknown section";
}



// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { 
    return 60;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = indexPath.row;
	NSUInteger section = indexPath.section;
	NSMutableArray *array;
	Bookmark *bookmark;	
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];		
		NSManagedObjectContext *context = [appDelegate managedObjectContext];			

		if (section == 0) {
			array = [self.bookmarkData valueForKey:kVinaiKey];
			bookmark = [array objectAtIndex:row];
			[context deleteObject:bookmark];
			[array removeObjectAtIndex:row];
		} else if (section == 1) {
			array = [self.bookmarkData valueForKey:kSuttanKey];
			bookmark = [array objectAtIndex:row];			
			[context deleteObject:bookmark];			
			[array removeObjectAtIndex:row];			
		} else if (section == 2) {
			array = [self.bookmarkData valueForKey:kAbhidhumKey];
			bookmark = [array objectAtIndex:row];			
			[context deleteObject:bookmark];			
			[array removeObjectAtIndex:row];			
		} 

		NSError *error;
		if (![context save:&error]) {
			NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
		}		

        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[tableView reloadData];
    }
}



/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = indexPath.row;
	NSUInteger section = indexPath.section;
	NSMutableArray *array;
	Bookmark *bookmark = nil;	
	
	if (section == 0) {
		array = [self.bookmarkData valueForKey:kVinaiKey];
		bookmark = [array objectAtIndex:row];
	} else if (section == 1) {
		array = [self.bookmarkData valueForKey:kSuttanKey];
		bookmark = [array objectAtIndex:row];			
	} else if (section == 2) {
		array = [self.bookmarkData valueForKey:kAbhidhumKey];
		bookmark = [array objectAtIndex:row];			
	} 
	
	if (bookmark) {
		NSDictionary *plistDict = [Utils readData];
		[plistDict setValue:self.language forKey:@"Language"];
		[[plistDict valueForKey:self.language] setValue:bookmark.item.content.volume forKey:@"Volume"];
		[[plistDict valueForKey:self.language] setValue:bookmark.item.content.page forKey:@"Page"];		
		[Utils writeData:plistDict];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            UINavigationController* firstNavController = [self.tabBarController.viewControllers objectAtIndex:0];
            ReadViewController* readController = [firstNavController.viewControllers objectAtIndex:0];
            [readController reloadData];
            readController.scrollToItem = YES;
            readController.savedItemNumber = [bookmark.item.number intValue];
            [readController updateReadingPage:nil];		
            self.tabBarController.selectedIndex = 0;		
        }
        else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [readViewController reloadData];
            readViewController.scrollToItem = YES;
            readViewController.savedItemNumber = [bookmark.item.number intValue];
            [readViewController updateReadingPage];
            [readViewController dismissAllPopoverControllers];
        }
	}
	
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	self.language = nil;
    self.readViewController = nil;
}

- (void)dealloc {
    [super dealloc];
	[bookmarkData release];
	[language release];
    [readViewController release];
}

#pragma mark -
#pragma mark Tab Bar Controller Delegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
	//NSLog(@"tabbar");
	if (self.tableView.editing) {
		return NO;
	} 
	return YES;
}

@end

