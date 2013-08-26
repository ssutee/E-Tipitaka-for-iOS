//
//  ToolsViewController.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 11/25/55 BE.
//
//

#import "ToolsViewController.h"
#import "ImportListViewController.h"
#import "ExportTool.h"
#import "MBProgressHUD.h"

@interface ToolsViewController ()<MBProgressHUDDelegate>

@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation ToolsViewController

@synthesize HUD = _HUD;
@synthesize tableView = _tableView;

- (MBProgressHUD *)HUD
{
    if (_HUD == nil) {
        _HUD = [[MBProgressHUD alloc] initWithWindow:self.view.window];
        _HUD.delegate = self;
        _HUD.mode = MBProgressHUDModeIndeterminate;
        _HUD.dimBackground = YES;
    }
    return _HUD;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"เครื่องมือ";
    self.navigationItem.title = self.title;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"จัดการข้อมูล";
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell.textLabel.text = @"นำข้อมูลเข้า";
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        cell.textLabel.text = @"นำข้อมูลออก";
    } else {
        cell.textLabel.text = @"";
    }
    
    return cell;
}

- (void)exportData
{
    self.HUD.labelText = @"กำลังนำข้อมูลออก";
    [self.view.window addSubview:self.HUD];
    [self.HUD show:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [ExportTool exportData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.HUD hide:YES];            
        });
    });
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        ImportListViewController *controller = [[ImportListViewController alloc] initWithNibName:@"ImportListViewController" bundle:nil];
        [self.navigationController pushViewController:controller animated:YES];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        [self exportData];
    }
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud
{
    [self.HUD removeFromSuperview];
    self.HUD = nil;
}

@end
