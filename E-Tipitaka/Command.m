//
//  Command.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 9/10/54 BE.
//  Copyright 2554 __MyCompanyName__. All rights reserved.
//

#import "Command.h"
#import "ReadViewController.h"
#import "ContentInfo.h"
#import "QueryHelper.h"
#import "Utils.h"
#import "Item.h"
#import "Content.h"

@implementation Command

- (void) execute
{
    [NSException raise:NSInternalInconsistencyException 
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}
@end

@implementation ReadViewControllerCommand

- (id)initWithController:(ReadViewController *)controller
{
    self = [super init];
    if (self) {
        readViewController = controller;
    }
    return self;    
}

@end


@implementation GotoPageCommand

- (void) execute
{
	ContentInfo *info = [[ContentInfo alloc] init];
    info.language = [readViewController getCurrentLanguage];
    info.volume = [readViewController getCurrentVolume];
    [info setType:LANGUAGE|VOLUME];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ใส่หน้าที่ต้องการ" message:[Utils arabic2thai:[NSString stringWithFormat:@"ตั้งแต่หน้าที่ ๑ ถึง %d", [QueryHelper getMaximumPageValue:info]]] delegate:readViewController cancelButtonTitle:@"ยกเลิก" otherButtonTitles:@"ตกลง", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeNumberPad;
	alert.tag = kGotoPageAlert;
    [alert show];
}

@end


@implementation GotoItemCommand

- (void) execute
{
    ContentInfo *info = [[ContentInfo alloc] init];
    info.language = [readViewController getCurrentLanguage];
    info.volume = [readViewController getCurrentVolume];
    [info setType:LANGUAGE|VOLUME];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ใส่ข้อที่ต้องการ" message:[Utils arabic2thai:[NSString stringWithFormat:@"ตั้งแต่ข้อที่ ๑ ถึง %d", [QueryHelper getMaximumItemValue:info]]] delegate:readViewController cancelButtonTitle:@"ยกเลิก" otherButtonTitles:@"ตกลง", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeNumberPad;
    alert.tag = kGotoItemAlert;
    [alert show];
}

@end

@implementation GotoMoreItemsCommand

@synthesize items;
@synthesize itemNumber;

- (void) execute
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.tag = kSelectItemActionSheet;
    actionSheet.title = [Utils arabic2thai: 
                         [NSString stringWithFormat:@"ข้อที่ %@ พบมากกว่าหนึ่งหน้า", itemNumber]];
    actionSheet.delegate = readViewController;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    for (Item *item in items) {
        [actionSheet addButtonWithTitle:
         [Utils arabic2thai:[NSString stringWithFormat:@"หน้าที่ %@", item.content.page]]];
    }                                    
    [actionSheet addButtonWithTitle:@"ยกเลิก"];
    [actionSheet setCancelButtonIndex:[items count]];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [actionSheet showFromToolbar:readViewController.toolbar];
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [actionSheet showFromBarButtonItem:readViewController.gotoButton 
                                  animated:YES];
        readViewController.itemOptionsActionSheet = actionSheet;
    }
}

@end
