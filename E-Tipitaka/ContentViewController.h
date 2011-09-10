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
    UIWebView *webView;
    Content *content;
    NSString *highlightText;
    NSUInteger itemNumber;
    NSUInteger fontSize;
    NSUInteger scrollPosition;
    BOOL scrollToItemNumber;
    BOOL scrollToHighlightText;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) Content *content;
@property (nonatomic, retain) NSString *highlightText;
@property (assign) NSUInteger itemNumber;
@property (assign) NSUInteger fontSize;
@property (assign) NSUInteger scrollPosition;
@property (assign) BOOL scrollToItemNumber;
@property (assign) BOOL scrollToHighlightText;

-(NSString *) convertContentToHTML;
-(NSString *) convertWhiteSpacesToHTML:(NSString *)text;
-(NSString *) markHighlight:(NSString *)text;
-(NSString *) anchorItemNumber:(NSString *)text;

@end
