//
//  WebViewViewController.m
//  VLC for iOS
//
//  Created by Janusz Jankowski on 10/03/14.
//  Copyright (c) 2014 VideoLAN. All rights reserved.
//

#import "WebViewViewController.h"
#import "VLCAppDelegate.h"
#import "UIBarButtonItem+Theme.h"

@interface WebViewViewController ()

@end

@implementation WebViewViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title"]];
    
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem themedRevealMenuButtonWithTarget:self andSelector:@selector(goBack:)];
    
    self.view.backgroundColor = [UIColor colorWithWhite:.122 alpha:1.];
    self.webView.backgroundColor = [UIColor colorWithWhite:.122 alpha:1.];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mobileonline.tv"]]];
    
    self.webView.delegate = self;
}

- (BOOL)shouldAutorotate
{
    UIInterfaceOrientation toInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        return NO;
    return YES;
}

- (IBAction)goBack:(id)sender
{
    [[(VLCAppDelegate*)[UIApplication sharedApplication].delegate revealController] toggleSidebar:![(VLCAppDelegate*)[UIApplication sharedApplication].delegate revealController].sidebarShowing duration:kGHRevealSidebarDefaultAnimationDuration];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//    if([[request.URL absoluteString] hasPrefix:@"http://www.nzx"]) {
//        // do stuff
//        NSLog(@"Have caught the prefix");
//        return YES;
//    }
//    
//    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
//        [[UIApplication sharedApplication] openURL:[request URL]];
//        return NO;
//    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    webView.alpha = 0.;
    CGFloat alpha = 1.;

    void (^animationBlock)() = ^() {
        webView.alpha = alpha;
    };

    void (^completionBlock)(BOOL finished) = ^(BOOL finished) {
        webView.hidden = NO;
    };

    [UIView animateWithDuration:.3 animations:animationBlock completion:completionBlock];
}
//
//- (IBAction)openContributePage:(id)sender
//{
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.videolan.org/contribute.html"]];
//}

@end
