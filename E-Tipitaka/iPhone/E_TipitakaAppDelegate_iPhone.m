//
//  E_TipitakaAppDelegate_iPhone.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "E_TipitakaAppDelegate_iPhone.h"
#import <Socialize/Socialize.h>

@implementation E_TipitakaAppDelegate_iPhone

@synthesize rootController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
//    [self.window setRootViewController:rootController];
//    [self.window addSubview:rootController.view];
    return YES;
}

@end
