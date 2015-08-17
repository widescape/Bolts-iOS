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

@interface ViewController () <BFAppLinkReturnToRefererControllerDelegate>

@property (nonatomic, strong) BFAppLinkReturnToRefererController *returnToRefererController;

@end

@implementation ViewController

#pragma mark - Sample Implementation

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

- (void)showRefererBackButtonIfNeeded
{
    BFURL *receivedAppLinkURL = [AppDelegate sharedInstance].receivedAppLinkURL;
    if (receivedAppLinkURL.appLinkReferer != nil) {
        if (self.returnToRefererController == nil) {
            self.returnToRefererController = [[BFAppLinkReturnToRefererController alloc] initForDisplayInViewController:self];
        }
        [self.returnToRefererController showViewForRefererAppLink:receivedAppLinkURL.appLinkReferer];
    } else {
        [self.returnToRefererController removeFromViewController];
    }
}

- (void)returnToRefererController:(BFAppLinkReturnToRefererController *)controller didCloseView:(BFAppLinkReturnToRefererView *)view animated:(BOOL)animated {
    [AppDelegate sharedInstance].receivedAppLinkURL = nil;
}

#pragma mark - Sample App Interface Events

- (IBAction)appLinkButtonTapped:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:BFURLWithRefererData]];
}

- (IBAction)flipButtonTapped:(UIButton *)sender {
    if (self.presentingViewController != nil && self.navigationController == nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        ViewController *viewController = [[ViewController alloc] init];
        viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:viewController animated:YES completion:nil];
    }
}

- (IBAction)modalButtonTapped:(UIButton *)sender {
    UIViewController *viewController = [[ViewController alloc] init];
    viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.navigationBar.translucent = NO;

    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)doneButtonTapped:(id)sender
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
