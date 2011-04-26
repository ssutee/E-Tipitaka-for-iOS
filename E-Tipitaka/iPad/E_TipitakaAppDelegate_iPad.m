//
//  E_TipitakaAppDelegate_iPad.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "E_TipitakaAppDelegate_iPad.h"

@implementation E_TipitakaAppDelegate_iPad

@synthesize splitViewController=_splitViewController;
@synthesize readViewController=_readViewController;
@synthesize rootViewController=_rootViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // Add the split view controller's view to the window and display.
    [super createEditableCopyOfDatabaseIfNeeded];
    self.window.rootViewController = self.splitViewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc
{
	[super dealloc];
    
    [_splitViewController release];
    [_rootViewController release];
    [_readViewController release];
}

@end
