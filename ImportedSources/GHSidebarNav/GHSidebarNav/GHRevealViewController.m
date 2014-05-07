//
//  GHSidebarViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHRevealViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "GADBannerView.h"
#import "GADInterstitial.h"

// if true then ads are shown
static BOOL isFree = false;

#pragma mark -
#pragma mark Constants
const NSTimeInterval kGHRevealSidebarDefaultAnimationDuration = 0.25;
const CGFloat kGHRevealSidebarWidth = 260.0f;
const CGFloat kGHRevealSidebarFlickVelocity = 1000.0f;


#pragma mark -
#pragma mark Private Interface
@interface GHRevealViewController ()
@property (nonatomic, readwrite, getter = isSidebarShowing) BOOL sidebarShowing;
@property (nonatomic, readwrite, getter = isSearching) BOOL searching;
@property (nonatomic, strong) UIView *searchView;
- (void)hideSidebar;
@end


#pragma mark -
#pragma mark Implementation
@implementation GHRevealViewController {
@private
	UIView *_sidebarView;
	UIView *_contentView;
	UITapGestureRecognizer *_tapRecog;
    
    GADBannerView *bannerView_;
    GADInterstitial *interstitial_;
}

- (void)setSidebarViewController:(UIViewController *)svc {
	if (_sidebarViewController == nil) {
		svc.view.frame = _sidebarView.bounds;
        svc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		_sidebarViewController = svc;
		[self addChildViewController:_sidebarViewController];
		[_sidebarView addSubview:_sidebarViewController.view];
		[_sidebarViewController didMoveToParentViewController:self];
	} else if (_sidebarViewController != svc) {
		svc.view.frame = _sidebarView.bounds;
        svc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		[_sidebarViewController willMoveToParentViewController:nil];
		[self addChildViewController:svc];
		self.view.userInteractionEnabled = NO;
		[self transitionFromViewController:_sidebarViewController
						  toViewController:svc
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:^{}
								completion:^(BOOL finished){
									self.view.userInteractionEnabled = YES;
									[_sidebarViewController removeFromParentViewController];
									[svc didMoveToParentViewController:self];
									_sidebarViewController = svc;
								}
		 ];
	}
}

- (void)setContentViewController:(UIViewController *)cvc {
	if (_contentViewController == nil) {
		cvc.view.frame = _contentView.bounds;
		_contentViewController = cvc;
		[self addChildViewController:_contentViewController];
		[_contentView addSubview:_contentViewController.view];
		[_contentViewController didMoveToParentViewController:self];
	} else if (_contentViewController != cvc) {
		cvc.view.frame = _contentView.bounds;
		[_contentViewController willMoveToParentViewController:nil];
		[self addChildViewController:cvc];
		self.view.userInteractionEnabled = NO;
		[self transitionFromViewController:_contentViewController
						  toViewController:cvc
								  duration:0
								   options:UIViewAnimationOptionTransitionNone
								animations:^{}
								completion:^(BOOL finished){
									self.view.userInteractionEnabled = YES;
									[_contentViewController removeFromParentViewController];
									[cvc didMoveToParentViewController:self];
									_contentViewController = cvc;
								}
         ];
	}
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"\nGAD RECEIVED\n");
}

- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"\nGAD FAILED\n %@", [error localizedFailureReason]);
}

-(void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    NSLog(@"\nGADInterstitial RECEIVED\n");
    [interstitial_ presentFromRootViewController:self];
}

-(void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"\nGADInterstitial FAILED\n %@", [error localizedFailureReason]);
}

- (void) requestFullscreenAd {
    if (!isFree) {
        return;
    }
    
    interstitial_ = [[GADInterstitial alloc] init];
    interstitial_.adUnitID = @"XXX";
    [interstitial_ setDelegate:self];
    GADRequest *request = [GADRequest request];
    request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil];
    [interstitial_ loadRequest:request];
}

- (void) incAdCounter {
    static int viewsCount = 0;
    
    if (viewsCount == 0) {
        [self requestFullscreenAd];
    }
    
    viewsCount = (viewsCount + 1) % 5;
    
    NSLog(@"viewed: %d", viewsCount);
}

#pragma mark Memory Management
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        
		self.sidebarShowing = NO;
		self.searching = NO;
		_tapRecog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSidebar)];
		_tapRecog.cancelsTouchesInView = YES;
		
		self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        
        float hbonus = 20;
        if (SYSTEM_RUNS_IOS7_OR_LATER) {
            hbonus = 0;
        }
        
        CGRect cframe = CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-GAD_SIZE_320x50.height - hbonus);
        
        if (!isFree) {
            cframe = self.view.bounds;
        }
        
		_sidebarView = [[UIView alloc] initWithFrame:cframe];
		_sidebarView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		_sidebarView.backgroundColor = [UIColor clearColor];
		[self.view addSubview:_sidebarView];
        
		_contentView = [[UIView alloc] initWithFrame:cframe];
		_contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		_contentView.backgroundColor = [UIColor clearColor];
		_contentView.layer.masksToBounds = NO;
		_contentView.layer.shadowColor = [UIColor blackColor].CGColor;
		_contentView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
		_contentView.layer.shadowOpacity = 1.0f;
		_contentView.layer.shadowRadius = 2.5f;
		_contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:_contentView.bounds].CGPath;
		[self.view addSubview:_contentView];
        
        if (!isFree) {
            return self;
        }
        
        UIImageView *sview = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height-GAD_SIZE_320x50.height+1, self.view.bounds.size.width, GAD_SIZE_320x50.height-1)];
        
        sview.contentMode = UIViewContentModeScaleToFill;
        sview.alpha = 0.5;
        [sview setImage:[UIImage imageNamed:@"aabottom"]];
        [self.view addSubview:sview];
        
        bannerView_ = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height-GAD_SIZE_320x50.height, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
        
        [bannerView_ setDelegate:self];
        
        // Specify the ad unit ID.
        bannerView_.adUnitID = @"XXX";
        // Let the runtime know which UIViewController to restore after taking
        // the user wherever the ad goes and add it to the view hierarchy.
        bannerView_.rootViewController = self;
        [self.view addSubview:bannerView_];
        // Initiate a generic request to load it with an ad.
        
        GADRequest *request = [GADRequest request];
        request.testDevices = [NSArray arrayWithObjects:GAD_SIMULATOR_ID, nil];
        [bannerView_ loadRequest:request];

    }
    return self;
}

#pragma mark UIViewController
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	return (orientation == UIInterfaceOrientationPortraitUpsideDown)
    ? (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    : YES;
}

#pragma mark Public Methods
- (void)dragContentView:(UIPanGestureRecognizer *)panGesture {
	CGFloat translation = [panGesture translationInView:self.view].x;
	if (panGesture.state == UIGestureRecognizerStateChanged) {
		if (_sidebarShowing) {
			if (translation > 0.0f) {
				_contentView.frame = CGRectOffset(_contentView.bounds, kGHRevealSidebarWidth, 0.0f);
				self.sidebarShowing = YES;
			} else if (translation < -kGHRevealSidebarWidth) {
				_contentView.frame = _contentView.bounds;
				self.sidebarShowing = NO;
			} else {
				_contentView.frame = CGRectOffset(_contentView.bounds, (kGHRevealSidebarWidth + translation), 0.0f);
			}
		} else {
			if (translation < 0.0f) {
				_contentView.frame = _contentView.bounds;
				self.sidebarShowing = NO;
			} else if (translation > kGHRevealSidebarWidth) {
				_contentView.frame = CGRectOffset(_contentView.bounds, kGHRevealSidebarWidth, 0.0f);
				self.sidebarShowing = YES;
			} else {
				_contentView.frame = CGRectOffset(_contentView.bounds, translation, 0.0f);
			}
		}
	} else if (panGesture.state == UIGestureRecognizerStateEnded) {
		CGFloat velocity = [panGesture velocityInView:self.view].x;
		BOOL show = (fabs(velocity) > kGHRevealSidebarFlickVelocity)
        ? (velocity > 0)
        : (translation > (kGHRevealSidebarWidth / 2));
		[self toggleSidebar:show duration:kGHRevealSidebarDefaultAnimationDuration];
		
	}
}

- (void)toggleSidebar:(BOOL)show duration:(NSTimeInterval)duration {
	[self toggleSidebar:show duration:duration completion:^(BOOL finshed){}];
}

- (void)toggleSidebar:(BOOL)show duration:(NSTimeInterval)duration completion:(void (^)(BOOL finsihed))completion {
    __weak GHRevealViewController *selfRef = self;
	void (^animations)(void) = ^{
		if (show) {
			_contentView.frame = CGRectOffset(_contentView.bounds, kGHRevealSidebarWidth, 0.0f);
			[_contentView addGestureRecognizer:_tapRecog];
            [selfRef.contentViewController.view setUserInteractionEnabled:NO];
		} else {
			if (self.isSearching) {
				_sidebarView.frame = CGRectMake(0.0f, 0.0f, kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds));
			} else {
				[_contentView removeGestureRecognizer:_tapRecog];
			}
			_contentView.frame = _contentView.bounds;
            [selfRef.contentViewController.view setUserInteractionEnabled:YES];
		}
		selfRef.sidebarShowing = show;
	};
    
	if (duration > 0.0) {
		[UIView animateWithDuration:duration
							  delay:0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:animations
						 completion:completion];
	} else {
		animations();
		completion(YES);
	}
}

- (void)toggleSearch:(BOOL)showSearch withSearchView:(UIView *)srchView duration:(NSTimeInterval)duration {
	[self toggleSearch:showSearch withSearchView:srchView duration:duration completion:^(BOOL finished){}];
}

- (void)toggleSearch:(BOOL)showSearch withSearchView:(UIView *)srchView duration:(NSTimeInterval)duration completion:(void (^)(BOOL finsihed))completion {
	if (showSearch) {
		srchView.frame = self.view.bounds;
	} else {
		_sidebarView.alpha = 0.0f;
		_contentView.frame = CGRectOffset(self.view.bounds, CGRectGetWidth(self.view.bounds), 0.0f);
		[self.view addSubview:_contentView];
	}
	void (^animations)(void) = ^{
		if (showSearch) {
			_contentView.frame = CGRectOffset(_contentView.bounds, CGRectGetWidth(self.view.bounds), 0.0f);
			[_contentView removeGestureRecognizer:_tapRecog];
			[_sidebarView removeFromSuperview];
			self.searchView = srchView;
			[self.view insertSubview:self.searchView atIndex:0];
		} else {
			_sidebarView.frame = CGRectMake(0.0f, 0.0f, kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds));
			_sidebarView.alpha = 1.0f;
			[self.view insertSubview:_sidebarView atIndex:0];
			self.searchView.frame = _sidebarView.frame;
			_contentView.frame = CGRectOffset(_contentView.bounds, kGHRevealSidebarWidth, 0.0f);
		}
	};
	void (^fullCompletion)(BOOL) = ^(BOOL finished){
		if (showSearch) {
			_contentView.frame = CGRectOffset(_contentView.bounds, CGRectGetHeight([UIScreen mainScreen].bounds), 0.0f);
			[_contentView removeFromSuperview];
		} else {
			[_contentView addGestureRecognizer:_tapRecog];
			[self.searchView removeFromSuperview];
			self.searchView = nil;
		}
		self.sidebarShowing = YES;
		self.searching = showSearch;
		completion(finished);
	};
	if (duration > 0.0) {
		[UIView animateWithDuration:duration
							  delay:0
							options:UIViewAnimationOptionCurveEaseInOut
						 animations:animations
						 completion:fullCompletion];
	} else {
		animations();
		fullCompletion(YES);
	}
}

#pragma mark Private Methods
- (void)hideSidebar {
	[self toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];
}

@end