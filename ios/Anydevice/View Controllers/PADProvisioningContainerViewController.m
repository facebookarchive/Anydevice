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

#import "PADProvisioningContainerViewController.h"

#import "PADAlertUtilities.h"
#import "PADMainProvisioningFlowViewController.h"
#import "PADNetworkUtilities.h"
#import "PADProvisioningProtocols.h"
#import "PADProvisioningState.h"
#import "PADStoryboardConstants.h"
#import "PADUserSession.h"
#import "PADUtilities.h"

@interface PADProvisioningContainerViewController () <ProvisioningStepDelegate>

/*!
 @abstract <PADProvisioningState> object containing information about the provisioning process so far.

 @see PADProvisioningState.h
 */
@property (nonatomic, strong) PADProvisioningState *provisioningState;

/*!
 @abstract The alert view controller which takes user confirmation before canceling the provisioning
 flow.
 */
@property (nonatomic, weak) UIAlertController *cancelAlertController;

@end

@implementation PADProvisioningContainerViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Add Device", nil);
    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    [self.navigationController.navigationBar setTitleTextAttributes:titleAttributes];

    self.provisioningState = [[PADProvisioningState alloc] init];
    self.provisioningState.currentStep = PADProvisioningStepInitialProvision;

    // Perform a segue to embed the view controller which handles the beginning of the provisioning
    // flow.
    [self performSegueWithIdentifier:PADEmbedProvisioningFlowSegue sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Pass along the provisioning state and set up parent-child relationship reference.
    UIViewController<ProvisioningContainerChild> *childViewController = segue.destinationViewController;
    childViewController.provisioningState = self.provisioningState;
    childViewController.delegate = self;
}

#pragma mark - Actions

- (IBAction)cancelButtonTapped:(id)sender {
    [self finishProvisioningWithCancelConfirmation:YES deleteDevice:YES];
}

#pragma mark - ProvisioningStepDelegate

- (void)finishProvisioningWithCancelConfirmation:(BOOL)confirmation
                                    deleteDevice:(BOOL)deleteDevice
{
    // If no confirmation of cancellation is necessary, just cancel immediately and return.
    if (!confirmation) {
        [self cancelProvisioningFlowAndDeleteDevice:deleteDevice];
        return;
    }

    NSString *cancelMessage = NSLocalizedString(@"You have not completed adding your device. " \
                                                "Are you sure you would like to leave?",
                                                @"Confirm message - cancelling provisioning");

    UIAlertAction *leaveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *action) {
        [self cancelProvisioningFlowAndDeleteDevice:deleteDevice];
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];

    NSString *title = NSLocalizedString(@"Cancel Provisioning?",
                                        @"Title - cancelling provisioning");

    [PADAlertUtilities showActionAlertWithTitle:title
                                        message:cancelMessage
                                   alertActions:@[cancelAction, leaveAction]
                           presentingController:self];
}

- (void)swapViewControllerForCurrentStep {
    if (self.provisioningState.currentStep == PADProvisioningStepConfirmDevice) {
        // Get the device access point's SSID.
        NSDictionary *deviceAccessPointInfo = [PADNetworkUtilities currentNetworkInformation];
        NSString *SSIDKey = (__bridge NSString *)kCNNetworkInfoKeySSID;
        NSString *deviceSSID = [deviceAccessPointInfo objectForKey:SSIDKey];

        // Set the model identifier by parsing it out of the device access point's SSID.
        self.provisioningState.modelIdentifier = [PADUtilities modelIdentiferFromSSID:deviceSSID];

        // Perform a segue to embed the <PADConfirmProvisioningDetailsViewController>.
        [self performSegueWithIdentifier:PADEmbedConfirmDeviceSegue sender:nil];

    } else if (self.provisioningState.currentStep == PADProvisioningStepDisconnecting) {
        // Perform a segue to embed the <PADMainProvisioningFlowViewController>.
        [self performSegueWithIdentifier:PADEmbedProvisioningFlowSegue sender:nil];
    }
}

- (void)provisioningFlowFinished {
    [self.cancelAlertController dismissViewControllerAnimated:NO completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private

/*!
 @abstract Cancels the provisioning flow with an option to delete the device that has been
 provisioned so far.

 @discussion Deleting the device will remove the device's <PADUserSession> and <PADInstallation>
 objects from the Parse cloud.

 @param deleteDevice Boolean describing whether to delete the device or not.
 */
- (void)cancelProvisioningFlowAndDeleteDevice:(BOOL)deleteDevice {
    if (deleteDevice) {
        [self.provisioningState.userSession deleteEventually];
    }

    [self provisioningFlowFinished];
}

@end
