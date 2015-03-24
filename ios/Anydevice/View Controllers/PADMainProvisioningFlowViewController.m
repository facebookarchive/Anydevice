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

#import "PADMainProvisioningFlowViewController.h"

#import <SystemConfiguration/CaptiveNetwork.h>

#import <Parse/Parse.h>

#import "PADAlertUtilities.h"
#import "PADDeviceReachabilityManager.h"
#import "PADEventsService.h"
#import "PADInfrastructureKey.h"
#import "PADInstallation.h"
#import "PADProvisioningEventManager.h"
#import "PADProvisioningService.h"
#import "PADProvisioningState.h"
#import "PADTimer.h"
#import "PADUserSession.h"
#import "PADWifiCredentialsService.h"
#import "PADWifiReachabilityManager.h"
#import "UIColor+CustomColors.h"

static const NSTimeInterval kReconnectingTimeoutInterval = 30;

@interface PADMainProvisioningFlowViewController ()

/*!
 @abstract <PADDeviceReachabilityManager> object that determines the current connection state
 between the phone and a device.

 @see PADDeviceReachabilityManager.h
 */
@property (nonatomic, strong) PADDeviceReachabilityManager *deviceReachabilityManager;

/*!
 @abstract <PADWifiReachabilityManager> object that determines the current wifi connection state of
 the phone.

 @see PADWifiReachabilityManager.h
 */
@property (nonatomic, strong) PADWifiReachabilityManager *wifiReachabilityManager;

/*!
 @abstract Timer that controls the timout interval for reconnecting to a wifi network.

 @see PADTimer.h
 */
@property (nonatomic, strong) PADTimer *wifiReconnectTimer;

/*!
 @abstract <PADProvisioningEventManager> object that manages waiting to receive the initial
 provisioning success event from the connected device.

 @see PADProvisioningEventManager.h
 */
@property (nonatomic, strong) PADProvisioningEventManager *eventManager;

/*!
 @abstract The alert view controller currently being displayed (if any).
 */
@property (nonatomic, weak) UIAlertController *currentAlertController;

@end

@implementation PADMainProvisioningFlowViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appForegrounded)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.provisioningState.currentStep == PADProvisioningStepInitialProvision) {
        [self provisionNewDevice];

    } else if (self.provisioningState.currentStep == PADProvisioningStepDisconnecting) {
        // Initialize the event manager which waits for the provisioning event to be sent from the
        // device being provisioned.
        NSString *userSessionId = self.provisioningState.userSession.objectId;
        self.eventManager = [[PADProvisioningEventManager alloc] initWithUserSessionId:userSessionId];

        // If the phone is disconnecting from the device, setup device reachability to determine
        // when the connection is lost.
        [self setupDeviceReachability];

        [self updateViewForCurrentStep];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // Ensure the reachability classes are stopped and destroyed.
    [self tearDownWifiReachability];
    [self tearDownDeviceReachability];
}

#pragma mark - Actions

- (IBAction)stepButtonTapped:(id)sender {
    // Generic action button that has specific results based on the current provisioning step.

    switch (self.provisioningState.currentStep) {
        case PADProvisioningStepInitialProvisionFailed:
            // Retry initialization step.
            self.provisioningState.currentStep = PADProvisioningStepInitialProvision;
            [self provisionNewDevice];
            break;
        case PADProvisioningStepGoToWifi:
        case PADProvisioningStepConnectionFailed:
        case PADProvisioningStepReconnectingFailed: {
            // Deep link to the iOS Settings app.
            NSURL *settingsUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsUrl];
            break;
        }
        case PADProvisioningStepConnected:
            // Navigate to the confirm provisioning details controller.
            self.provisioningState.currentStep = PADProvisioningStepConfirmDevice;
            [self.delegate swapViewControllerForCurrentStep];
            break;
        case PADProvisioningStepEventFailed:
            [self.delegate finishProvisioningWithCancelConfirmation:NO deleteDevice:NO];
            break;
        default:
            // No button or action for the current step.
            break;
    }
}

#pragma mark - Private

/*!
 @abstract Initializes a reachability manager which will receive callbacks when the phone's network
 reachability changes.

 @discussion This method is used when the phone has disconnected from the device and is attempting
 to reconnect to a wifi network that it remembers. In order to limit the amount of time reconnecting
 can take, a timer is started.
 */
- (void)setupWifiReachability {
    self.wifiReachabilityManager = [[PADWifiReachabilityManager alloc] init];

    __weak typeof(self) weakSelf = self;
    self.wifiReachabilityManager.reachabilityChangedBlock = ^(PADNetworkStatus currentNetworkStatus) {
        PADProvisioningStep currentStep = weakSelf.provisioningState.currentStep;

        // If the phone is attempting to reconnect to wifi and wifi is reachable, finish
        // provisioning.
        BOOL proceedToFinish = (currentStep == PADProvisioningStepReconnecting ||
                                currentStep == PADProvisioningStepReconnectingFailed);

        if (currentNetworkStatus == PADNetworkStatusReachable && proceedToFinish) {
            [weakSelf finishProvisioning];
        }
    };

    // Start timer to limit the time reconnecting can take.
    self.wifiReconnectTimer = [[PADTimer alloc] initWithTimeout:kReconnectingTimeoutInterval
                                                        repeats:NO];

    [self.wifiReconnectTimer startTimerWithTimeoutBlock:[self reconnectingTimeoutBlock]];

    // Start receiving reachability change callbacks.
    [self.wifiReachabilityManager startNotifier];
}

/*!
 @abstract Creates a block that handles the wifi network reconnection timeout.

 @returns A block with no parameters and no return value.
 */
- (void (^)())reconnectingTimeoutBlock {
    __weak typeof(self) weakSelf = self;
    return ^{
        weakSelf.provisioningState.currentStep = PADProvisioningStepReconnectingFailed;
        [weakSelf updateViewForCurrentStep];
    };
}

/*!
 @abstract Stops the reconnecting timer and wifi reachability notifier.
 */
- (void)tearDownWifiReachability {
    [self.wifiReconnectTimer stopTimer];
    [self.wifiReachabilityManager stopNotifier];
    self.wifiReachabilityManager = nil;
}

/*!
 @abstract Initializes a reachability manager which will receive callbacks when the connection to
 the device changes.

 @discussion This method is called after the provisioning information has been sent to the connected
 device, and the device drops its access point, thereby disconnecting from the phone.
 */
- (void)setupDeviceReachability {
    self.deviceReachabilityManager = [[PADDeviceReachabilityManager alloc] init];

    __weak typeof(self) weakSelf = self;
    self.deviceReachabilityManager.reachabilityChangedBlock = ^(DeviceStatus currentDeviceStatus) {
        // When the phone disconnects from the device, it will try to reconnect to a previous wifi
        // network that it remembers. Therefore we start the wifi reachability when the device
        // disconnects, and tear down device reachability.
        if (currentDeviceStatus == PADDeviceStatusNotReachable &&
            weakSelf.provisioningState.currentStep == PADProvisioningStepDisconnecting)
        {
            [weakSelf tearDownDeviceReachability];

            weakSelf.provisioningState.currentStep = PADProvisioningStepReconnecting;
            [weakSelf updateViewForCurrentStep];

            [weakSelf setupWifiReachability];
        }
    };

    [self.deviceReachabilityManager startNotifier];
}

/*!
 @abstract Stops the device reachability notifier.
 */
- (void)tearDownDeviceReachability {
    [self.deviceReachabilityManager stopNotifier];
    self.deviceReachabilityManager = nil;
}

/*!
 @abstract Starts the provisioning process by creating a user session object for the device on the
 Parse cloud.

 @discussion Before making a request to create the session, it checks if the user has already
 connected to the device. If so, the user is asked to change their network to one with an internet
 connection.
 */
- (void)provisionNewDevice {
    self.provisioningState.currentStep = PADProvisioningStepInitialProvision;
    [self updateViewForCurrentStep];

    // Ensure the user has not already connected to the device, as the initial provisioning step
    // requires an internet connection.
    __weak typeof(self) weakSelf = self;
    [PADDeviceReachabilityManager deviceReachabilityStatusWithCompletionBlock:^(DeviceStatus deviceStatus) {
        if (deviceStatus == PADDeviceStatusReachable) {
            weakSelf.provisioningState.currentStep = PADProvisioningStepInitialProvisionConnectedToBoard;
            [weakSelf updateViewForCurrentStep];
            return;
        }

        // The phone is not connected to a device - proceed with provisioning.
        [PADProvisioningService startProvisioningNewDeviceWithSuccess:^(PADUserSession *userSession) {
            weakSelf.provisioningState.userSession = userSession;
            weakSelf.provisioningState.currentStep = PADProvisioningStepGoToWifi;

            // Fetch any saved wifi credentials for this network before the user leaves the network
            // and connects to the device.
            [weakSelf loadWifiCredentials];
            [weakSelf updateViewForCurrentStep];

        } failure:^(NSError *error) {
            weakSelf.provisioningState.currentStep = PADProvisioningStepInitialProvisionFailed;
            [weakSelf updateViewForCurrentStep];
        }];

    }];
}

- (void)loadWifiCredentials {
    [PADWifiCredentialsService currentWifiCredentialsWithSuccess:^(PADInfrastructureKey *wifiCredentials) {
        self.provisioningState.wifiCredentials = wifiCredentials;
    } failure:nil];
}

/*!
 @abstract Called when the user foregrounds the application.

 @discussion Some provisioning steps require the user to leave the application to perform some
 other action (e.g. changing wifi networks). This method is used to continue the provisioning flow
 when the user re-enters the application based on the provisioning step they are completing.
 */
- (void)appForegrounded {
    [self.currentAlertController dismissViewControllerAnimated:NO completion:nil];

    switch (self.provisioningState.currentStep) {
        case PADProvisioningStepInitialProvisionConnectedToBoard:
        case PADProvisioningStepInitialProvisionFailed:
            // Retry provisioning.
            [self provisionNewDevice];
            break;
        case PADProvisioningStepGoToWifi:
        case PADProvisioningStepConnectionFailed: {
            self.provisioningState.currentStep = PADProvisioningStepConnecting;
            [self updateViewForCurrentStep];

            // If device is reachable, then connection is successful.
            __weak typeof(self) weakSelf = self;
            [PADDeviceReachabilityManager deviceReachabilityStatusWithCompletionBlock:^(DeviceStatus deviceStatus) {
                if (deviceStatus == PADDeviceStatusReachable) {
                    weakSelf.provisioningState.currentStep = PADProvisioningStepConnected;
                } else {
                    weakSelf.provisioningState.currentStep = PADProvisioningStepConnectionFailed;
                }

                [weakSelf updateViewForCurrentStep];
            }];
            break;
        }
        case PADProvisioningStepReconnectingFailed: {
            self.provisioningState.currentStep = PADProvisioningStepReconnecting;
            [self updateViewForCurrentStep];

            // If wifi is now reachable, finish provisioning. Otherwise, restart the wifi
            // reconnecting timeout timer.
            if (self.wifiReachabilityManager.currentNetworkStatus == PADNetworkStatusReachable) {
                [self finishProvisioning];
            } else {
                [self.wifiReconnectTimer startTimerWithTimeoutBlock:[self reconnectingTimeoutBlock]];
            }
            break;
        }
        default:
            // No action required when the app is foregrounded during any other step.
            break;
    }
}

/*!
 @abstract Finishes the provisioning process by waiting for the device's provisioning event.

 @discussion If the user wanted to save the wifi network credentials, this is also done here.
 */
- (void)finishProvisioning {
    // Network has reconnected successfully at this point - reachability monitoring can be stopped.
    [self tearDownWifiReachability];

    if (self.provisioningState.shouldSaveWifiCredentials) {
        [self.provisioningState.wifiCredentials saveInBackground];
    }

    [self waitForResponseFromDevice];
}

/*!
 @abstract Starts waiting for the provisioning success event from the device.

 @discussion The provisioning event may not be immediately available. Waiting will fail if the
 event is not received after a pre-defined timeout period.
 */
- (void)waitForResponseFromDevice {
    self.provisioningState.currentStep = PADProvisioningStepWaitingForEvent;
    [self updateViewForCurrentStep];

    __weak typeof(self) weakSelf = self;
    [self.eventManager waitForResponseFromDeviceWithSuccess:^{
        [weakSelf.delegate finishProvisioningWithCancelConfirmation:NO deleteDevice:NO];
    } failure:^{
        weakSelf.provisioningState.currentStep = PADProvisioningStepEventFailed;
        [weakSelf updateViewForCurrentStep];
    }];
}

/*!
 @abstract Shows an error alert with an action for navigating to the Settings application.

 @discussion The alert can also optionally include a `Try Again` action, which is used when
 initial provisioning has failed and this alert is displayed.

 @param title             Title for the alert.
 @param message           Message to be displayed on the alert.
 @param hasTryAgainAction Boolean describing whether or not a 'Try Again' action is to be displayed.
 */
- (void)showGoToSettingsAlertWithTitle:(NSString *)title
                               message:(NSString *)message
                     hasTryAgainAction:(BOOL)hasTryAgainAction
{
    NSString *goToSettingsTitle = NSLocalizedString(@"Go to Settings", nil);
    UIAlertAction *goToSettingsAction = [UIAlertAction actionWithTitle:goToSettingsTitle
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
        NSURL *settingsUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsUrl];
    }];

    __weak typeof(self) weakSelf = self;
    NSString *cancelTitle = NSLocalizedString(@"Back to Device List", nil);
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
        [weakSelf.delegate finishProvisioningWithCancelConfirmation:NO deleteDevice:YES];
    }];

    NSArray *actions;
    if (hasTryAgainAction) {
        NSString *tryAgainTitle = NSLocalizedString(@"Try Again", nil);
        UIAlertAction *tryAgainAction = [UIAlertAction actionWithTitle:tryAgainTitle
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action) {
            [weakSelf provisionNewDevice];
        }];

        actions = @[goToSettingsAction, tryAgainAction, cancelAction];

    } else {
        actions = @[cancelAction, goToSettingsAction];
    }

    // Keep a reference to the alert in case we need to manually dismiss it in the future.
    self.currentAlertController = [PADAlertUtilities showActionAlertWithTitle:title
                                                                      message:message
                                                                 alertActions:actions
                                                         presentingController:self];
}

/*!
 @abstract Updates the user interface elements based on the current provisioning step.

 @discussion This method is called every time a new provisioning step that re-uses this view
 controller's interface begins.
 */
- (void)updateViewForCurrentStep {
    self.stepButton.backgroundColor = [UIColor provisioningFlowButtonEnabledBackgroundColor];
    self.stepButton.layer.cornerRadius = 4;

    switch (self.provisioningState.currentStep) {
        case PADProvisioningStepInitialProvision:
            self.stepIconImageView.hidden = YES;
            self.stepButton.hidden = YES;
            [self.loadingIndicator startAnimating];

            self.stepNameLabel.text = NSLocalizedString(@"Communicating with Cloud",
                                                        @"Loading title - provisioning initialization");

            self.stepDescriptionLabel.text = NSLocalizedString(@"Please wait one moment for setup to initialize.",
                                                               @"Loading message - provisioning initialization");

            break;
        case PADProvisioningStepInitialProvisionConnectedToBoard: {
            NSString *message = NSLocalizedString(@"You are still connected to the device's network. " \
                                                   "Please go to Settings > Wi-Fi and select a different network. ",
                                                  @"Connected to board error - provisioning initialization");

            [self showGoToSettingsAlertWithTitle:NSLocalizedString(@"Network Connection Error", @"Offline error title")
                                         message:message
                               hasTryAgainAction:NO];

            break;
        }
        case PADProvisioningStepInitialProvisionFailed: {
            NSString *message = NSLocalizedString(@"There seems to be an issue communicating with the cloud. " \
                                                   "Check your internet connection in Settings > Wi-Fi and try again.",
                                                  @"Provisioning initialization failed message");

            NSString *title = NSLocalizedString(@"Network Connection Error", @"Offline error title");
            [self showGoToSettingsAlertWithTitle:title
                                         message:message
                               hasTryAgainAction:YES];

            break;
        }
        case PADProvisioningStepGoToWifi:
            self.stepIconImageView.hidden = NO;
            self.stepButton.hidden = NO;
            [self.loadingIndicator stopAnimating];

            self.stepIconImageView.image = [UIImage imageNamed:@"connect_icon"];
            self.stepNameLabel.text = NSLocalizedString(@"Connect to Your Device", @"Title - connect to the board");
            self.stepDescriptionLabel.text = NSLocalizedString(@"To provision a device you must connect it through Wi-Fi first. " \
                                                                "Go to Settings > Wi-Fi and connect to the device",
                                                               @"Message - connect to board");

            [self.stepButton setTitle:NSLocalizedString(@"Go to Settings", nil)
                             forState:UIControlStateNormal];

            break;
        case PADProvisioningStepConnecting:
            self.stepIconImageView.hidden = YES;
            self.stepButton.hidden = YES;
            [self.loadingIndicator startAnimating];

            self.stepNameLabel.text = NSLocalizedString(@"Verifying Device",
                                                        @"Loading title - connecting to device");

            self.stepDescriptionLabel.text = NSLocalizedString(@"One moment please...",
                                                               @"Loading message - generic");

            break;
        case PADProvisioningStepConnectionFailed: {
            NSString *message = NSLocalizedString(@"There seems to be an issue connecting to the selected device. " \
                                                   "Go to Settings > Wi-Fi and review the device connection. " \
                                                   "Then return to the app to continue.",
                                                  @"Error message - connection failed");

            NSString *title = NSLocalizedString(@"Device Connection Error",
                                                @"Error title - connection failed");

            [self showGoToSettingsAlertWithTitle:title
                                         message:message
                               hasTryAgainAction:NO];

            break;
        }
        case PADProvisioningStepConnected:
            self.stepIconImageView.hidden = NO;
            self.stepButton.hidden = NO;
            [self.loadingIndicator stopAnimating];

            self.stepIconImageView.image = [UIImage imageNamed:@"success_icon"];
            self.stepNameLabel.text = NSLocalizedString(@"Successfully Connected", @"Success title - connected");
            self.stepDescriptionLabel.text = NSLocalizedString(@"You've successfully connected to your device. " \
                                                               "Please continue to the next step.",
                                                               @"Success message - connected");

            [self.stepButton setTitle:NSLocalizedString(@"Continue", nil)
                             forState:UIControlStateNormal];

            break;
        case PADProvisioningStepDisconnecting:
            self.stepIconImageView.hidden = YES;
            self.stepButton.hidden = YES;
            [self.loadingIndicator startAnimating];

            self.stepNameLabel.text = NSLocalizedString(@"Disconnecting from Board",
                                                        @"Loading title - disconnecting");

            self.stepDescriptionLabel.text = NSLocalizedString(@"One moment please...",
                                                               @"Loading message - generic");

            break;
        case PADProvisioningStepReconnecting:
            self.stepIconImageView.hidden = YES;
            self.stepButton.hidden = YES;
            [self.loadingIndicator startAnimating];

            self.stepNameLabel.text = NSLocalizedString(@"Reconnecting to Network",
                                                        @"Loading title - reconnecting");

            self.stepDescriptionLabel.text = NSLocalizedString(@"One moment please...",
                                                               @"Loading message - generic");

            break;
        case PADProvisioningStepReconnectingFailed: {
            NSString *message = NSLocalizedString(@"There was an issue reconnecting to the network. " \
                                                   "Please go to Settings > Wi-Fi and ensure that you are connected.",
                                                  @"Error message - reconnecting failed");

            NSString *title = NSLocalizedString(@"Network Connection Error", @"Offline error title");
            [self showGoToSettingsAlertWithTitle:title
                                         message:message
                               hasTryAgainAction:NO];

            break;
        }
        case PADProvisioningStepWaitingForEvent:
            self.stepIconImageView.hidden = YES;
            self.stepButton.hidden = YES;
            [self.loadingIndicator startAnimating];

            self.stepNameLabel.text = NSLocalizedString(@"Waiting for Response from Device",
                                                        @"Loading title - waiting for response");

            self.stepDescriptionLabel.text = NSLocalizedString(@"One moment please...",
                                                               @"Loading message - generic");

            break;
        case PADProvisioningStepEventFailed:
            self.stepIconImageView.hidden = NO;
            self.stepButton.hidden = NO;
            [self.loadingIndicator stopAnimating];

            self.stepIconImageView.image = [UIImage imageNamed:@"error_icon"];
            self.stepNameLabel.text = NSLocalizedString(@"Failed to receive Response from Device",
                                                        @"Error title - failed to receive response");

            self.stepDescriptionLabel.text = NSLocalizedString(@"There was an issue communicating with the device.",
                                                               @"Error message - failed to receive response");

            [self.stepButton setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

@end
