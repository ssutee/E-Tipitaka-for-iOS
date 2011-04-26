//
//  E_TipitakaAppDelegate_iPad.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "E_TipitakaAppDelegate.h"
#import "ReadViewController.h"
#import "BookListTableViewController.h"

@interface E_TipitakaAppDelegate_iPad : E_TipitakaAppDelegate {
    UISplitViewController *splitViewController;
}

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet ReadViewController *readViewController;
@property (nonatomic, retain) IBOutlet BookListTableViewController *rootViewController;

@end

