//
//  E_TipitakaAppDelegate_iPhone.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "E_TipitakaAppDelegate.h"
#import "TapDetectingWindow.h"

@interface E_TipitakaAppDelegate_iPhone : E_TipitakaAppDelegate {
	UITabBarController *rootController;     
}

@property (nonatomic, strong) IBOutlet UITabBarController *rootController;

@end
