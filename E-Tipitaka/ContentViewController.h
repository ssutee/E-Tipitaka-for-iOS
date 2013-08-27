//
//  ContentViewController.h
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 9/9/54 BE.
//  Copyright 2554 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Socialize/Socialize.h>

@class Content;

@interface ContentViewController : UIViewController <UIWebViewDelegate>
{
    NSUInteger itemNumber;
    NSUInteger fontSize;
    NSUInteger scrollPosition;
    BOOL scrollToItemNumber;
    BOOL scrollToHighlightText;
}

@property (nonatomic, strong) Content *content;
@property (nonatomic, strong) NSString *highlightText;
@property (nonatomic, assign) NSUInteger itemNumber;
@property (nonatomic, assign) NSUInteger fontSize;
@property (nonatomic, assign) NSUInteger scrollPosition;
@property (nonatomic, assign) BOOL scrollToItemNumber;
@property (nonatomic, assign) BOOL scrollToHighlightText;
@property (nonatomic, strong) id<SocializeEntity> entity;
@property (nonatomic, assign) NSInteger fontColorIndex;

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indictor;
@property (nonatomic, strong) IBOutlet UIWebView *webView;

- (id)initWithEntity:(id<SocializeEntity>)entity;
-(NSString *) convertContentToHTML;
-(NSString *) convertWhiteSpacesToHTML:(NSString *)text;
-(NSString *) markHighlight:(NSString *)text;
-(NSString *) anchorItemNumber:(NSString *)text;

-(void) update;

@end
