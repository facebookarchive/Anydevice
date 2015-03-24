/*
 *  Copyright (c) 2015, Parse, LLC. All rights reserved.
 *
 *  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
 *  copy, modify, and distribute this software in source code or binary form for use
 *  in connection with the web services and APIs provided by Parse.
 *
 *  As with any software that integrates with the Parse platform, your use of
 *  this software is subject to the Parse Terms of Service
 *  [https://www.parse.com/about/terms]. This copyright notice shall be
 *  included in all copies or substantial portions of the software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 *  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 *  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 *  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 *  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#import "AppDelegate.h"

#import <Parse/Parse.h>

#import "PADConstants.h"
#import "PADDeviceDetailsViewController.h"
#import "PADEvent.h"
#import "PADHomeViewController.h"
#import "PADInstallation.h"
#import "PADMainProvisioningFlowViewController.h"
#import "PADProvisioningContainerViewController.h"
#import "PADProvisioningState.h"
#import "UIColor+CustomColors.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // ****************************************************************************
    // Parse initialization
    //
    // The Application ID and Client Key necessary for Parse initialization are
    // stored in the Constants.m file. Go there to add your own Application ID
    // and Client Key.
    //
    [Parse setApplicationId:PADApplicationId clientKey:PADClientKey];
    // ****************************************************************************

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance] setBarTintColor:[UIColor navigationBarTintColorDefault]];
    [[UINavigationBar appearance] setTintColor:[UIColor navigationTintColorDefault]];

    NSDictionary *eventPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (eventPayload) {
        [self handleEventWithPayload:eventPayload applicationState:application.applicationState];
    }

    return YES;
}

#pragma mark - Push Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // When the application is successfully registered for push notifications, the phone's
    // PADInstallation must be updated with the device token.

    PADInstallation *currentInstallation = [PADInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // This delegate is called when a push notification is received. We forward the notification
    // data and application state to a custom notification handling method.

    [self handleEventWithPayload:userInfo applicationState:application.applicationState];
}

- (void)handleEventWithPayload:(NSDictionary *)payload applicationState:(UIApplicationState)applicationState {
    // If the notification is not an event, do nothing.
    NSString *pushActionString = [payload objectForKey:@"action"];
    if (![pushActionString isEqualToString:@"com.parse.anydevice.EVENT"]) {
        return;
    }

    NSDictionary *eventDictionary = [payload objectForKey:@"event"];
    PADEvent *event = [PADEvent objectFromDictionary:eventDictionary];
    NSString *userSessionId = [payload objectForKey:@"userSessionId"];
    NSString *installationId = [payload objectForKey:@"installationId"];

    // Get reference to the application's root view controller in preparation for deep linking.
    UINavigationController *rootNavigationController = (UINavigationController *)self.window.rootViewController;
    PADHomeViewController *homeViewController = (PADHomeViewController *)[rootNavigationController.viewControllers firstObject];

    // Get a reference to the modally presented navigation controller, if there is one.
    UINavigationController *modalNavigationController;
    UIViewController *modalViewController = rootNavigationController.presentedViewController;
    if ([modalViewController isKindOfClass:[UINavigationController class]]) {
        modalNavigationController = (UINavigationController *)modalViewController;
    }

    // If the user is in the middle of the device provisioning flow, they may be waiting for the
    // provisioning success event. Post a notification so that the provisioning flow can handle this
    // if necessary. No other action is needed in this case.
    if ([modalNavigationController.topViewController isKindOfClass:[PADProvisioningContainerViewController class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PADProvisioningEventNotification
                                                            object:self
                                                          userInfo:@{@"userSessionId" : userSessionId}];
        return;
    }

    // If the user is on the device details screen from which the event was sent, just update
    // that device's latest event.
    UIViewController *topViewController = rootNavigationController.topViewController;
    if ([topViewController isKindOfClass:[PADDeviceDetailsViewController class]]) {
        PADDeviceDetailsViewController *deviceDetailsVC = (PADDeviceDetailsViewController *)topViewController;
        if ([deviceDetailsVC.installation.installationId isEqualToString:installationId]) {
            deviceDetailsVC.latestEvent = event;
            return;
        }
    }

    // If the user is on any other screen, deep link to the device details screen for the device
    // from which the event was sent.
    if (applicationState != UIApplicationStateActive) {
        [rootNavigationController popToRootViewControllerAnimated:NO];
        [homeViewController navigateToDeviceDetailsForInstallationId:installationId
                                                           withEvent:event];

    }
}

@end
