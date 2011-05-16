//
//  SearchHistoryViewController.m
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchHistoryViewController.h"
#import "SearchViewController.h"
#import "E_TipitakaAppDelegate.h"
#import "History.h"
#import "Utils.h"
#import "Content.h"

@implementation SearchHistoryViewController

@synthesize language;
@synthesize historyData;

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

-(void) deleteJunkRecords {
	E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];	
	
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"History" 
								   inManagedObjectContext:context];	
	[fetchRequest setEntity:entity];
	NSPredicate *pred = [NSPredicate
                         predicateWithFormat:@"(lang == nil)"];
	
	[fetchRequest setPredicate:pred];
        
	NSError *error1;			
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error1];
    [fetchRequest release];

	NSError *error2;    
    for (History *history in fetchedObjects) {
        if ([history.contents count] == 0) {
            NSLog(@"delete %@", history.keywords);
            [context deleteObject:history];
            if (![context save:&error2]) {
                NSLog(@"Whoops, couldn't save: %@", [error2 localizedDescription]);
            }                  
        }
    }
}

-(void) reloadData {
    
    [self deleteJunkRecords];
    
	E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];	
	
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"History" 
								   inManagedObjectContext:context];	
	[fetchRequest setEntity:entity];
	NSPredicate *pred = [NSPredicate 
                         predicateWithFormat:@"(ANY contents.lang == %@ OR lang == %@)",
                         [self.language lowercaseString], [self.language lowercaseString]];
	
	[fetchRequest setPredicate:pred];

    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"keywords" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [sortDescriptor release];
    
	NSError *error;			
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
    self.historyData = [fetchedObjects mutableCopy];
}

-(BOOL) hidesBottomBarWhenPushed {
	return YES;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [language release];
    [historyData release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
								   initWithTitle:@"แก้ไข"
								   style:UIBarButtonItemStyleBordered
								   target:self 
								   action:@selector(toggleEdit:)];
	self.navigationItem.rightBarButtonItem = editButton;
	[editButton release];
    
    [self reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.language = nil;
    self.historyData = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.historyData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (section == 0) {
        History *history = [self.historyData objectAtIndex:row];
        NSString *text = [[NSString alloc] initWithFormat:@"%@", history.keywords];
        cell.textLabel.text = [Utils arabic2thai:text];
        [text release];
        
        NSInteger n1 = 0, n2 = 0, n3 = 0;
        for (Content *content in history.contents) {
            if ([content.volume intValue] <= 8) {
                n1++;
            } else if([content.volume intValue] >= 9 && [content.volume intValue] <= 33) {
                n2++;
            } else {
                n3++;
            }
        }
        text = [[NSString alloc] 
                initWithFormat:@"%4d หน้า: วิ.(%d) สุต.(%d) อภิ.(%d)", 
                [history.contents count] ,n1, n2, n3];
        cell.detailTextLabel.text = [Utils arabic2thai:text];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:22];    
        cell.detailTextLabel.font = [UIFont systemFontOfSize:20];        
        [text release];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath { 
    return 60;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.language isEqualToString:@"Thai"]) {
        return @"ภาษาไทย";
    } else {
        return @"ภาษาบาลี";
    }

}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Update database
		E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];		
		NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
        History *history = [self.historyData objectAtIndex:indexPath.row];
        
        //for(Content *content in history.contents) {
            //[history removeContentsObject:content];
            //[content removeHistoriesObject:history];
        //}
        
        [context deleteObject:history];
        
        [self.historyData removeObjectAtIndex:indexPath.row];
        
		NSError *error;
		if (![context save:&error]) {
			NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
		}        
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView reloadData];
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    SearchViewController *searchController = [self.navigationController.viewControllers objectAtIndex:0];
    
    [searchController loadHistory:[self.historyData objectAtIndex:row]];

    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
