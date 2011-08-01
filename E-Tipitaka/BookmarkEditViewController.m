//
//  BookmarkEditViewController.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BookmarkEditViewController.h"
#import "Bookmark.h"
#import "Item.h"
#import "Content.h"
#import "Utils.h"
#import "E_TipitakaAppDelegate.h"

@implementation BookmarkEditViewController

@synthesize bookmark;
@synthesize label1;
@synthesize label2;
@synthesize textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [bookmark release];
    [label1 release];
    [label2 release];
    [textView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(IBAction) saveButtonClicked:(id) sender {
	E_TipitakaAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];	
	
	NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    self.bookmark.text = self.textView.text;
    
	NSError *error;    
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.contentSizeForViewInPopover = CGSizeMake(350.0, 500.0);
 
	UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"บันทึก" 
                                   style:UIBarButtonItemStyleBordered
                                   target:self 
                                   action:@selector(saveButtonClicked:)];
	self.navigationItem.rightBarButtonItem = saveButton;
	[saveButton release];    
    
    NSString *text = [[NSString alloc] 
                      initWithFormat:@"เล่มที่ %@ หน้าที่ %@ ข้อที่ %@", 
                      self.bookmark.item.content.volume,
                      self.bookmark.item.content.page,
                      self.bookmark.item.number];
    self.label2.text = [Utils arabic2thai:text];
    [text release];

    if ([self.bookmark.item.content.lang isEqualToString:@"thai"]) {
        self.label1.text = @"พระไตรปิฎก บาลีสยามรัฐ (ภาษาไทย)";
    } else {
        self.label1.text = @"พระไตรปิฎก บาลีสยามรัฐ (ภาษาบาลี)";
    }
    
    self.textView.text = self.bookmark.text;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.bookmark = nil;
    self.label1 = nil;
    self.label2 = nil;
    self.textView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
