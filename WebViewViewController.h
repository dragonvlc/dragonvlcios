//
//  WebViewViewController.h
//  VLC for iOS
//
//  Created by Janusz Jankowski on 10/03/14.
//  Copyright (c) 2014 VideoLAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;

@end
