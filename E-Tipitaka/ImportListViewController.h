//
//  ImportListViewController.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 11/24/55 BE.
//
//

#import <UIKit/UIKit.h>

@class ImportListViewController;

@protocol ImportListViewControllerDelegate <NSObject>

@optional
-(void)impotListViewControllerDidFinish:(ImportListViewController *) controller;

@end

@interface ImportListViewController : UITableViewController

@property (nonatomic, assign) id<ImportListViewControllerDelegate> delegate;
@property (nonatomic, retain) UIBarButtonItem* refreshButtonItem;

@end
