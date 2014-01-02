//
//  ImportTool.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 2/1/14.
//
//

#import "ImportTool.h"
#import "E_TipitakaAppDelegate.h"
#import "Item+Helper.h"
#import "Bookmark+Helper.h"
#import "History+Helper.h"
#import "Content+Helper.h"
#import "ZipFile.h"
#import "ZipReadStream.h"
#import <JSONKit/JSONKit.h>
#import <SVProgressHUD/SVProgressHUD.h>

@implementation ImportTool

+ (BOOL)importData:(id)jsonObject bookmarksCount:(NSInteger *)bookmarksCount historiesCount:(NSInteger *)historiesCount inContext:(NSManagedObjectContext *)context
{
    if ([jsonObject objectForKey:@"version"]) {
        return NO;
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"th_TH"]];
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    
    NSArray *bookmarks = [jsonObject objectForKey:@"bookmarks"];
    int bookmarkPosition = 0;
    *bookmarksCount = bookmarks.count;
    for (NSDictionary *bookmark in bookmarks) {
        Item *item = [Item itemWithSection:[bookmark objectForKey:@"item_section"] number:[bookmark objectForKey:@"item_number"] volume:[bookmark objectForKey:@"volume"] lang:[bookmark objectForKey:@"lang"] inManagedObjectContext:context];
        if (item) {
            Bookmark *newBookmark = [Bookmark bookmarkWithItem:item text:[bookmark objectForKey:@"text"] inManagedObjectContext:context];
            newBookmark.text = [bookmark objectForKey:@"text"];
            newBookmark.created = [dateFormatter dateFromString:[bookmark objectForKey:@"created"]];
        }
        [context save:nil];
        bookmarkPosition += 1;
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showProgress:1.0f*bookmarkPosition/(*bookmarksCount) status:@"รายการจดจำ" maskType:SVProgressHUDMaskTypeGradient];
        });
    }
    
    NSArray *histories = [jsonObject objectForKey:@"histories"];
    int historyPosition = 0;
    *historiesCount = histories.count;
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
        [context save:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showProgress:1.0f*historyPosition/(*historiesCount) status:@"ประวัติการค้นหา" maskType:SVProgressHUDMaskTypeGradient];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus:@"Done"];
    });
    return YES;
}

+ (BOOL)importDataFromFile:(NSString *)filePath bookmarksCount:(NSInteger *)bookmarksCount historiesCount:(NSInteger *)historiesCount inContext:(NSManagedObjectContext *)context
{
    id data = nil;
    if ([[filePath pathExtension] isEqualToString:@"etz"]) {
        ZipFile *zipFile = [[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeUnzip];
        [zipFile goToFirstFileInZip];
        ZipReadStream *readStream = [zipFile readCurrentFileInZip];
        NSString *text = @"";
        NSMutableData *buffer = [[NSMutableData alloc] initWithLength:256];
        do {
            [buffer setLength:256];
            int bytesRead = [readStream readDataWithBuffer:buffer];
            if (!bytesRead) { break; }
            [buffer setLength:bytesRead];
            text = [text stringByAppendingString:[[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding]];
        } while (YES);
        data = [text objectFromJSONString];
    } else {
        data = [[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] objectFromJSONString];
    }
    return [ImportTool importData:data bookmarksCount:bookmarksCount historiesCount:historiesCount inContext:context];
}

@end
