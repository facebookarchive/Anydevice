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

#import "PADDeviceDetailsViewController.h"

#import <Parse/Parse.h>

#import "PADAlertUtilities.h"
#import "PADDeviceActivityUtilities.h"
#import "PADDeviceStateCell.h"
#import "PADDeviceStateUtilities.h"
#import "PADEvent.h"
#import "PADEventsService.h"
#import "PADInstallation.h"
#import "PADLoadingIndicatorController.h"
#import "PADMessageService.h"
#import "PADModel.h"
#import "PADProvisioningService.h"
#import "PADTimer.h"
#import "PADUserSession.h"
#import "PADUtilities.h"

static const NSTimeInterval kMessageTimeout = 30.0f;
static const NSInteger kWarningViewHeight = 33;

@interface PADDeviceDetailsViewController () <UITableViewDataSource, UITableViewDelegate>

/*!
 @abstract The table view cell that corresponds to the most recently known LED state of the device.
 */
@property (nonatomic, strong) PADDeviceStateCell *selectedDeviceStateCell;

/*!
 @abstract The table view cell that corresponds to the LED state change message currently being sent
 to the device.
 */
@property (nonatomic, strong) PADDeviceStateCell *loadingDeviceStateCell;

/*!
 @abstract Timer that controls the timeout interval for LED state change messages.

 @see PADTimer.h
 */
@property (nonatomic, strong) PADTimer *messageTimeoutTimer;

/*!
 @abstract The user session for the provisioned device.

 @see PADUserSession.h
 */
@property (nonatomic, strong) PADUserSession *userSession;

@end

@implementation PADDeviceDetailsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Anydevice", @"App name");

    [self setupSubviews];
    [self fetchModelIcon];
    [self fetchUserSession];
    [self updateCurrentDeviceState];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // Stop the message timeout timer when the user is leaving the screen.
    [self.messageTimeoutTimer stopTimer];
}

#pragma mark - Public

- (void)setLatestEvent:(PADEvent *)latestEvent {
    // Stop the timer since an event just came in.
    [self.messageTimeoutTimer stopTimer];

    // No need for any UI updates if we already have the latest event.
    if ([self.latestEvent.objectId isEqualToString:latestEvent.objectId]) {
        return;
    }

    self.installation.latestEvent = latestEvent;
    [self updateCurrentDeviceState];
}

- (PADEvent *)latestEvent {
    return self.installation.latestEvent;
}

#pragma mark - Private

- (void)setupSubviews {
    UIImage *deleteImage = [UIImage imageNamed:@"delete"];
    self.deleteButton.image = [deleteImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    [self updateDeviceActivityBanner];

    // Make the icon image view circular using rounded corners and clipsToBounds.
    self.deviceIconImageView.layer.cornerRadius = self.deviceIconImageView.frame.size.height / 2;
    self.deviceIconImageView.clipsToBounds = YES;

    self.deviceNameLabel.text = self.installation.deviceName;
    self.modelNameLabel.text = self.installation.model.boardType;
    [self updateLastSeenTime];

    NSString *deviceStateCellReuseIdentifier = NSStringFromClass([PADDeviceStateCell class]);
    UINib *cellNib = [UINib nibWithNibName:deviceStateCellReuseIdentifier bundle:nil];
    [self.deviceStateTableView registerNib:cellNib
                    forCellReuseIdentifier:deviceStateCellReuseIdentifier];

    self.deviceStateTableView.dataSource = self;
    self.deviceStateTableView.delegate = self;
    self.deviceStateTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

/*!
 @abstract Fetches the icon associated with the model of the device.
 */
- (void)fetchModelIcon {
    PFFile *iconFile = self.installation.model.icon;

    __weak typeof(self) weakSelf = self;
    [iconFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if (!error) {
            [weakSelf.deviceIconImageView setImage:[UIImage imageWithData:data]];
        }
    }];
}

- (void)fetchUserSession {
    __weak typeof(self) weakSelf = self;
    [PADProvisioningService fetchUserSessionForInstallation:self.installation
                                                    success:^(PADUserSession *userSession) {
        weakSelf.userSession = userSession;
        weakSelf.deleteButton.enabled = YES;
        [weakSelf updateCurrentDeviceState];
    } failure:nil];
}

/*!
 @abstract Update the top banner with a warning message.

 @discussion Specific warning messages will show if the device has not provisioned successfully or
 if the device has not been active in three days. If the device is active and has no known issues,
 the top banner view will be hidden, as its default height is 0.
 */
- (void)updateDeviceActivityBanner {
    DeviceActivityState activityState = [PADDeviceActivityUtilities activityStateForInstallation:self.installation];
    NSString *warningMessage = [PADDeviceActivityUtilities warningForActivityState:activityState];
    if (warningMessage) {
        self.warningLabel.text = warningMessage;

        // Show the banner view by giving it an appropriate height.
        self.warningViewHeightConstraint.constant = kWarningViewHeight;
    }
}

/*!
 @abstract Updates the device details user interface based on the most recent event sent from the
 device.

 @discussion Based on the most recent event, the last seen time and the current LED state of the
 device are updated.
 */
- (void)updateCurrentDeviceState {
    if (!self.latestEvent) {
        return;
    }

    [self updateLastSeenTime];

    NSString *deviceStateString = [PADDeviceStateUtilities deviceStateFromBlinkEvent:self.latestEvent];
    DeviceState deviceState = [PADDeviceStateUtilities deviceStateFromDeviceStateString:deviceStateString];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:deviceState inSection:0];

    // Deselect the cell corresponding to the old LED state.
    self.selectedDeviceStateCell.cellSelected = NO;

    // Retrieve the cell corresponding to the new LED state and set it as the selected cell.
    self.selectedDeviceStateCell = (PADDeviceStateCell *)[self.deviceStateTableView cellForRowAtIndexPath:indexPath];
    self.selectedDeviceStateCell.cellSelected = YES;

    // Remove the loading spinner corresponding to the sent message.
    [self clearMessageLoadingIndicator];
}

/*!
 @abstract Updates the last seen time of the device based on the most recent event.

 @discussion The creation time of the latest event is always used if the device has sent at least
 one event. Otherwise, the user session update time is used as a fallback.
 */
- (void)updateLastSeenTime {
    NSString *lastSeenString = NSLocalizedString(@"Seen: %@", @"Most recent date a device was seen");

    // If no event has been received for this device, default to the user session updated time.
    NSDate *lastSeenDate = self.latestEvent ? self.latestEvent.createdAt : self.userSession.updatedAt;
    lastSeenString = [NSString stringWithFormat:lastSeenString, [PADUtilities stringFromDate:lastSeenDate]];

    self.lastSeenTimeLabel.text = lastSeenString;
}

/*!
 @abstract Starts a timeout timer that waits for a new LED state event to be received from the
 device in response to an LED state change message.

 @discussion If no event is received within 30 seconds (configurable in the constant
 `kMessageTimeout`), then an alert is displayed with an error message.
 */
- (void)startMessageTimeoutTimer {
    self.messageTimeoutTimer = [[PADTimer alloc] initWithTimeout:kMessageTimeout repeats:NO];

    __weak typeof(self) weakSelf = self;
    [self.messageTimeoutTimer startTimerWithTimeoutBlock:^{
        [weakSelf clearMessageLoadingIndicator];

        NSString *alertTitle = NSLocalizedString(@"Message Timed Out",
                                                 @"Error title when message fails to send");

        NSString *alertMessage = NSLocalizedString(@"The device failed to acknowledge the state change.",
                                                   @"Error message for failure to receive ack event");

        [PADAlertUtilities showAlertWithTitle:alertTitle
                                      message:alertMessage
                         presentingController:weakSelf];
    }];
}

- (void)clearMessageLoadingIndicator {
    self.loadingDeviceStateCell.loading = NO;
    self.loadingDeviceStateCell = nil;
}

#pragma mark - Actions

- (IBAction)deleteButtonTapped:(id)sender {
    // Show a confirmation alert before deleting the device

    NSString *alertMessage = NSLocalizedString(@"Are you sure you would like to remove this device?",
                                               @"Message to confirm device deletion");

    [PADAlertUtilities showConfirmationActionSheetWithTitle:nil
                                                    message:alertMessage
                                          actionButtonTitle:NSLocalizedString(@"Remove", nil)
                                       presentingController:self
                                            completionBlock:^{
        NSString *loadingTitle = NSLocalizedString(@"Removing Device...", nil);
        PADLoadingIndicatorController *loadingIndicator = [PADLoadingIndicatorController loadingControllerWithMessage:loadingTitle];
        [loadingIndicator show];

        [PADProvisioningService deleteDeviceWithUserSession:self.userSession success:^{
            [loadingIndicator hide];
            [self.navigationController popViewControllerAnimated:YES];

        } failure:^(NSError *error) {
            [loadingIndicator hide];
            NSString *alertTitle = NSLocalizedString(@"Delete Failed",
                                                     @"Error title for delete failure");

            [PADAlertUtilities showErrorAlertWithTitle:alertTitle
                                                 error:error
                                  presentingController:self];
        }];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return DeviceStateCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = NSStringFromClass([PADDeviceStateCell class]);
    PADDeviceStateCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier
                                                            forIndexPath:indexPath];

    NSString *messageTitle = [PADDeviceStateUtilities messageTitleForDeviceState:indexPath.row];
    SeparatorStyle separatorStyle = SeparatorStyleTop;
    if (indexPath.row == DeviceStateCount - 1) {
        separatorStyle |= SeparatorStyleBottom;
    }

    [cell setupWithMessageTitle:messageTitle separatorStyle:separatorStyle];
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView
  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Prevent attempts to change the LED state to the existing state.
    BOOL selected = [[tableView indexPathForCell:self.selectedDeviceStateCell] isEqual:indexPath];

    // Prevent attempts to send a message if there is already one in flight.
    BOOL loading = (self.loadingDeviceStateCell != nil);
    BOOL allowSelection = !(selected || loading);

    NSIndexPath *selectedIndexPath = allowSelection ? indexPath : nil;
    return selectedIndexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Show a loading spinner on the cell that corresponds to the LED state change message being
    // sent.
    self.loadingDeviceStateCell = (PADDeviceStateCell *)[tableView cellForRowAtIndexPath:indexPath];
    self.loadingDeviceStateCell.loading = YES;

    DeviceState selectedMessage = indexPath.row;
    [PADMessageService sendDeviceState:selectedMessage toInstallation:self.installation success:^{
        // If the user has allowed push notifications, message success is determined when a response
        // event is sent by the device.
        if ([PADEventsService isRegisteredForEvents]) {
            [self startMessageTimeoutTimer];
            return;
        }

        // Deselect the cell corresponding to the old LED state.
        self.selectedDeviceStateCell.cellSelected = NO;

        // Set the cell corresponding to the new LED state as the selected cell.
        self.selectedDeviceStateCell = self.loadingDeviceStateCell;
        self.selectedDeviceStateCell.cellSelected = YES;

        // There is no longer any message in flight, so the loading cell should be cleared.
        [self clearMessageLoadingIndicator];

    } failure:^(NSError *error) {
        [self clearMessageLoadingIndicator];
        NSString *alertTitle = NSLocalizedString(@"Message Failed",
                                                 @"Error title for failure to send message");

        [PADAlertUtilities showErrorAlertWithTitle:alertTitle
                                             error:error
                              presentingController:self];
    }];
}

@end
