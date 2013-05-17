//
//  ExportTool.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 11/25/55 BE.
//
//

#import "ExportTool.h"
#import "E_TipitakaAppDelegate.h"
#import "Bookmark+Helper.h"
#import "Item+Helper.h"
#import "Content+Helper.h"
#import "History+Helper.h"
#import "JSONKit.h"

@implementation ExportTool



+ (NSMutableArray *) exportBookmark {
    E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription
								   entityForName:@"Bookmark"
								   inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSError *error;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"th_TH"]];
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    
    NSMutableArray *bookmarkData = [[NSMutableArray alloc] initWithCapacity:fetchedObjects.count];
    NSUInteger position = 0;
    for(Bookmark *bookmark in fetchedObjects) {
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:[dateFormatter stringFromDate:bookmark.created ? bookmark.created : [NSDate date]], @"created", bookmark.text, @"text", bookmark.item.number, @"item_number", bookmark.item.section, @"item_section", bookmark.item.content.lang, @"lang", bookmark.item.content.volume, @"volume", nil];
        [bookmarkData addObject:data];
        position += 1;
        NSLog(@"%d", position);
    }

    return bookmarkData;
}

+ (NSMutableArray *) exportHistory {
    E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription
								   entityForName:@"History"
								   inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	NSError *error;
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"th_TH"]];
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    
    NSMutableArray *historyData = [[NSMutableArray alloc] initWithCapacity:fetchedObjects.count];
    NSUInteger position = 0;
    for (History *history in fetchedObjects) {
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        if (history.detail) {
            [data setObject:history.detail forKey:@"detail"];
        }
        if (history.star) {
            [data setObject:history.star forKey:@"star"];
        }
        [data setObject:history.lang forKey:@"lang"];
        [data setObject:history.keywords forKey:@"keywords"];
        
        [data setObject:[dateFormatter stringFromDate:history.created ? history.created : [NSDate date]] forKey:@"created"];
        if (history.state) {
            [data setObject:history.state forKey:@"state"];
        }

        NSArray *clickedItems = [NSArray array];
        if (history.selected && [NSKeyedUnarchiver unarchiveObjectWithData:history.selected]) {
            clickedItems = [NSKeyedUnarchiver unarchiveObjectWithData:history.selected];
        }
        [data setObject:clickedItems forKey:@"selected"];
        
        NSArray *readItems = [NSArray array];
        if (history.read && [NSKeyedUnarchiver unarchiveObjectWithData:history.read]) {
            readItems = [NSKeyedUnarchiver unarchiveObjectWithData:history.read];
        }
        [data setObject:readItems forKey:@"read"];
        NSMutableArray *contentIds = [[NSMutableArray alloc] initWithCapacity:history.contents.count];
        for (Content *content in history.contents) {
            [contentIds addObject:[NSString stringWithFormat:@"%@:%@", content.volume, content.page]];
        }
        [data setObject:contentIds forKey:@"contents"];

        [historyData addObject:data];
        position += 1;
        NSLog(@"%d", position);
    }
    
    return historyData;
}

+ (void)exportData {
    NSArray *bookmarks = [self exportBookmark];
    NSArray *histories = [self exportHistory];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:bookmarks, @"bookmarks", histories, @"histories", nil];
    NSString *json = [data JSONStringWithOptions:JKSerializeOptionEscapeUnicode error:nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"th_TH"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH.mm.ss"];
    
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.json", documentsDirectory, [dateFormatter stringFromDate:[NSDate date]]];
    [json writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[filePath lastPathComponent] message:@"นำข้อมูลออกสำเร็จ\nข้อมูลอยู่ที่ File Sharing ใน iTunes" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alertView show];
    });
}

@end
