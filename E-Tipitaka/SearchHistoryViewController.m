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
#import "MBProgressHUD.h"

@interface SearchHistoryViewController()<MBProgressHUDDelegate>

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsSortedByKeywordsController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsSortedByStateController;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsSortedByCreatedController;
@property (nonatomic, retain) MBProgressHUD *progressHUD;

@end

@implementation SearchHistoryViewController

@synthesize language;
@synthesize historyData;
@synthesize loadedData;
@synthesize detailTable;
@synthesize stageImages;
@synthesize sortingControl;
@synthesize backgroundManagedObjectContext = _backgroundManagedObjectContext;
@synthesize fetchedResultsSortedByCreatedController = _fetchedResultsSortedByCreatedController;
@synthesize fetchedResultsSortedByKeywordsController = _fetchedResultsSortedByKeywordsController;
@synthesize fetchedResultsSortedByStateController = _fetchedResultsSortedByStateController;
@synthesize progressHUD = _progressHUD;

- (NSFetchedResultsController *)fetchedResultsSortedByKeywordsController
{
    if (_fetchedResultsSortedByKeywordsController == nil) {        
        E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription 
                                       entityForName:@"History" 
                                       inManagedObjectContext:appDelegate.managedObjectContext];	
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
        
        _fetchedResultsSortedByKeywordsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                        managedObjectContext:appDelegate.managedObjectContext
                                                                                          sectionNameKeyPath:nil cacheName:@"Search History Keywords Cache"];;
        [fetchRequest release];        
    }
    return _fetchedResultsSortedByKeywordsController;
}

- (NSFetchedResultsController *)fetchedResultsSortedByStateController
{
    if (_fetchedResultsSortedByStateController == nil) {
        E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription 
                                       entityForName:@"History" 
                                       inManagedObjectContext:appDelegate.managedObjectContext];	
        [fetchRequest setEntity:entity];
        NSPredicate *pred = [NSPredicate 
                             predicateWithFormat:@"(lang == %@)",
                             [self.language lowercaseString], [self.language lowercaseString]];
        
        [fetchRequest setPredicate:pred];
        
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"state" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [sortDescriptor release];
        
        _fetchedResultsSortedByStateController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                     managedObjectContext:appDelegate.managedObjectContext
                                                                                       sectionNameKeyPath:nil cacheName:@"Search History State Cache"];
        [fetchRequest release]; 
    }
    return _fetchedResultsSortedByStateController;
}

- (NSFetchedResultsController *)fetchedResultsSortedByCreatedController
{
    if (_fetchedResultsSortedByCreatedController == nil) {
        E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription 
                                       entityForName:@"History" 
                                       inManagedObjectContext:appDelegate.managedObjectContext];	
        [fetchRequest setEntity:entity];
        NSPredicate *pred = [NSPredicate 
                             predicateWithFormat:@"(lang == %@)",
                             [self.language lowercaseString], [self.language lowercaseString]];
        
        [fetchRequest setPredicate:pred];
        
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"created" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        [fetchRequest setSortDescriptors:sortDescriptors];
        [sortDescriptor release];
        
        _fetchedResultsSortedByCreatedController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                       managedObjectContext:appDelegate.managedObjectContext
                                                                                         sectionNameKeyPath:nil cacheName:@"Search History Created Cache"];
        [fetchRequest release];         
    }
    return _fetchedResultsSortedByCreatedController;
}

- (MBProgressHUD *)progressHUD
{
    if (_progressHUD == nil) {
        _progressHUD = [[MBProgressHUD alloc] initWithWindow:self.view.window];
        _progressHUD.mode = MBProgressHUDModeDeterminate;
        _progressHUD.labelText = @"ประมวลผลข้อมูล";
        _progressHUD.dimBackground = YES;
        _progressHUD.progress = 0.0;
    }
    return _progressHUD;
}

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
    [_fetchedResultsSortedByKeywordsController release];
    [_fetchedResultsSortedByCreatedController release];
    [_fetchedResultsSortedByStateController release];
    [_progressHUD release];
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

- (IBAction) starTapped:(id)sender
{
    UIButton *senderButton = (UIButton *)sender;
        
    History *history = [self.fetchedResultsController.fetchedObjects objectAtIndex:senderButton.tag];    
    
    if (history.state) {
        history.state = [NSNumber numberWithInteger:([history.state intValue]+1)%4];
    } else {
        history.state = [NSNumber numberWithInteger:1];
    }    
}

-(IBAction)sortList:(id)sender {
    switch (sortingControl.selectedSegmentIndex) {
        case 0:
            sorting = BY_TEXT;
            self.fetchedResultsController = self.fetchedResultsSortedByKeywordsController;
            break;
        case 1:
            sorting = BY_PRIORITY;
            self.fetchedResultsController = self.fetchedResultsSortedByStateController;
            break;
        case 2:
            sorting = BY_CREATED;
            self.fetchedResultsController = self.fetchedResultsSortedByCreatedController;
            break;
        default:
            sorting = BY_TEXT;
            self.fetchedResultsController = self.fetchedResultsSortedByKeywordsController;
            break;
    }    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView = (UITableView *)self.view;
    
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
    
    self.fetchedResultsController = self.fetchedResultsSortedByKeywordsController;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.language = nil;
    self.historyData = nil;
    self.loadedData = nil;
    self.detailTable = nil;
    self.stageImages = nil;
    self.tableView = nil;
    self.sortingControl = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.contentSizeForViewInPopover = CGSizeMake(660.0, 600.0);   
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.progressHUD.superview == nil) {
        self.suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
        [self.view.window addSubview:self.progressHUD];
        [self.progressHUD show:YES];
        
        dispatch_queue_t historyDetailQueue = dispatch_queue_create("history detail queue", NULL);
        
        dispatch_async(historyDetailQueue, ^{
            int count = 1;
            for (History *history in self.fetchedResultsController.fetchedObjects) {
                if (history.detail == nil) {
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
                    history.detail = [Utils arabic2thai:text];                
                    [text release];                                        
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.progressHUD.progress = 1.0 * count / self.fetchedResultsController.fetchedObjects.count;
                });                
                count += 1;                
                NSLog(@"%d %f", count, self.progressHUD.progress);
            }        
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.progressHUD hide:YES];
                self.suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
                NSError *error = nil;
                if (![self.fetchedResultsController.managedObjectContext save:&error]) {
                    NSLog(@"%@", error.localizedDescription);
                }
                [self.tableView reloadData];                
            });
        });
        
        dispatch_release(historyDetailQueue);
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSError *error = nil;
    if (![self.fetchedResultsController.managedObjectContext save:&error]) {
        NSLog(@"%@", error.localizedDescription);
    }
}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle 
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    
    History *history = [self.fetchedResultsController.fetchedObjects objectAtIndex:row];
    
    cell.textLabel.textAlignment = UITextAlignmentLeft;            
    cell.textLabel.text = history.keywords;
    cell.detailTextLabel.text = history.detail;            
    
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return !loading;
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        History *history = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
        [self.fetchedResultsController.managedObjectContext deleteObject:history];
        NSError *error = nil;
        if (![self.fetchedResultsController.managedObjectContext save:&error]) {
            NSLog(@"%@", error.localizedDescription);
        }        
        [self.tableView reloadData];
    }   
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    SearchViewController *searchController = [self.navigationController.viewControllers objectAtIndex:0];
    [searchController loadHistory:[self.fetchedResultsController.fetchedObjects objectAtIndex:row]];

    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if (loading) {
        return nil;
    }
    return indexPath;
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [super controllerWillChangeContent:controller];
    self.sortingControl.enabled = NO;
    self.sortingControl.alpha = 0.2;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [super controllerDidChangeContent:controller];
    self.sortingControl.enabled = YES;
    self.sortingControl.alpha = 1.0;    
}

#pragma mark - MBProgressHUD delegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [self.progressHUD removeFromSuperview];
}

@end
