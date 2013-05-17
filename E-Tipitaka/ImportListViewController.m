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
#import "MBProgressHUD.h"

@interface ImportListViewController ()<MBProgressHUDDelegate>

@property (nonatomic, strong) NSMutableArray *jsonFiles;
@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation ImportListViewController

@synthesize jsonFiles = _jsonFiles;
@synthesize delegate = _delegate;
@synthesize refreshButtonItem = _refreshButtonItem;
@synthesize HUD = _HUD;

- (MBProgressHUD *)HUD
{
    if (!_HUD) {
        _HUD = [[MBProgressHUD alloc] initWithWindow:self.view.window];
        _HUD.delegate = self;
        _HUD.mode = MBProgressHUDModeDeterminate;
        _HUD.progress = 0.0f;
        _HUD.dimBackground = YES;
    }
    return _HUD;
}

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

- (void)mergeChanges:(NSNotification *)notification
{
    E_TipitakaAppDelegate *application = [[UIApplication sharedApplication] delegate];
    [application.managedObjectContext performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) withObject:notification waitUntilDone:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:notification.object];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
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
    [self.view.window addSubview:self.HUD];
    self.HUD.labelText = @"กำลังนำข้อมูลเข้า";
    [self.HUD show:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
        [context setUndoManager:nil];
        [context setPersistentStoreCoordinator:[appDelegate persistentStoreCoordinator]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mergeChanges:) name:NSManagedObjectContextDidSaveNotification object:context];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"th_TH"]];
        [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
        
        NSString *path = [self.jsonFiles objectAtIndex:indexPath.row];
        NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *jsonString = [NSString stringWithContentsOfFile:[documentsDirectory stringByAppendingPathComponent:path] encoding:NSUTF8StringEncoding error:nil];
        
        id jsonObject = [jsonString objectFromJSONString];
        
        NSArray *bookmarks = [jsonObject objectForKey:@"bookmarks"];
        self.HUD.progress = 0.0f;
        int bookmarkPosition = 0;
        int bookmarksCount = bookmarks.count;
        for (NSDictionary *bookmark in bookmarks) {
            Item *item = [Item itemWithSection:[bookmark objectForKey:@"item_section"] number:[bookmark objectForKey:@"item_number"] volume:[bookmark objectForKey:@"volume"] lang:[bookmark objectForKey:@"lang"] inManagedObjectContext:context];
            if (item) {
                Bookmark *newBookmark = [Bookmark bookmarkWithItem:item text:[bookmark objectForKey:@"text"] inManagedObjectContext:context];
                newBookmark.text = [bookmark objectForKey:@"text"];
                newBookmark.created = [dateFormatter dateFromString:[bookmark objectForKey:@"created"]];
            }
            bookmarkPosition += 1;
            self.HUD.progress = 1.0f * bookmarkPosition/ bookmarksCount;
        }
        
        NSArray *histories = [jsonObject objectForKey:@"histories"];
        self.HUD.progress = 0.0f;
        int historyPosition = 0;
        int historiesCount = histories.count;
        for (NSDictionary *history in histories) {
            NSString *lang = [history objectForKey:@"lang"];
            History *newHistory = [History historyWithKeywords:[history objectForKey:@"keywords"] lang:lang inManagedObjectContext:context];
            newHistory.detail = [history objectForKey:@"detail"];
            newHistory.star = [history objectForKey:@"star"];
            newHistory.created = [dateFormatter dateFromString:[history objectForKey:@"created"]];
            newHistory.state = [history objectForKey:@"state"];
            newHistory.read = [NSKeyedArchiver archivedDataWithRootObject:[history objectForKey:@"read"]];
            newHistory.selected = [NSKeyedArchiver archivedDataWithRootObject:[history objectForKey:@"selected"]];
            NSMutableSet *contents = [[NSMutableSet alloc] init];
            NSLog(@"count = %d", [[history objectForKey:@"contents"] count]);
            if ([[history objectForKey:@"contents"] count] <= 500) {
                for (NSString *encodedContent in [history objectForKey:@"contents"]) {
                    NSArray *tokens = [encodedContent componentsSeparatedByString:@":"];
                    NSNumber *volume = [NSNumber numberWithInt:[[tokens objectAtIndex:0] intValue]];
                    NSNumber *page = [NSNumber numberWithInt:[[tokens objectAtIndex:1] intValue]];
                    Content *content = [Content getContentWithLang:lang volume:volume page:page inManagedObjectContext:context];
                    if (content) {
                        [contents addObject:content];
                    }
                }
                [newHistory addContents:contents];
            }
            historyPosition += 1;
            self.HUD.progress = 1.0f * historyPosition/ historiesCount;
        }
        
        [context save:nil];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.HUD hide:YES];
        });

        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"นำข้อมูลเข้าสำเร็จ" message:[NSString stringWithFormat:@"การจดจำ %d อัน\nประวัติการค้นหา %d อัน", bookmarksCount, historiesCount] delegate:nil cancelButtonTitle:@"Close" otherButtonTitles: nil];
            [alertView show];
            
            if ([self.delegate respondsToSelector:@selector(impotListViewControllerDidFinish:)]) {
                [self.delegate impotListViewControllerDidFinish:self];
            }
        });

        
    });
}

- (void)viewDidUnload
{
    self.refreshButtonItem = nil;
    [super viewDidUnload];
}


#pragma mark - MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [self.HUD removeFromSuperview];
	self.HUD = nil;
}


@end
