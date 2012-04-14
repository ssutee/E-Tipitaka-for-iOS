//
//  SearchHistoryViewController.h
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"

typedef enum {
    BY_TEXT, BY_CREATED, BY_PRIORITY
} sortingType;

@interface SearchHistoryViewController : CoreDataTableViewController
<UITableViewDataSource, UITableViewDelegate>{
    NSString *language;
    NSMutableArray *historyData;
    NSMutableArray *loadedData;
    NSMutableDictionary *detailTable;
    NSArray *stageImages;
    BOOL loading;
    BOOL willReload;
    UITableView *tableView;
    UISegmentedControl *sortingControl;
    sortingType sorting;
}
@property(nonatomic, retain) NSString *language;
@property(nonatomic, retain) NSMutableArray *historyData;
@property(nonatomic, retain) NSMutableArray *loadedData;
@property(nonatomic, retain) NSMutableDictionary *detailTable;
@property(nonatomic, retain) NSArray *stageImages;
@property(nonatomic, retain) IBOutlet UISegmentedControl *sortingControl;
@property(nonatomic, retain) NSManagedObjectContext *backgroundManagedObjectContext;

-(IBAction)toggleEdit:(id)sender;
-(IBAction)starTapped:(id)sender;

@end

