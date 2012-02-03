//
//  SearchViewController.h
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@class History;

#define kThaiScope 0
#define kPaliScope 1

@class ReadViewController;


@interface SearchViewController : UIViewController 
<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MBProgressHUDDelegate> {
	UITableView *table;
	UISearchBar *search;
	NSMutableDictionary *results;
    NSMutableArray *clickedItems;
	NSMutableArray *categories;
	NSString *keywords;
    ReadViewController *readViewController;
	NSInteger scope;
	BOOL isSearching;
    BOOL isNewKeywords;
    BOOL notFound;
}

@property(nonatomic, retain) ReadViewController *readViewController;
@property(nonatomic, retain) IBOutlet UITableView *table;
@property(nonatomic, retain) IBOutlet UISearchBar *search;
@property(nonatomic, retain) NSMutableDictionary *results;
@property(nonatomic, retain) NSMutableArray *clickedItems;
@property(nonatomic, retain) NSMutableArray *categories;
@property(nonatomic, retain) NSString *keywords;
@property(assign) NSInteger scope;

- (void)resetSearch;
- (void)handleSearchForTerm:(NSString *)searchTerm;
- (void)loadHistory:(History *)history;
- (IBAction)toggleLanguage:(id)sender;
- (IBAction)showSearchHistory:(id)sender;

@end
