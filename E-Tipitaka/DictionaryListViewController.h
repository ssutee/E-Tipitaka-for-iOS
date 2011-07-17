//
//  DictionaryListViewController.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 7/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DictionaryListViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    UISearchBar *searchBar;
    UITableView *tableView;
    NSArray *fetchedResults;
    BOOL isFound;
    BOOL isBlank;
    NSInteger selectedIndex;
}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSArray *fetchedResults;

- (BOOL) checkDatabase;
- (void)handleSearchForTerm:(NSString *)searchTerm;

@end
