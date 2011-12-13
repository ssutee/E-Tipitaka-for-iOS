//
//  ContentViewController.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 9/9/54 BE.
//  Copyright 2554 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Content;

@interface ContentViewController : UIViewController <UIWebViewDelegate>
{
    NSUInteger itemNumber;
    NSUInteger fontSize;
    NSUInteger scrollPosition;
    BOOL scrollToItemNumber;
    BOOL scrollToHighlightText;
}

@property (nonatomic, retain) Content *content;
@property (nonatomic, retain) NSString *highlightText;
@property (assign) NSUInteger itemNumber;
@property (assign) NSUInteger fontSize;
@property (assign) NSUInteger scrollPosition;
@property (assign) BOOL scrollToItemNumber;
@property (assign) BOOL scrollToHighlightText;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *indictor;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

-(NSString *) convertContentToHTML;
-(NSString *) convertWhiteSpacesToHTML:(NSString *)text;
-(NSString *) markHighlight:(NSString *)text;
-(NSString *) anchorItemNumber:(NSString *)text;

-(void) update;

@end
