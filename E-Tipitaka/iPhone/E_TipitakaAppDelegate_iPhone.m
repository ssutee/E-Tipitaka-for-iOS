//
//  E_TipitakaAppDelegate_iPhone.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "E_TipitakaAppDelegate_iPhone.h"

@implementation E_TipitakaAppDelegate_iPhone

@synthesize rootController;

- (void)dealloc
{
	[super dealloc];
    [rootController release];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    // hide status bar
    [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    // create database for the first time
    [super createEditableCopyOfDatabaseIfNeeded];
    

    [self.window addSubview:rootController.view];    

    
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
