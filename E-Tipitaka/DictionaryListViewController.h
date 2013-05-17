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

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *fetchedResults;

- (BOOL) checkDatabase;
- (void)handleSearchForTerm:(NSString *)searchTerm;

@end
