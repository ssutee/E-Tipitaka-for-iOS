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

@interface ToolsViewController ()

@end

@implementation ToolsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"เครื่องมือ";
    
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        ImportListViewController *controller = [[ImportListViewController alloc] initWithNibName:@"ImportListViewController" bundle:nil];
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
    } else if (indexPath.section == 0 && indexPath.row == 1) {
        [ExportTool exportData];
    }
}

@end
