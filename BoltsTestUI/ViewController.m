/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "ViewController.h"
#import "AppDelegate.h"
#import <Bolts/Bolts.h>

static NSString *const BFURLWithRefererData = @"bolts://?foo=bar&al_applink_data=%7B%22a%22%3A%22b%22%2C%22user_agent%22%3A%22Bolts%20iOS%201.0.0%22%2C%22target_url%22%3A%22http%3A%5C%2F%5C%2Fwww.example.com%5C%2Fpath%3Fbaz%3Dbat%22%2C%22referer_app_link%22%3A%7B%22app_name%22%3A%22Facebook%22%2C%22url%22%3A%22fb%3A%5C%2F%5C%2Fsomething%5C%2F%22%7D%7D";

@interface ViewController ()

@property (nonatomic, strong) BFAppLinkReturnToRefererController *returnToRefererController;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showRefererBackButtonIfNeeded];
    [[AppDelegate sharedInstance] addObserver:self forKeyPath:@"receivedAppLinkURL" options:0 context:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self showRefererBackButtonIfNeeded];
    [[AppDelegate sharedInstance] removeObserver:self forKeyPath:@"receivedAppLinkURL"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"receivedAppLinkURL"]) {
        [self showRefererBackButtonIfNeeded];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (IBAction)didTapAppLinkButton:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:BFURLWithRefererData]];
}

- (IBAction)didTapFlipButton:(UIButton *)sender {
    if ([self.presentingViewController isKindOfClass:[ViewController class]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        ViewController *viewController = [[ViewController alloc] init];
        viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (void)showRefererBackButtonIfNeeded
{
    BFURL *receivedAppLinkURL = [[AppDelegate sharedInstance] receivedAppLinkURL];
    if (receivedAppLinkURL.appLinkReferer != nil) {
        if (self.returnToRefererController == nil) {
            self.returnToRefererController = [[BFAppLinkReturnToRefererController alloc] init];
            self.returnToRefererController.view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 1);
            self.returnToRefererController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [self.view addSubview:self.returnToRefererController.view];
        }
        self.returnToRefererController.view.closed = NO;
        [self.returnToRefererController showViewForRefererAppLink:receivedAppLinkURL.appLinkReferer];
    } else {
        [self.returnToRefererController removeFromNavController];
    }
}

@end
