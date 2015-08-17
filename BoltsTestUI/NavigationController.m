/*
 *  Copyright (c) 2014, Facebook, Inc.
 *  All rights reserved.
 *
 *  This source code is licensed under the BSD-style license found in the
 *  LICENSE file in the root directory of this source tree. An additional grant
 *  of patent rights can be found in the PATENTS file in the same directory.
 *
 */

#import "NavigationController.h"
#import "AppDelegate.h"
#import <Bolts/Bolts.h>

@interface NavigationController ()

@end

@implementation NavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.navigationBar.translucent = NO;
        rootViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didTapDoneButton:)];
    }
    return self;
}

- (IBAction)didTapAppLinkButton:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:BFURLWithRefererData]];
}

- (void)didTapDoneButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
