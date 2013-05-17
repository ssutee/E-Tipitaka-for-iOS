//
//  SearchViewController.h
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "BaseReadViewController.h"

@class History;

#define kThaiScope 0
#define kPaliScope 1

@class ReadViewController;


@interface SearchViewController : UIViewController 
<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MBProgressHUDDelegate, BaseReadViewControllerDelegate> {
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

@property(nonatomic, strong) ReadViewController *readViewController;
@property(nonatomic, strong) IBOutlet UITableView *table;
@property(nonatomic, strong) IBOutlet UISearchBar *search;
@property(nonatomic, strong) NSMutableDictionary *results;
@property(nonatomic, strong) NSMutableArray *clickedItems;
@property(nonatomic, strong) NSMutableArray *readItems;
@property(nonatomic, strong) NSMutableArray *categories;
@property(nonatomic, strong) NSString *keywords;
@property(assign) NSInteger scope;

- (void)resetSearch;
- (void)handleSearchForTerm:(NSString *)searchTerm;
- (void)loadHistory:(History *)history;
- (IBAction)toggleLanguage:(id)sender;
- (IBAction)showSearchHistory:(id)sender;

@end
