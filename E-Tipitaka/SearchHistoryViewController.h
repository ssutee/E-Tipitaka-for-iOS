//
//  SearchHistoryViewController.h
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SearchHistoryViewController : UITableViewController {
    NSString *language;
    NSMutableArray *historyData;
}
@property(nonatomic, retain) NSString *language;
@property(nonatomic, retain) NSMutableArray *historyData;

-(void) reloadData;
-(IBAction)toggleEdit:(id)sender;

@end
