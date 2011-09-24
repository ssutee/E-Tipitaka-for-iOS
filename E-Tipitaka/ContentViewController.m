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

@interface ContentViewController()
// private methods
@end

@implementation ContentViewController

@synthesize content;
@synthesize highlightText;
@synthesize itemNumber;
@synthesize fontSize;
@synthesize scrollPosition;
@synthesize scrollToItemNumber;
@synthesize scrollToHighlightText;
@synthesize indictor=_indictor;
@synthesize webView=_webView;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc
{
    [_indictor release];
    [_webView release];
    [super dealloc];
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
    if (!highlightText) {
        return text;
    }
    
    NSArray *tokens = [highlightText componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    for(NSString *token in tokens) {
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
    for (Item *item in content.items) {
        if ([item.begin boolValue] == YES) {
            NSString *tmp = [[NSString alloc] initWithFormat:@"[%@]", [Utils arabic2thai:[item.number stringValue]]];
            
            text = [text stringByReplacingOccurrencesOfString:tmp 
                                                   withString:[NSString
                                                               stringWithFormat:@"<font id=\"i%@\" color=\"#FF0000\">%@</font>", 
                                                               item.number, tmp]];
            [tmp release];
        }
    }
    return text;
}

-(NSString *)convertContentToHTML
{
    NSString *text = [self anchorItemNumber:[self markHighlight:[self convertWhiteSpacesToHTML:content.text]]];
    NSString *template = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"page" ofType:@"html"] 
                                                   encoding:NSUTF8StringEncoding error:nil];
    NSString *html = [[[NSString alloc] 
                      initWithFormat:template, fontSize, text] autorelease];
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
    [self.indictor stopAnimating];
    self.indictor.hidden = YES;
    [aWebView scalesPageToFit];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
