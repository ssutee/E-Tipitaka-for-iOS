//
//  Command.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 9/10/54 BE.
//  Copyright 2554 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ReadViewController;

@interface Command : NSObject

- (void) execute;

@end

@interface ReadViewControllerCommand : Command {
    ReadViewController *readViewController;
}

- (id) initWithController:(ReadViewController *)controller;

@end

@interface GotoPageCommand : ReadViewControllerCommand

- (void) execute;

@end

@interface GotoItemCommand : ReadViewControllerCommand

- (void) execute;

@end

@interface GotoMoreItemsCommand : ReadViewControllerCommand {
    NSNumber *itemNumber;
    NSArray *items;
}

@property (nonatomic, assign) NSNumber *itemNumber;
@property (nonatomic, assign) NSArray *items;

- (void) execute;

@end
