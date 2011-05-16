//
//  BookListTableViewController.m
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "E_TipitakaAppDelegate.h"
#import "ReadViewController.h"
#import "BookListTableViewController.h"
#import "Utils.h"


@implementation BookListTableViewController

@synthesize namesDictionary;
@synthesize categories;
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

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 700.0);            
    }
    
	NSArray *array = [[NSArray alloc] initWithObjects:@"พระวินัยปิฎก",@"พระสุตตันตปิฎก",@"พระอภิธรรมปิฎก",nil];
	self.categories = array;
	[array release];
		
    self.namesDictionary = [Utils readNames];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(BOOL) hidesBottomBarWhenPushed {
	return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if (section == 0) {
		return 8;
	} else if (section == 1) {
		return 25;
	} else if (section == 2) {
		return 12;
	}
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { 
    return 60;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSUInteger section = indexPath.section;
	NSUInteger row = indexPath.row;
	
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSInteger volume;
	if (section == 0) {
		volume = row + 1;
	} else if(section == 1) {
		volume = row + 9;
	} else {
		volume = row + 34;
	}

    NSArray *bookInfo = [[namesDictionary valueForKey:@"Names"] objectAtIndex:volume-1];
    
    NSString *label = [[NSString alloc] initWithFormat:@"%d. %@", volume, [bookInfo objectAtIndex:0]];
    cell.textLabel.text = [Utils arabic2thai:label];
    cell.detailTextLabel.text = [bookInfo objectAtIndex:1];
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:22];    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:20];


    //NSLog(@"%@ %f", cell.textLabel.font.fontName, cell.textLabel.font.pointSize);
    //NSLog(@"%@ %f", cell.detailTextLabel.font.fontName, cell.detailTextLabel.font.pointSize);
    
	[label release];
	
    return cell;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"พระวินัยปิฎก";
	} else if (section == 1) {
		return @"พระสุตตันตปิฎก";
	} else {
		return @"พระอภิธรรมปิฎก";
	}
}

#pragma mark -
#pragma mark Table view delegate

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    NSArray *index = [NSArray arrayWithObjects:@"วิ.",@"สุต.",@"อภิ.",nil];
    return index;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUInteger section = indexPath.section;
	NSUInteger row = indexPath.row;

	NSUInteger volume;
	
	if (section == 0) {
		volume = row + 1;
	} else if (section == 1) {
		volume = row + 9;
	} else {
		volume = row + 34;
	}
	
	NSMutableDictionary *plistDict = [[NSMutableDictionary alloc] initWithDictionary:[Utils readData]];
	NSDictionary *dict1 = [[NSDictionary alloc] 
						  initWithObjectsAndKeys:
						  [NSNumber numberWithInt:1], @"Page",
						  [NSNumber numberWithInt:volume], @"Volume", nil];

	NSDictionary *dict2 = [[NSDictionary alloc] 
						   initWithObjectsAndKeys:
						   [NSNumber numberWithInt:1], @"Page",
						   [NSNumber numberWithInt:volume], @"Volume", nil];
	
	[plistDict setValue:dict1 forKey:@"Thai"];
	[plistDict setValue:dict2 forKey:@"Pali"];
	
	[Utils writeData:plistDict];
	
	[dict1 release];
	[dict2 release];
	[plistDict release];
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        ReadViewController* readController = [[self.navigationController viewControllers] objectAtIndex:0];
        [readController reloadData];
        [readController updateReadingPage];
        [readController resetScrollPositions];
        [self.navigationController popViewControllerAnimated:YES];
    } 
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [readViewController reloadData];
        [readViewController updateReadingPage];
        [readViewController resetScrollPositions];
        [readViewController dismissAllPopoverControllers];        
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
    self.namesDictionary = nil;
	self.categories = nil;
}


- (void)dealloc {
	[categories release];
    [readViewController release];
    [namesDictionary release];
    [super dealloc];
}


@end

