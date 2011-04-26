//
//  E_TipitakaAppDelegate.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 4/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapDetectingWindow.h"

@interface E_TipitakaAppDelegate : NSObject <UIApplicationDelegate> {
    TapDetectingWindow *window;
}

@property (nonatomic, retain) IBOutlet TapDetectingWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)createEditableCopyOfDatabaseIfNeeded;

@end
