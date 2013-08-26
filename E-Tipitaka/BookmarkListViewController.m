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
#import "Bookmark+Helper.h"
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
@synthesize tableView = _tableView;
@synthesize sortingControl;

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

- (BOOL)shouldAutorotate {
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return orientation != UIInterfaceOrientationPortraitUpsideDown;
    }
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
	
	self.bookmarkData = dict;
	
	
	E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];	
	
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"Bookmark" 
								   inManagedObjectContext:context];	
	[fetchRequest setEntity:entity];
    
	NSPredicate *pred = sorting == ONLY_IMPORTANCE ? [NSPredicate predicateWithFormat:@"item.content.lang = %@ AND important = 1", self.language.lowercaseString] : [NSPredicate predicateWithFormat:@"item.content.lang = %@", self.language.lowercaseString];
	
	[fetchRequest setPredicate:pred];
	
	NSError *error;			
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	
	
	if (fetchedObjects) {
		NSSortDescriptor *sortDescriptor;
        switch (sorting) {
            case BY_CREATED:
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:NO];
                break;
            case BY_TEXT:
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"text" ascending:YES];
                break;
            case BY_VOLUME:
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"item.content.volume" ascending:YES];
                break;
            case ONLY_IMPORTANCE:
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
                break;
            default:
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"item.content.volume" ascending:YES];
                break;
        }

        NSArray *sortedBookmarks = nil;
        if (sortDescriptor) {
            NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
            sortedBookmarks = [fetchedObjects sortedArrayUsingDescriptors:sortDescriptors];
        } else {
            sortedBookmarks = fetchedObjects;
        }
		
		for(Bookmark *bookmark in sortedBookmarks) {
			NSNumber *volume = bookmark.item.content.volume;
			if ([volume intValue] <= 8) {
				[[self.bookmarkData valueForKey:kVinaiKey] addObject:bookmark];
			} else if ([volume intValue] > 8 && [volume intValue] <= 33) {
				[[self.bookmarkData valueForKey:kSuttanKey] addObject:bookmark];					
			} else {
				[[self.bookmarkData valueForKey:kAbhidhumKey] addObject:bookmark];					
			}
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
		[self.navigationItem.rightBarButtonItem setTitle:@"แก้ไข"];
		[self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleBordered];
	}
}

-(IBAction)toggleLanguage:(id)sender {
	NSString *newLanguage;	
	if([self.language isEqualToString:@"Thai"]) {
		newLanguage = @"Pali";
		self.language = newLanguage;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.navigationItem.title = @"ภาษาบาลี";		
        }
		[self.navigationItem.leftBarButtonItem setTitle:@"ไทย"];
	} else {
		newLanguage = @"Thai";
		self.language = newLanguage;
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
	controller = nil;    
    
}

-(IBAction)sortList:(id)sender {
    switch (sortingControl.selectedSegmentIndex) {
        case 0:
            sorting = BY_TEXT;
            break;
        case 1:
            sorting = BY_VOLUME;
            break;
        case 2:
            sorting = BY_CREATED;
            break;
        case 3:
            sorting = ONLY_IMPORTANCE;
            break;
        default:
            sorting = BY_VOLUME;
            break;
    }
    [self reloadData];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gestureRecognizer locationInView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
        if (indexPath) {
            Bookmark *bookmark = nil;
            
            if (indexPath.section == 0) {
                bookmark = [[self.bookmarkData valueForKey:kVinaiKey] objectAtIndex:indexPath.row];
            } else if (indexPath.section == 1) {
                bookmark = [[self.bookmarkData valueForKey:kSuttanKey] objectAtIndex:indexPath.row];
            } else if (indexPath.section == 2) {
                bookmark = [[self.bookmarkData valueForKey:kAbhidhumKey] objectAtIndex:indexPath.row];
            }
            
            if (bookmark && bookmark.important.boolValue) {
                bookmark.important = [NSNumber numberWithBool:NO];
            } else if (bookmark && !bookmark.important.boolValue) {
                bookmark.important = [NSNumber numberWithBool:YES];
            }
            
            E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            NSError *error = nil;
            [appDelegate.managedObjectContext save:&error];
            if (error) {
                NSLog(@"%@", error.localizedDescription);
            } else {
                [self reloadData];
            }
        }
    }
}

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad
{
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    for (Bookmark *bookmark in [Bookmark bookmarksWithoutOrderInManagedObjectContext:appDelegate.managedObjectContext]) {
        bookmark.order = [NSNumber numberWithDouble:[bookmark.created timeIntervalSince1970]];
    }
    
    NSError *error = nil;
    [appDelegate.managedObjectContext save:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGestureRecognizer.minimumPressDuration = 1.5; //seconds
    longPressGestureRecognizer.delegate = self;
    [self.tableView addGestureRecognizer:longPressGestureRecognizer];
    
    self.contentSizeForViewInPopover = CGSizeMake(350.0, 500.0);

    sorting = BY_TEXT;
    
    self.title = @"รายการบันทึก";
    
    UIButton *titleNavLabel = [UIButton buttonWithType:UIButtonTypeCustom];
    titleNavLabel.showsTouchWhenHighlighted = YES;
    [titleNavLabel setTitle:@"รายการบันทึก" forState:UIControlStateNormal];
    titleNavLabel.frame = CGRectMake(0, 0, 230, 44);
    
    titleNavLabel.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [titleNavLabel addTarget:self action:@selector(sortList:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = titleNavLabel;	
    
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
								   initWithTitle:@"แก้ไข"
								   style:UIBarButtonItemStyleBordered
								   target:self 
								   action:@selector(toggleEdit:)];
	self.navigationItem.rightBarButtonItem = editButton;

	UIBarButtonItem *languageButton;
    if ([self.language isEqualToString:@"Thai"]) {
        languageButton = [[UIBarButtonItem alloc] initWithTitle:@"บาลี"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self 
                                                         action:@selector(toggleLanguage:)];
    } else {
        languageButton = [[UIBarButtonItem alloc] initWithTitle:@"ไทย"
                                                          style:UIBarButtonItemStyleBordered
                                                         target:self 
                                                         action:@selector(toggleLanguage:)];        
    }
    
	self.navigationItem.leftBarButtonItem = languageButton;
	
	NSDictionary *plistDict = [Utils readData];
	
	NSString *text = [plistDict valueForKey:@"Language"];
	self.language = text;

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
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = indexPath.row;
	NSUInteger section = indexPath.section;
	
    static NSString *CellIdentifier = @"Bookmark Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
	Bookmark *bookmark = nil;
	
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
        cell.textLabel.textColor = bookmark.important.boolValue ? [UIColor redColor] : [UIColor blackColor];
		cell.textLabel.text = bookmark.text;
        cell.textLabel.numberOfLines = 2;
		cell.detailTextLabel.text = [Utils arabic2thai:text];
        EditBookmarkButton *button = [[EditBookmarkButton alloc] init];

        UIImage *image = [UIImage imageNamed:@"ic_menu_edit.png"];
        
        
        button.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
        [button setImage:image forState:UIControlStateNormal];
        
        [button setSection:section];
        [button setRow:row];

        //[button setTitle:@"แก้ไข" forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(editBookmark:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
        
        
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
    return 85;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
        [aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[aTableView reloadData];
    }
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray *array = nil;
    if (fromIndexPath.section == 0) {
        array = [self.bookmarkData valueForKey:kVinaiKey];
    } else if (fromIndexPath.section == 1) {
        array = [self.bookmarkData valueForKey:kSuttanKey];
    } else if (fromIndexPath.section == 2) {
        array = [self.bookmarkData valueForKey:kAbhidhumKey];
    }
    
    if (array) {
        Bookmark *sourceBookmark = [array objectAtIndex:fromIndexPath.row];
        Bookmark *targetBookmark = [array objectAtIndex:toIndexPath.row];
        double sourceOrder = sourceBookmark.order.doubleValue;
        sourceBookmark.order = [NSNumber numberWithDouble:targetBookmark.order.doubleValue];
        targetBookmark.order = [NSNumber numberWithDouble:sourceOrder];
        E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSError *error = nil;
        [appDelegate.managedObjectContext save:&error];

        if (!error) {
            [self reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }

    }
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return sorting == ONLY_IMPORTANCE;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    // limit UITableView row reordering to a section
    // source: http://stackoverflow.com/questions/849926/how-to-limit-uitableview-row-reordering-to-a-section
    
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        NSInteger row = 0;
        if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
            row = [self.tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
        }
        return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];
    }
    return proposedDestinationIndexPath;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
            [readController updateReadingPage];		
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

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;    
    float reload_distance = 40;
    
    willReload = (y > h + reload_distance) ? YES : NO;
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"end dragging");
    if (willReload) {
        NSLog(@"load more cells");
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
    self.tableView = nil;
    self.sortingControl = nil;
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

