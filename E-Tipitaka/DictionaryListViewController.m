//
//  DictionaryListViewController.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 7/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define HEAD_FONT           @"Helvetica"
#define HEAD_SIZE           26
#define TRANSLATION_FONT    @"Helvetica"
#define TRANSLATION_SIZE    22

#define CELL_WIDTH_IPHONE   230
#define CELL_WIDTH_IPAD     640

#define CELL_MIN_HEIGHT 65
#define CELL_PADDING 10

#define allTrim(object) [object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]

#import "DictionaryListViewController.h"
#import "E_TipitakaAppDelegate.h"
#import "Utils.h"
#import "PaliThai.h"


@implementation DictionaryListViewController

@synthesize searchBar;
@synthesize tableView;
@synthesize fetchedResults;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    
    [searchBar release];
    [tableView release];
    [fetchedResults release];    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(CGFloat)getTranslationHeightForIndex:(NSInteger)index
{
    CGSize maximumSize;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        maximumSize = CGSizeMake(CELL_WIDTH_IPAD, 10000);
    } else {
        maximumSize = CGSizeMake(CELL_WIDTH_IPHONE, 10000);
    }
    PaliThai *item = [fetchedResults objectAtIndex:index];
    CGSize translaitonHeighSize = [item.translation 
                                   sizeWithFont:[UIFont fontWithName:TRANSLATION_FONT 
                                                                size:TRANSLATION_SIZE]                                   
                                   constrainedToSize:maximumSize
                                   lineBreakMode:UILineBreakModeWordWrap];
    
    return translaitonHeighSize.height;
    
}

-(CGFloat)getHeadHeightForIndex:(NSInteger)index
{
    CGSize maximumSize;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        maximumSize = CGSizeMake(CELL_WIDTH_IPAD, 10000);
    } else {
        maximumSize = CGSizeMake(CELL_WIDTH_IPHONE, 10000);
    }
    PaliThai *item = [fetchedResults objectAtIndex:index];
    CGSize headHeighSize = [item.head 
                            sizeWithFont:[UIFont fontWithName:HEAD_FONT 
                                                         size:HEAD_SIZE]
                            constrainedToSize:maximumSize
                            lineBreakMode:UILineBreakModeWordWrap];
    
    return headHeighSize.height;
    
}

//This just a convenience function to get the height of the label based on the comment text
-(CGFloat)getCellHeightForIndex:(NSInteger)index
{
    return [self getTranslationHeightForIndex:index] + [self getHeadHeightForIndex:index];
}



- (BOOL)checkDatabase {
    E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];			
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"PaliThai" 
                                   inManagedObjectContext:context];	
    [fetchRequest setEntity:entity];
    
    NSError *error;			
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];        
    
    [fetchRequest release];    
    
    if (!fetchedObjects) {
        NSLog(@"Error: %@", [error localizedDescription]);
        return NO;
    }
    
    if (fetchedObjects && [fetchedObjects count] == 0) {
        return NO;
    }
    
    return YES;
}

- (void)handleSearchForTerm:(NSString *)searchTerm {
    
    isBlank = [allTrim(searchTerm) length] > 0 ? NO : YES;
    
    if (isBlank) {
        return;
    }
    
    E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];			
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"PaliThai" 
                                   inManagedObjectContext:context];	
    [fetchRequest setEntity:entity];
        
    NSString *newTerm = [NSString 
                         stringWithUTF8String:[Utils 
                                               replace:[searchTerm UTF8String] 
                                               pattern:[[NSString 
                                                         stringWithFormat:@"%C", 3597] UTF8String]
                                               replacement:[[NSString 
                                                             stringWithFormat:@"%C", 63247] UTF8String]]];
    newTerm = [NSString 
               stringWithUTF8String:[Utils 
                                     replace:[newTerm UTF8String] 
                                     pattern:[[NSString 
                                               stringWithFormat:@"%C", 3661] UTF8String]
                                     replacement:[[NSString 
                                                   stringWithFormat:@"%C", 63249] UTF8String]]];
    newTerm = [NSString 
               stringWithUTF8String:[Utils 
                                     replace:[newTerm UTF8String] 
                                     pattern:[[NSString 
                                               stringWithFormat:@"%C", 3600] UTF8String]
                                     replacement:[[NSString 
                                                   stringWithFormat:@"%C", 63232] UTF8String]]];
    
    
    NSPredicate *pred = [NSPredicate 
                         predicateWithFormat:
                         @"(head BEGINSWITH %@) || (head BEGINSWITH %@)", newTerm, searchTerm];
    
    [fetchRequest setPredicate:pred];
    [fetchRequest setFetchLimit:50];

    NSError *error;			
    
    self.fetchedResults = [context executeFetchRequest:fetchRequest error:&error];        
    [fetchRequest release];    
    
    if (!fetchedResults) {
        NSLog(@"Error: %@", [error localizedDescription]);
    } 
    
    isFound = [fetchedResults count] > 0 ? YES : NO;
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentSizeForViewInPopover = CGSizeMake(660.0, 600.0);

    isBlank = YES;
    isFound = NO;
    selectedIndex = -1;
    
    searchBar.placeholder = @"ป้อนคำภาษาบาลี";
    
    if (![self checkDatabase]) {
        
        UIAlertView *dbAlert = [[[UIAlertView alloc] 
                                 initWithTitle:@"โปรดรอซักครู่\nโปรแกรมกำลังสร้างฐานข้อมูลพจนานุกรม" 
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
            E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];			
            NSManagedObjectContext *context = [appDelegate managedObjectContext];
            
            [[Utils readPlist:@"PaliThai"] 
             enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                 PaliThai *lex = [NSEntityDescription 
                                  insertNewObjectForEntityForName:@"PaliThai" 
                                  inManagedObjectContext:context];
                 lex.head = key;
                 lex.translation = obj;
            }];
            NSError *error;
            if (![context save:&error]) {
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }            
            dispatch_async(dispatch_get_main_queue(), ^{
                [dbAlert dismissWithClickedButtonIndex:0 animated:YES];
            });            
        });                     
    }     
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.searchBar = nil;
    self.tableView = nil;
    self.fetchedResults = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark -
#pragma mark Table View Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isBlank) {
        return 0;
    }
    return isFound ? [fetchedResults count] : 1;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    
    static NSString *sectionsTableIdentifier = @"sectionsTableIdentifier";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier: sectionsTableIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                 reuseIdentifier: sectionsTableIdentifier] autorelease];
    }

    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    if(selectedIndex == indexPath.row)
    {
        CGFloat translationHeight = [self getTranslationHeightForIndex:indexPath.row];        
        cell.contentView.backgroundColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.7 alpha:0.15];
        cell.detailTextLabel.frame = CGRectMake(cell.detailTextLabel.frame.origin.x, 
                                                 cell.detailTextLabel.frame.origin.y, 
                                                 cell.detailTextLabel.frame.size.width, 
                                                 translationHeight);                
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.detailTextLabel.numberOfLines = 0;

    }
    else {        
        //Otherwise just return the minimum height for the label.
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.detailTextLabel.frame = CGRectMake(cell.detailTextLabel.frame.origin.x, 
                                                 cell.detailTextLabel.frame.origin.y, 
                                                 cell.detailTextLabel.frame.size.width, 
                                                 CELL_MIN_HEIGHT);
        cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
        cell.detailTextLabel.numberOfLines = 1;

    }    
    
    
    if (isFound) {        
        PaliThai *item =  [fetchedResults objectAtIndex:row];            
        cell.textLabel.text = item.head;
        cell.detailTextLabel.text = item.translation;        
        cell.textLabel.font = [UIFont fontWithName:HEAD_FONT size:HEAD_SIZE];
        cell.detailTextLabel.font = [UIFont fontWithName:TRANSLATION_FONT size:TRANSLATION_SIZE];;
    } else {
        cell.textLabel.text = searchBar.text;
        cell.detailTextLabel.text = @"ไม่พบคำนี้ในพจนานุกรม";
        cell.textLabel.font = [UIFont fontWithName:HEAD_FONT size:HEAD_SIZE];
        cell.detailTextLabel.font = [UIFont fontWithName:TRANSLATION_FONT size:TRANSLATION_SIZE];;        
    } 
    
    return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods
- (NSIndexPath *) tableView:(UITableView *)aTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //We only don't want to allow selection on any cells which cannot be expanded
    if([self getCellHeightForIndex:indexPath.row] > CELL_MIN_HEIGHT)
    {
        return indexPath;
    }
    else {
        return nil;
    }
}

-(void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //The user is selecting the cell which is currently expanded
    //we want to minimize it back
    if(selectedIndex == indexPath.row)
    {
        selectedIndex = -1;
        [aTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                          withRowAnimation:UITableViewRowAnimationFade];
        
        return;
    }
    
    //First we check if a cell is already expanded.
    //If it is we want to minimize make sure it is reloaded to minimize it back
    if(selectedIndex >= 0)
    {
        NSIndexPath *previousPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
        selectedIndex = indexPath.row;
        [aTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:previousPath] 
                          withRowAnimation:UITableViewRowAnimationFade];        
    }
    
    //Finally set the selected index to the new selection and reload it to expand
    selectedIndex = indexPath.row;
    [aTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                      withRowAnimation:UITableViewRowAnimationFade];    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //If this is the selected index we need to return the height of the cell
    //in relation to the label height otherwise we just return the minimum label height with padding
    if(selectedIndex == indexPath.row)
    {
        return [self getCellHeightForIndex:indexPath.row] + CELL_PADDING * 2;
    }
    else {
        return CELL_MIN_HEIGHT + CELL_PADDING * 2;
    }    
}

#pragma mark - 
#pragma mark Search Bar Delegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar {
    NSString *searchTerm = [aSearchBar text];
    [self handleSearchForTerm:searchTerm];
    [tableView reloadData];
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)aSearchBar textDidChange:(NSString *)searchTerm {
    [self handleSearchForTerm:searchTerm];
    [tableView reloadData];
}

@end
