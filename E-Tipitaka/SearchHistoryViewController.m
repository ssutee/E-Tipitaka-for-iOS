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
@synthesize loadedData;
@synthesize detailTable;
@synthesize stageImages;
@synthesize tableView;
@synthesize sortingControl;
@synthesize backgroundManagedObjectContext = _backgroundManagedObjectContext;

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
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"History" 
								   inManagedObjectContext:self.backgroundManagedObjectContext];	
	[fetchRequest setEntity:entity];
	NSPredicate *pred = [NSPredicate
                         predicateWithFormat:@"(lang == nil)"];
	
	[fetchRequest setPredicate:pred];
        
	NSError *fetchError;			
	NSArray *fetchedObjects = [self.backgroundManagedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    [fetchRequest release];

	NSError *saveError;    
    for (History *history in fetchedObjects) {
        if ([history.contents count] == 0) {
            NSLog(@"delete %@", history.keywords);
            [self.backgroundManagedObjectContext deleteObject:history];
            if (![self.backgroundManagedObjectContext save:&saveError]) {
                NSLog(@"Whoops, couldn't save: %@", [saveError localizedDescription]);
            }                  
        }
    }
}

-(void) loadMoreData:(NSArray *)histories loadedData:(NSMutableArray *)table 
                from:(NSUInteger)start to:(NSUInteger)end {

    for (int row=start; row < end; row++) {
        if (row >= [histories count]) {
            break;
        }
        History *history = [histories objectAtIndex:row];
        [table insertObject:history atIndex:row];
        
        NSInteger n1 = 0, n2 = 0, n3 = 0;
        for (Content *content in history.contents) {
            if ([content.volume intValue] <= 8) {
                n1++;
            } else if([content.volume intValue] <= 33) {
                n2++;
            } else {
                n3++;
            }
        }
        NSString *text = [[NSString alloc] initWithFormat:@"%4d หน้า: วิ.(%d) สุต.(%d) อภิ.(%d)",
                          [history.contents count] ,n1, n2, n3];
        [detailTable setValue:[Utils arabic2thai:text] forKey:history.keywords];
        [text release];        
    }
}

-(void) reloadData {
    NSManagedObjectContext *ctx = [[NSManagedObjectContext alloc] init];
    E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [ctx setPersistentStoreCoordinator:[appDelegate persistentStoreCoordinator]];
    self.backgroundManagedObjectContext = ctx;
    [ctx release];
    
    [self deleteJunkRecords];
    
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"History" 
								   inManagedObjectContext:self.backgroundManagedObjectContext];	
	[fetchRequest setEntity:entity];
	NSPredicate *pred = [NSPredicate 
                         predicateWithFormat:@"(lang == %@)",
                         [self.language lowercaseString], [self.language lowercaseString]];
	
	[fetchRequest setPredicate:pred];

    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"keywords" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [fetchRequest setSortDescriptors:sortDescriptors];
    [sortDescriptor release];
    
	NSError *error;			
	NSArray *fetchedObjects = [self.backgroundManagedObjectContext executeFetchRequest:fetchRequest error:&error];
	[fetchRequest release];
    self.historyData = [[fetchedObjects mutableCopy] autorelease];

    // create empty array
    NSMutableArray *array = [[NSMutableArray alloc] init];
    self.loadedData = array;
    [array release];
    
    // create empty dictionary
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    self.detailTable = dict;
    [dict release];    
    
    [self.tableView reloadData];
}

-(BOOL) hidesBottomBarWhenPushed {
	return YES;
}

- (void)dealloc
{
    [language release];
    [historyData release];
    [loadedData release];
    [stageImages release];
    [tableView release];
    [sortingControl release];
    [detailTable release];
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

- (IBAction) starTapped:(id)sender
{
    UIButton *senderButton = (UIButton *)sender;
        
    History *history = [self.historyData objectAtIndex:senderButton.tag];
    
	E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];	
	
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    if (history.state) {
        history.state = [NSNumber numberWithInteger:([history.state intValue]+1)%4];
    } else {
        history.state = [NSNumber numberWithInteger:1];
    }
    
	NSError *error;    
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    [self.tableView reloadData];
    
}

-(IBAction)sortList:(id)sender {
    NSSortDescriptor *sortDescriptor;
    switch (sortingControl.selectedSegmentIndex) {
        case 0:
            sorting = BY_TEXT;
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"keywords"
                                                          ascending:YES] autorelease];            
            break;
        case 1:
            sorting = BY_PRIORITY;
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"state"
                                                          ascending:NO] autorelease];                        
            break;
        case 2:
            sorting = BY_CREATED;
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"created"
                                                          ascending:YES] autorelease];                                    
            break;
        default:
            sorting = BY_TEXT;
            sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"keywords"
                                                          ascending:YES] autorelease];                        
            break;
    }
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    self.historyData = [[[historyData sortedArrayUsingDescriptors:sortDescriptors] mutableCopy] autorelease];
    self.loadedData = [[[loadedData sortedArrayUsingDescriptors:sortDescriptors] mutableCopy] autorelease];
    
    [self.tableView reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    loading = YES;
    self.contentSizeForViewInPopover = CGSizeMake(660.0, 600.0);
    
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
								   initWithTitle:@"แก้ไข"
								   style:UIBarButtonItemStyleBordered
								   target:self 
								   action:@selector(toggleEdit:)];
	self.navigationItem.rightBarButtonItem = editButton;
	[editButton release];

    NSString *stage1, *stage2, *stage3, *stage4;
    
    stage1 = @"stage_01.png";
    stage2 = @"stage_02.png";
    stage3 = @"stage_03.png";
    stage4 = @"stage_04.png";
    
    NSArray *array = [[NSArray alloc] initWithObjects:stage1, stage2, stage3, stage4, nil];
    self.stageImages = array;
    [array release];
    
    self.sortingControl.enabled = NO;
    self.sortingControl.alpha = 0.2;

    dispatch_async(dispatch_get_global_queue(0, 0), ^{        
        [self reloadData];
        while ([historyData count] != [loadedData count]) {
            loading = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            [NSThread sleepForTimeInterval:0.5];
            [self loadMoreData:historyData loadedData:loadedData 
                          from:[loadedData count] to:[loadedData count]+10];
            loading = NO;
            dispatch_async(dispatch_get_main_queue(), ^{           
                [self.tableView reloadData];                
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{           
            self.sortingControl.enabled = YES;
            self.sortingControl.alpha = 1.0;
            [self.tableView reloadData];                            
        });                    
    });
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.language = nil;
    self.historyData = nil;
    self.loadedData = nil;
    self.detailTable = nil;
    self.stageImages = nil;
    self.tableView = nil;
    self.sortingControl = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    self.contentSizeForViewInPopover = CGSizeMake(660.0, 600.0);
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

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return (loading) ? [loadedData count] + 1 : [loadedData count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                       reuseIdentifier:CellIdentifier] autorelease];
        cell.tag = 0;
    }
    
    if (section == 0) {
        if (loading && row == [loadedData count]) {
            if (cell.tag == 0) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                               reuseIdentifier:CellIdentifier] autorelease];
                cell.tag = 1;
            }
            cell.textLabel.text = @"กำลังโหลดข้อมูล กรุณารอสักครู่";
            [cell.textLabel setTextAlignment:UITextAlignmentCenter];
            UIActivityIndicatorView *indicator = [[[UIActivityIndicatorView alloc] 
                                                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
            [indicator startAnimating];
            cell.accessoryView = indicator;
        } else {
            History *history = [historyData objectAtIndex:row];
            if (cell.tag == 1) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                               reuseIdentifier:CellIdentifier] autorelease];                
                cell.tag = 0;
            }

            cell.textLabel.textAlignment = UITextAlignmentLeft;            
            cell.textLabel.text = history.keywords;
            cell.detailTextLabel.text = [detailTable valueForKey:history.keywords];
            
            UIImage *buttonStar;
            if (history.state) {
                buttonStar = [UIImage imageNamed:[stageImages objectAtIndex:[history.state intValue]]];  
            } else {
                buttonStar = [UIImage imageNamed:[stageImages objectAtIndex:0]];   
            }
            
            UIButton *button = [[UIButton alloc] init];
            button.tag = row;
            button.frame = CGRectMake(0.0, 0.0, buttonStar.size.width, buttonStar.size.height);
            [button setImage:buttonStar forState:UIControlStateNormal];
            [button addTarget:self action:@selector(starTapped:) forControlEvents:UIControlEventTouchUpInside];            
            cell.accessoryView = button;
            [button release];
            
            cell.textLabel.font = [UIFont boldSystemFontOfSize:22];    
            cell.detailTextLabel.font = [UIFont systemFontOfSize:20];                     
        }
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
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
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
        
        [historyData removeObjectAtIndex:indexPath.row];
        [loadedData removeObjectAtIndex:indexPath.row];
        
		NSError *error;
		if (![context save:&error]) {
			NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
		}        
        
        // Delete the row from the data source
        [aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                         withRowAnimation:UITableViewRowAnimationFade];
        [aTableView reloadData];
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

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (loading) {
        return nil;
    }
    return indexPath;
}

//- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
//    CGPoint offset = aScrollView.contentOffset;
//    CGRect bounds = aScrollView.bounds;
//    CGSize size = aScrollView.contentSize;
//    UIEdgeInsets inset = aScrollView.contentInset;
//    float y = offset.y + bounds.size.height - inset.bottom;
//    float h = size.height;    
//    float reload_distance = 40;
//    
//    willReload = (y > h + reload_distance) ? YES : NO;
//    
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView willDecelerate:(BOOL)decelerate {
//    if (willReload && [self.historyData count] > [self.tableData count] && loading == NO) {
//        loading = YES;
//        [self.tableView reloadData];
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            [NSThread sleepForTimeInterval:1];            
//            [self addMoreHistoryData:self.historyData 
//                           tableData:self.tableData 
//                                from:[self.tableData count] to:[self.tableData count]+10];            
//            loading = NO;            
//            [self.tableView reloadData];
//            [NSThread sleepForTimeInterval:.5];                        
//        });
//    }
//}

@end
