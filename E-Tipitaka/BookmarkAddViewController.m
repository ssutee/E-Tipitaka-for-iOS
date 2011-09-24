//
//  BookmarkAddViewController.m
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookmarkAddViewController.h"
#import "E_TipitakaAppDelegate.h"
#import "Bookmark.h"
#import "Utils.h"
#import "Item.h"
#import "ReadViewController.h"

@implementation BookmarkAddViewController

@synthesize titleLabel1;
@synthesize titleLabel2;
@synthesize textView;
@synthesize selectedItem;
@synthesize popoverController;
@synthesize readViewController;

- (BOOL)shouldAutorotateToInterfaceOrientation:
(UIInterfaceOrientation)toInterfaceOrientation {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
    return NO;
}

-(BOOL) hidesBottomBarWhenPushed {
	return YES;
}

-(IBAction) backgroundClicked {
	[textView resignFirstResponder];
}

-(IBAction) cancelButtonClicked:(id) sender {
    [popoverController dismissPopoverAnimated:YES];
}

-(IBAction) saveButtonClicked:(id) sender {
	//NSLog(@"Saved");
	E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];		
	NSManagedObjectContext *context = [appDelegate managedObjectContext];	

	Bookmark *bookmark = [NSEntityDescription
						  insertNewObjectForEntityForName:@"Bookmark" inManagedObjectContext:context];
	bookmark.text = self.textView.text;
	bookmark.item = self.selectedItem;
    bookmark.created = [NSDate date];
	[self.selectedItem addBookmarksObject:bookmark];
	
	NSError *error;
	if (![context save:&error]) {
		NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
	}
	
	//[[iToast makeText:NSLocalizedString(@"ข้อมูลถูกบันทึกแล้ว", @"")] show];
    [readViewController showToast];
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [popoverController dismissPopoverAnimated:YES];
    }		
}
// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
    self.contentSizeForViewInPopover = CGSizeMake(500, 431.0);
    
	NSDictionary *dataDictionary = [Utils readData];
	
	NSString *language = [dataDictionary valueForKey:@"Language"];
	NSDictionary *dict = [dataDictionary valueForKey:language];
	
	NSNumber *page = [dict valueForKey:@"Page"];
	NSNumber *volume = [dict valueForKey:@"Volume"];
	
	NSString *newLabel;
	
	if([language isEqualToString:@"Thai"]) {
		self.titleLabel1.text = @"พระไตรปิฎก บาลีสยามรัฐ (ภาษาไทย)";
		newLabel = [[NSString alloc] initWithFormat:@"เล่มที่ %@ หน้าที่ %@ ข้อที่ %@", volume, page, self.selectedItem.number];
	} else {
		self.titleLabel1.text = @"พระไตรปิฎก บาลีสยามรัฐ (ภาษาบาลี)";		
		newLabel = [[NSString alloc] initWithFormat:@"เล่มที่ %@ หน้าที่ %@ ข้อที่ %@", volume, page, self.selectedItem.number];
	}
	
	self.titleLabel2.text = [Utils arabic2thai:newLabel];
	[newLabel release];	
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        NSString *newTitle = [NSString alloc];
        if([volume intValue] <= 8) {
            newTitle = [newTitle initWithFormat:@"%@ เล่มที่ %d", @"พระวินัยปิฎก", [volume intValue]];
        } else if([volume intValue] <= 33) {
            newTitle = [newTitle initWithFormat:@"%@ เล่มที่ %d", @"พระสุตตันตปิฎก", [volume intValue] - 8];
        } else {
            newTitle = [newTitle initWithFormat:@"%@ เล่มที่ %d", @"พระอภิธรรมปิฎก", [volume intValue] - 33];		
        }
        
        self.title = [Utils arabic2thai:newTitle];
        [newTitle release];	        
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.title = @"จดบันทึก";
    }

	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
									 initWithTitle:@"บันทึก" 
									 style:UIBarButtonItemStyleBordered
									 target:self 
									 action:@selector(saveButtonClicked:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];	
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                       initWithTitle:@"ยกเลิก" 
                                       style:UIBarButtonItemStyleBordered
                                       target:self 
                                       action:@selector(cancelButtonClicked:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        [cancelButton release];	
    }
    
	[textView becomeFirstResponder];

}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.titleLabel1 = nil;
	self.titleLabel2 = nil;
	self.textView = nil;
    self.readViewController = nil;
    self.popoverController = nil;
}


- (void)dealloc {
    [super dealloc];

	[titleLabel1 release];
	[titleLabel2 release];
	[textView release];
	[selectedItem release];
    [readViewController release];
    [popoverController release];
}


@end
