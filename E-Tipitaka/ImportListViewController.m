//
//  ImportListViewController.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 11/24/55 BE.
//
//

#import "E_TipitakaAppDelegate.h"
#import "ImportListViewController.h"
#import "JSONKit.h"
#import "Bookmark+Helper.h"
#import "Item+Helper.h"
#import "History+Helper.h"
#import "Content+Helper.h"

@interface ImportListViewController ()

@property (nonatomic, retain) NSMutableArray *jsonFiles;

@end

@implementation ImportListViewController

@synthesize jsonFiles = _jsonFiles;
@synthesize delegate = _delegate;
@synthesize refreshButtonItem = _refreshButtonItem;

- (NSMutableArray *)jsonFiles
{
    if (!_jsonFiles) {
        _jsonFiles = [[NSMutableArray alloc] init];
    }
    return _jsonFiles;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"นำข้อมูลเข้า";
    self.refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    self.contentSizeForViewInPopover = CGSizeMake(320, 400);
    [self loadFiles];
    self.navigationItem.rightBarButtonItem = self.refreshButtonItem;
}

- (void)loadFiles
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    for (NSString* path in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil]) {
        if ([path.pathExtension isEqualToString:@"json"]) {
            [self.jsonFiles addObject:path];
        }
    }
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCompare:)];
    [self.jsonFiles sortUsingDescriptors:@[sortDescriptor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)refresh:(id)sender
{
    [self.jsonFiles removeAllObjects];
    [self loadFiles];
    [self.tableView reloadData];
}

- (void)deleteFileAtIndexPath:(NSIndexPath *)indexPath
{    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:[self.jsonFiles objectAtIndex:indexPath.row]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:path error:nil];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.jsonFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"JSON File Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSString *path = [self.jsonFiles objectAtIndex:indexPath.row];
    
    cell.textLabel.text = path.lastPathComponent;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteFileAtIndexPath:indexPath];
        [self.jsonFiles removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"th_TH"] autorelease]];
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    
    NSString *path = [self.jsonFiles objectAtIndex:indexPath.row];    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *jsonString = [NSString stringWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:path] encoding:NSUTF8StringEncoding error:nil];

    id jsonObject = [jsonString objectFromJSONString];

    NSArray *bookmarks = [jsonObject objectForKey:@"bookmarks"];
    for (NSDictionary *bookmark in bookmarks) {
        Item *item = [Item itemWithSection:[bookmark objectForKey:@"item_section"] number:[bookmark objectForKey:@"item_number"] volume:[bookmark objectForKey:@"volume"] lang:[bookmark objectForKey:@"lang"] inManagedObjectContext:context];
        if (item) {
            Bookmark *newBookmark = [Bookmark bookmarkWithItem:item inManagedObjectContext:context];
            newBookmark.text = [bookmark objectForKey:@"text"];
            newBookmark.created = [dateFormatter dateFromString:[bookmark objectForKey:@"created"]];
        }
    }
    
    NSArray *histories = [jsonObject objectForKey:@"histories"];
    for (NSDictionary *history in histories) {
        NSString *lang = [history objectForKey:@"lang"];
        History *newHistory = [History historyWithKeywords:[history objectForKey:@"keywords"] lang:lang inManagedObjectContext:context];
        newHistory.detail = [history objectForKey:@"detail"];
        newHistory.star = [history objectForKey:@"star"];
        newHistory.created = [dateFormatter dateFromString:[history objectForKey:@"created"]];
        newHistory.state = [history objectForKey:@"state"];
        newHistory.read = [NSKeyedArchiver archivedDataWithRootObject:[history objectForKey:@"read"]];
        newHistory.selected = [NSKeyedArchiver archivedDataWithRootObject:[history objectForKey:@"selected"]];
        for (NSString *encodedContent in [history objectForKey:@"contents"]) {
            NSArray *tokens = [encodedContent componentsSeparatedByString:@":"];
            NSNumber *volume = [NSNumber numberWithInt:[[tokens objectAtIndex:0] intValue]];
            NSNumber *page = [NSNumber numberWithInt:[[tokens objectAtIndex:1] intValue]];
            Content *content = [Content getContentWithLang:lang volume:volume page:page inManagedObjectContext:context];
            if (content && ![newHistory.contents containsObject:content]) {
                [newHistory addContentsObject:content];
            }
        }
    }

    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"%@", error.localizedDescription);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"พบข้อผิดพลาด" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alertView show];
        [alertView release];

    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"นำข้อมูลเข้าสำเร็จ" message:[NSString stringWithFormat:@"การจดจำ %d อัน\nประวัติการค้นหา %d อัน", bookmarks.count, histories.count] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
    }
    
    if ([self.delegate respondsToSelector:@selector(impotListViewControllerDidFinish:)]) {
        [self.delegate impotListViewControllerDidFinish:self];
    }
}

- (void)viewDidUnload
{
    self.refreshButtonItem = nil;
    [super viewDidUnload];
}

- (void)dealloc
{
    [_jsonFiles release];
    [_refreshButtonItem release];
    [super dealloc];
}

@end
