//
//  BookListTableViewController.h
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReadViewController;

@interface BookListTableViewController : UITableViewController {
    NSDictionary *namesDictionary;
	NSArray *categories;
    ReadViewController *readViwController;
}

@property(nonatomic, strong) NSDictionary *namesDictionary;
@property(nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) IBOutlet ReadViewController *readViewController;

@end
