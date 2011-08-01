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

typedef enum {
    BY_TEXT, BY_CREATED, BY_VOLUME
} sortingType;

@interface BookmarkListViewController : UIViewController 
<UITableViewDataSource, UITableViewDelegate,UITabBarControllerDelegate> {
	NSMutableDictionary *bookmarkData;
	NSString *language;
    ReadViewController *readViewController;
    UITableView *tableView;
    sortingType sorting;
    UISegmentedControl *sortingControl;
    BOOL willReload;
}

@property(nonatomic, retain) NSMutableDictionary *bookmarkData;
@property(nonatomic, retain) NSString *language;
@property(nonatomic, retain) ReadViewController *readViewController;
@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UISegmentedControl *sortingControl;


-(IBAction)toggleEdit:(id)sender;
-(IBAction)toggleLanguage:(id)sender;
-(IBAction)editBookmark:(id)sender;
-(IBAction)sortList:(id)sender;

@end


@interface EditBookmarkButton : UIButton {
    NSInteger section;
    NSInteger row;
}

@property(assign) NSInteger section;
@property(assign) NSInteger row;

@end