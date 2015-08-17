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
#import "NavigationController.h"
#import <Bolts/Bolts.h>

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showRefererBackButtonIfNeeded];
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
    if (self.presentingViewController != nil && self.navigationController == nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        ViewController *viewController = [[ViewController alloc] init];
        viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (IBAction)didTapModalButton:(UIButton *)sender {
    NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)showRefererBackButtonIfNeeded
{
    BFURL *receivedAppLinkURL = [[AppDelegate sharedInstance] receivedAppLinkURL];
    if (receivedAppLinkURL.appLinkReferer != nil) {
        if (self.returnToRefererController == nil) {
            self.returnToRefererController = [[BFAppLinkReturnToRefererController alloc] initForDisplayInViewController:self];
        }
        self.returnToRefererController.view.closed = NO;
        [self.returnToRefererController showViewForRefererAppLink:receivedAppLinkURL.appLinkReferer];
    } else {
        [self.returnToRefererController removeFromViewController];
    }
}

@end
