//
//  TapDetectingWindow.h
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TapDetectingWindowDelegate
- (void)userDidTapView:(id)tapPoint;
@end
@interface TapDetectingWindow : UIWindow {
    UIView *viewToObserve;
    id <TapDetectingWindowDelegate> __weak controllerThatObserves;
}
@property (nonatomic, strong) UIView *viewToObserve;
@property (nonatomic, weak) id <TapDetectingWindowDelegate> controllerThatObserves;
@end