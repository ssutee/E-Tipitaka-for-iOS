//
//  QueryHelper.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 9/10/54 BE.
//  Copyright 2554 __MyCompanyName__. All rights reserved.
//

#import "QueryHelper.h"
#import "E_TipitakaAppDelegate.h"
#import "ContentInfo.h"
#import "Content.h"
#import "Item.h"
#import "Utils.h"

@implementation QueryHelper

+(NSArray *) getContents:(ContentInfo *)info
{
	E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];	
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"Content" 
								   inManagedObjectContext:context];	
	[fetchRequest setEntity:entity];
		
	[fetchRequest setPredicate:[info predicate]];
	
	NSError *error = nil;    
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	if (error) {
        NSLog(@"%@", [error description]);
    }
	
	return fetchedObjects;
}

+(NSArray *) getItems:(ContentInfo *)info {
	E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];	
	
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription 
								   entityForName:@"Item" 
								   inManagedObjectContext:context];	
	[fetchRequest setEntity:entity];
	
	[fetchRequest setPredicate:[info predicate]];
	
    if ([info getType] == (LANGUAGE | VOLUME | BEGIN) ||  [info getType] == (LANGUAGE | VOLUME | PAGE | BEGIN)) {
        NSSortDescriptor *sortByNumber = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortByNumber]];
        
    }
        
	NSError *error;			
	NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
	
    
	return fetchedObjects;
}

+(NSArray *) getItemsFromContent:(Content *)content {
	NSMutableArray *array = [[NSMutableArray alloc] init];
	
	for(Item *item in content.items) {
		if ([item.begin boolValue]) {
			[array addObject:item];
		}
	}
    
	if ([array count] == 0) {
		for (Item *item in content.items) {
			[array addObject:item];
		}
	}
	
	NSSortDescriptor *sortDescriptor;
	sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
	NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
	NSArray *sortedItems = [array sortedArrayUsingDescriptors:sortDescriptors];
	
	
	return sortedItems;
	
}

+(NSInteger) getMaximumItemValue:(ContentInfo *)info {
    NSDictionary *itemsDictionary = [Utils readItems];
    NSInteger n=0;
    for (NSNumber *i in [[itemsDictionary valueForKey:info.language] objectAtIndex:[info.volume intValue]-1]) {
        if ([i intValue] > n) {
            n = [i intValue];
        }
    }
	return n;
}

+(NSInteger) getMaximumPageValue:(ContentInfo *)info {
    NSDictionary *pagesDictionary = [Utils readPages];
    return [[[pagesDictionary valueForKey:info.language] objectAtIndex:[info.volume intValue]-1] intValue];
}


@end
