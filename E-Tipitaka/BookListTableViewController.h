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

@property(nonatomic, retain) NSDictionary *namesDictionary;
@property(nonatomic, retain) NSArray *categories;
@property (nonatomic, retain) IBOutlet ReadViewController *readViewController;

@end
