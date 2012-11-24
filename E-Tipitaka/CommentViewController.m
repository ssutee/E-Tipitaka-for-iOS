//
//  CommentViewController.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 4/28/55 BE.
//  Copyright (c) 2555 __MyCompanyName__. All rights reserved.
//

#import "CommentViewController.h"
#import "Reachability.h"

@interface CommentViewController ()<SocializeServiceDelegate>

@property (nonatomic, retain) Socialize *socialize;

@end

@implementation CommentViewController

@synthesize socialize = _socialize;

- (Socialize *)socialize
{
    if (_socialize == nil) {
        _socialize = [[Socialize alloc] initWithDelegate:self];
    }
    return _socialize;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Comments";
    [self.socialize getEntityWithId:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.socialize = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    if (netStatus == NotReachable) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Internet Connection Problem" message:@"ฟังก์ชั่นการทำงานนี้จำเป็นต้องใช้การเชื่อมต่ออินเตอร์เน็ต" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        [self.navigationController popViewControllerAnimated:YES];
    } 
}

- (void)dealloc
{
    [_socialize release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
    }
    return NO;
}

- (BOOL)shouldAutorotate {
    UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    } else {
        return orientation != UIInterfaceOrientationPortraitUpsideDown;
    }
}

-(BOOL) hidesBottomBarWhenPushed {
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
