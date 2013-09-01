//
//  SearchHistoryViewController.h
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataViewController.h"

typedef enum {
    BY_TEXT, BY_CREATED, BY_PRIORITY
} sortingType;

@interface SearchHistoryViewController : CoreDataViewController
<UITableViewDataSource, UITableViewDelegate>{
    NSString *language;
    NSMutableArray *historyData;
    NSMutableArray *loadedData;
    NSMutableDictionary *detailTable;
    NSArray *stageImages;
    BOOL loading;
    BOOL willReload;
    UISegmentedControl *sortingControl;
    sortingType sorting;
}

@property(nonatomic, strong) NSString *language;
@property(nonatomic, strong) NSMutableArray *historyData;
@property(nonatomic, strong) NSMutableArray *loadedData;
@property(nonatomic, strong) NSMutableDictionary *detailTable;
@property(nonatomic, strong) NSArray *stageImages;
@property(nonatomic, strong) IBOutlet UISegmentedControl *sortingControl;
@property(nonatomic, strong) IBOutlet UISegmentedControl *orderingControl;
@property(nonatomic, strong) NSManagedObjectContext *backgroundManagedObjectContext;

-(IBAction)toggleEdit:(id)sender;
-(IBAction)starTapped:(id)sender;

@end

