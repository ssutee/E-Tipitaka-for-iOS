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
@synthesize tableData;
@synthesize stageImages;
@synthesize tableView;
@synthesize sortingControl;
@synthesize indicator;

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

-(NSMutableDictionary *) convertHistoryData:(History *)history atRow:(NSUInteger)row
{    
    NSString *text = [[NSString alloc] initWithFormat:@"%@", history.keywords];
    
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
    
    NSString *detail = [[NSString alloc] 
            initWithFormat:@"%4d หน้า: วิ.(%d) สุต.(%d) อภิ.(%d)", 
            [history.contents count] ,n1, n2, n3];

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
    
    NSMutableDictionary *result = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:
     [Utils arabic2thai:text], @"text",
     [Utils arabic2thai:detail], @"detail",
     button,@"accessory", nil] autorelease];
    
    [button release];
    [text release];
    [detail release];
    
    return result;
    
}

// exclude item at end position
-(NSMutableArray *) convertAllHistoryData:(NSArray *)histories from:(NSUInteger)start to:(NSUInteger)end
{
    NSMutableArray *results = [[[NSMutableArray alloc] init] autorelease];
    History *history;
    for (int row=start; row < end; row++) {
        if (row >= [histories count]) {
            break;
        }
        history = [histories objectAtIndex:row];
        [results insertObject:[self convertHistoryData:history atRow:row] atIndex:row];
    }
    return results;
}

-(void) addMoreHistoryData:(NSArray *)histories tableData:(NSMutableArray *)table from:(NSUInteger)start to:(NSUInteger)end {
    History *history;
    for (int row=start; row < end; row++) {
        if (row >= [histories count]) {
            break;
        }
        history = [histories objectAtIndex:row];
        [table insertObject:[self convertHistoryData:history atRow:row] atIndex:row];
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
                         predicateWithFormat:@"(lang == %@)",
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
    
    self.historyData = [[fetchedObjects mutableCopy] autorelease];    
    [self.tableView reloadData];
}

-(BOOL) hidesBottomBarWhenPushed {
	return YES;
}

- (void)dealloc
{
    [language release];
    [historyData release];
    [tableData release];
    [stageImages release];
    [tableView release];
    [sortingControl release];
    [indicator release];
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
    NSMutableDictionary *data = [self.tableData objectAtIndex:senderButton.tag];
    
	E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];	
	
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    if (history.state) {
        history.state = [NSNumber numberWithInteger:([history.state intValue]+1)%4];
    } else {
        history.state = [NSNumber numberWithInteger:1];
    }
    
    UIButton *button = [data valueForKey:@"accessory"];
    
    [button setImage:[UIImage imageNamed:[stageImages objectAtIndex:[history.state intValue]]]
            forState:UIControlStateNormal];
    
    [data setValue:button forKey:@"accessory"];

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
    self.tableData = [self convertAllHistoryData:historyData from:0 to:[historyData count]];
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
        self.tableData = [self convertAllHistoryData:historyData from:0 to:10];
        loading = NO;
        [NSThread sleepForTimeInterval:1];        
        dispatch_async(dispatch_get_main_queue(), ^{   
            [self.tableView reloadData];
        });
        
        while ([self.historyData count] != [self.tableData count]) {
            loading = YES;
            [NSThread sleepForTimeInterval:1];
            dispatch_async(dispatch_get_main_queue(), ^{               
                [self.tableView reloadData];                
            });
            [self addMoreHistoryData:self.historyData 
                           tableData:self.tableData 
                                from:[self.tableData count] to:[self.tableData count]+10];
            loading = NO;
            [NSThread sleepForTimeInterval:1];            
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
    self.tableData = nil;
    self.stageImages = nil;
    self.tableView = nil;
    self.sortingControl = nil;
    self.indicator = nil;
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
    return (loading) ? [self.tableData count] + 1 : [self.tableData count];
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
        // set font
        if (loading && row == [self.tableData count]) {
            if (cell.tag == 0) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                               reuseIdentifier:CellIdentifier] autorelease];
                cell.tag = 1;
            }
            cell.textLabel.text = @"กำลังโหลดข้อมูล กรุณารอสักครู่";
            [cell.textLabel setTextAlignment:UITextAlignmentCenter];
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] 
                                                  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [indicator startAnimating];
            cell.accessoryView = indicator;
            [indicator release];
        } else {
            if (cell.tag == 1) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                               reuseIdentifier:CellIdentifier] autorelease];                
                cell.tag = 0;
            }
            NSMutableDictionary *result = [[self tableData] objectAtIndex:row];
            cell.textLabel.textAlignment = UITextAlignmentLeft;            
            cell.textLabel.text = [result valueForKey:@"text"];
            cell.detailTextLabel.text = [result valueForKey:@"detail"];
            cell.accessoryView = [result valueForKey:@"accessory"];
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
        
        [self.historyData removeObjectAtIndex:indexPath.row];
        [self.tableData removeObjectAtIndex:indexPath.row];
        
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
