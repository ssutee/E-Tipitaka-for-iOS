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
@property(nonatomic, strong) NSString *language;
@property(nonatomic, strong) NSMutableArray *historyData;
@property(nonatomic, strong) NSMutableArray *loadedData;
@property(nonatomic, strong) NSMutableDictionary *detailTable;
@property(nonatomic, strong) NSArray *stageImages;
@property(nonatomic, strong) IBOutlet UISegmentedControl *sortingControl;
@property(nonatomic, strong) NSManagedObjectContext *backgroundManagedObjectContext;

-(IBAction)toggleEdit:(id)sender;
-(IBAction)starTapped:(id)sender;

@end

