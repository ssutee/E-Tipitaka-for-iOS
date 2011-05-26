//
//  BookmarkListViewController.h
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kVinaiKey @"พระวินัยปิฎก"
#define kSuttanKey @"พระสุตตันตปิฎก"
#define kAbhidhumKey @"พระอภิธรรมปิฎก"

@class ReadViewController;

@interface BookmarkListViewController : UITableViewController <UITabBarControllerDelegate> {
	NSMutableDictionary *bookmarkData;
	NSString *language;
    ReadViewController *readViewController;
}

@property(nonatomic, retain) NSMutableDictionary *bookmarkData;
@property(nonatomic, retain) NSString *language;
@property(nonatomic, retain) ReadViewController *readViewController;


-(IBAction)toggleEdit:(id)sender;
-(IBAction)toggleLanguage:(id)sender;
-(IBAction)editBookmark:(id)sender;

@end


@interface EditBookmarkButton : UIButton {
    NSInteger section;
    NSInteger row;
}

@property(assign) NSInteger section;
@property(assign) NSInteger row;

@end