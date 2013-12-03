//
//  ContentViewController.m
//  E-Tipitaka
//
//  Created by Sutee Sudprasert on 9/9/54 BE.
//  Copyright 2554 __MyCompanyName__. All rights reserved.
//

#import "Utils.h"
#import "ContentViewController.h"
#import "Content.h"
#import "Item.h"
#import "ContentInfo.h"
#import "QueryHelper.h"

@interface ContentViewController()
// private methods
@end

@implementation ContentViewController

@synthesize content = _content;
@synthesize highlightText = _highlightText;
@synthesize itemNumber;
@synthesize fontSize;
@synthesize scrollPosition;
@synthesize scrollToItemNumber;
@synthesize scrollToHighlightText;
@synthesize indictor=_indictor;
@synthesize webView=_webView;
@synthesize entity = _entity;
@synthesize fontColorIndex = _fontColorIndex;

- (id)initWithEntity:(id<SocializeEntity>)entity
{
    self = [super init];
    if (self) {
        self.entity = entity;
        self.fontSize = 24;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)update
{
    [self.webView loadHTMLString:[self convertContentToHTML]
                    baseURL:[NSURL URLWithString:@"http://www.etipitaka.com"]];    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];        
    
    self.webView.scalesPageToFit = YES;
    
    [self.view bringSubviewToFront:self.indictor];
    for (id subview in self.webView.subviews)
        if ([[subview class] isSubclassOfClass: [UIScrollView class]])
            ((UIScrollView *)subview).bounces = NO;    
    
    if (self.entity) {
        self.title = self.entity.name;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        } else {
            titleLabel.font = [UIFont boldSystemFontOfSize:20.0];    
        }
        
        titleLabel.textColor = [UIColor whiteColor];
        self.navigationItem.titleView = titleLabel;
        titleLabel.text = self.title;
        [titleLabel sizeToFit];    
        
        NSString *key = self.entity.key;
        
        if ([key componentsSeparatedByString:@"?"].count == 2) {
            NSArray *tokens = [[key componentsSeparatedByString:@"?"].lastObject componentsSeparatedByString:@"&"];        
            NSString *langauge;
            NSNumber *volume, *page;
            
            for (NSString *token in tokens) {
                if ([token hasPrefix:@"language"]) {
                    langauge = [[token componentsSeparatedByString:@"="].lastObject capitalizedString];
                } else if ([token hasPrefix:@"number"]) {
                    page = [NSNumber numberWithInt:[[token componentsSeparatedByString:@"="].lastObject intValue]];
                } else if ([token hasPrefix:@"volume"]) {
                    volume = [NSNumber numberWithInt:[[token componentsSeparatedByString:@"="].lastObject intValue]];
                }
            }        
            
            ContentInfo *info = [[ContentInfo alloc] init];
            info.language = langauge;
            info.volume = volume;
            info.page = page;
            [info setType:(LANGUAGE|VOLUME|PAGE)];
            NSArray *fetchedObjects = [QueryHelper getContents:info];
            if (fetchedObjects && fetchedObjects.count == 1) {
                self.content = [fetchedObjects objectAtIndex:0];
            }
        }        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.content) {
        [self update];
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.indictor = nil;
    self.webView = nil;
}

#pragma mark - Private Methods

-(NSString *)convertWhiteSpacesToHTML:(NSString *)text
{
    NSString *html = [text stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    return [html stringByReplacingOccurrencesOfString:@"\t" withString:@"&nbsp;&nbsp;"];
}

-(NSString *)markHighlight:(NSString *)text
{
    if (!self.highlightText) {
        return text;
    }
    
    NSArray *tokens = [self.highlightText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    for(__strong NSString *token in tokens) {
        token = [token stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        
        //must use UTF8 for replacing Thai text
        const char *orig = [text UTF8String];
        const char *with = [[NSString 
                             stringWithFormat:@"<font color=\"#0000FF\" id=\"keywords\" style=\"background-color:yellow;\">%@</font>", token] UTF8String];
        const char *rep = [token UTF8String];
        char * result = [Utils replace:orig pattern:rep replacement:with];
        text = [NSString stringWithUTF8String:result];
        free(result);
    }
    return text;
    
}

-(NSString *)anchorItemNumber:(NSString *)text
{
    for (Item *item in self.content.items) {
        if ([item.begin boolValue] == YES) {
            NSString *tmp = [[NSString alloc] initWithFormat:@"[%@]", [Utils arabic2thai:[item.number stringValue]]];
            
            text = [text stringByReplacingOccurrencesOfString:tmp 
                                                   withString:[NSString
                                                               stringWithFormat:@"<font id=\"i%@\" color=\"#FF0000\">%@</font>", 
                                                               item.number, tmp]];
        }
    }
    return text;
}

-(NSString *)convertContentToHTML
{
    NSString *text = [self anchorItemNumber:[self markHighlight:[self convertWhiteSpacesToHTML:self.content.text]]];
    NSString *template = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"page" ofType:@"html"] 
                                                   encoding:NSUTF8StringEncoding error:nil];
    NSString *html = [[NSString alloc] 
                      initWithFormat:template, fontSize, [self fontColor], [self backgroudColor], text];
    return html;
}

#pragma mark - 
#pragma mark Web View Delegate Methods 

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{       
    if (scrollToItemNumber) {
		[aWebView stringByEvaluatingJavaScriptFromString:
		 [NSString stringWithFormat:
		  @"var item = document.getElementById(\"i%d\"); \n"
		  " if(item) { \n"
		  "    ScrollToElement(item); \n"
		  " }", itemNumber
		  ]];
		scrollToItemNumber = NO;
	}
	else if (scrollToHighlightText) {
		[aWebView stringByEvaluatingJavaScriptFromString:
		 @"var keywords = document.getElementById(\"keywords\"); \n"
		 " if(keywords) { \n"
		 "    ScrollToElement(keywords); \n"
		 " }"
		 ];
		scrollToHighlightText = NO;
	} 
	else {
        [aWebView stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:@"window.scrollTo(0,%d);", scrollPosition]];        
	}
    [aWebView scalesPageToFit];
    
    NSString *varMySheet = @"var mySheet = document.styleSheets[0];";
	NSString *addCSSRule =  @"function addCSSRule(selector, newRule) {"
	"if (mySheet.addRule) {"
    "mySheet.addRule(selector, newRule);"								// For Internet Explorer
	"} else {"
    "ruleIndex = mySheet.cssRules.length;"
    "mySheet.insertRule(selector + '{' + newRule + ';}', ruleIndex);"   // For Firefox, Chrome, etc.
    "}"
	"}";

    [aWebView stringByEvaluatingJavaScriptFromString:varMySheet];
    [aWebView stringByEvaluatingJavaScriptFromString:addCSSRule];
    
    NSString *setThemeColorRule = [NSString stringWithFormat:@"addCSSRule('body', 'background-color: %@; color: %@;')", [self backgroudColor], [self fontColor]];
    [aWebView stringByEvaluatingJavaScriptFromString:setThemeColorRule];
    
    [self.indictor stopAnimating];
    self.indictor.hidden = YES;    
}

- (NSString *)backgroudColor
{
     NSString *backgroundColor = @"#FFFFFF";
    switch (self.fontColorIndex) {
        case 0:
             backgroundColor = @"FEFEFE";
            break;
        case 1:
             backgroundColor = @"010101";
            break;
        case 2:
             backgroundColor = @"F9EFD8";
            break;
    }
    return backgroundColor;
}

- (NSString *)fontColor
{
    NSString *fontColor = @"#000000";
     switch (self.fontColorIndex) {
        case 0:
            fontColor = @"010101";
             break;
        case 1:
            fontColor = @"FEFEFE";
             break;
        case 2:
            fontColor = @"5E4933";
             break;
    }
    return fontColor;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.indictor.hidden = NO;
    [self.indictor startAnimating];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate {
    return YES;
 
}

@end
