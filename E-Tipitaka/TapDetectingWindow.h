//
//  TapDetectingWindow.h
//  ETipitaka
//
//  Created by Sutee Sudprasert on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TapDetectingWindowDelegate
- (void)userDidTapWebView:(id)tapPoint;
@end
@interface TapDetectingWindow : UIWindow {
    UIView *viewToObserve;
    id <TapDetectingWindowDelegate> controllerThatObserves;
}
@property (nonatomic, retain) UIView *viewToObserve;
@property (nonatomic, assign) id <TapDetectingWindowDelegate> controllerThatObserves;
@end