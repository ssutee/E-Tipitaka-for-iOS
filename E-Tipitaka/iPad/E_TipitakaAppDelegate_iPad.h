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
    UINavigationController *rootController;
}

@property (nonatomic, retain) IBOutlet UINavigationController *rootController;

@end

