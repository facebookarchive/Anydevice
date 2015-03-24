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

#import "PADConfirmProvisioningDetailsViewController.h"

#import <Parse/Parse.h>

#import "PADDeviceService.h"
#import "PADInfrastructureKey.h"
#import "PADInstallation.h"
#import "PADModel.h"
#import "PADNetworkUtilities.h"
#import "PADPickerAccessoryView.h"
#import "PADProvisioningDetailsFooterView.h"
#import "PADProvisioningService.h"
#import "PADProvisioningState.h"
#import "PADReachability.h"

static const CGFloat kDoneFooterHeight = 100.0f;
static const CGFloat kTableRowHeight = 45.0f;
static const CGFloat kPickerComponentHeight = 35.0f;

// Enumeration of the table view sections.
typedef NS_ENUM(NSInteger, TableViewSection) {
    TableViewSectionDeviceName = 0,
    TableViewSectionNetworkInfo,
    TableViewSectionSavePassword,
    TableViewSectionCount
};

@interface PADConfirmProvisioningDetailsViewController () <PADProvisioningDetailsFooterViewDelegate,
UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, PADPickerAccessoryViewDelegate>

/*!
 @abstract The footer view that is displayed on the table view.
 */
@property (nonatomic, strong) PADProvisioningDetailsFooterView *footerView;

/*!
 @abstract Picker view that allows the user to populate the security type field.
 */
@property (nonatomic, strong) UIPickerView *securityPickerView;

/*!
 @abstract Security type picker accessory that allows navigation between fields.
 */
@property (nonatomic, strong) PADPickerAccessoryView *pickerAccessoryView;

/*!
 @abstract Currently selected security type.
 */
@property (nonatomic, assign) SecurityType currentSecurityType;

@end

@implementation PADConfirmProvisioningDetailsViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set the initial security type based on the pre-populated network information, if any.
    SecurityType savedSecurityType = [self.provisioningState.wifiCredentials.security integerValue];
    self.currentSecurityType = savedSecurityType;

    [self setupLabels];
    [self setupTextFields];
    [self setupSavePasswordSwitch];
}

#pragma mark - Actions

- (IBAction)tapToDismissKeyboard:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - Private

- (void)setupLabels {
    self.networkLabel.text = NSLocalizedString(@"Network", nil);
    self.securityLabel.text = NSLocalizedString(@"Security", nil);
    self.passwordLabel.text = NSLocalizedString(@"Password", nil);
    self.savePasswordLabel.text = NSLocalizedString(@"Save Password", nil);
}

- (void)setupTextFields {
    // Setup text field delegates. This enables automatic movement between text fields when the
    // return key on the keyboard is tapped.
    self.deviceNameTextField.delegate = self;
    self.networkTextField.delegate = self;
    self.passwordTextField.delegate = self;
    self.securityTextField.delegate = self;

    // Use a custom picker view for the security type instead of the keyboard.
    self.securityTextField.inputView = self.securityPickerView;
    self.securityTextField.inputAccessoryView = self.pickerAccessoryView;

    // Pre-populate network fields with saved network credentials if there are any.
    self.networkTextField.text = self.provisioningState.wifiCredentials.ssid;
    self.passwordTextField.text = self.provisioningState.wifiCredentials.key;
    SecurityType savedSecurityType = [self.provisioningState.wifiCredentials.security integerValue];
    self.securityTextField.text = [PADNetworkUtilities securityStringFromSecurityType:savedSecurityType];

    // Pre-populate the device name field with the default name.
    NSString *username = [PFUser currentUser].username;
    NSString *stringFormat = NSLocalizedString(@"%@-device", @"Default device name format");
    self.deviceNameTextField.text = [NSString stringWithFormat:stringFormat, username];

    // Validate text fields for each character entered so the Done button is enabled/disabled
    // accordingly.
    [self.deviceNameTextField addTarget:self
                                 action:@selector(validateFields)
                       forControlEvents:UIControlEventEditingChanged];

    [self.networkTextField addTarget:self
                              action:@selector(validateFields)
                    forControlEvents:UIControlEventEditingChanged];

    [self.securityTextField addTarget:self
                               action:@selector(validateFields)
                     forControlEvents:UIControlEventEditingChanged];

    [self.passwordTextField addTarget:self
                               action:@selector(validateFields)
                     forControlEvents:UIControlEventEditingChanged];

    [self validateFields];
}

- (void)setupSavePasswordSwitch {
    // Load the previous state of the password switch for the current user. Defaults to off.

    NSString *userId = [PFUser currentUser].objectId;
    BOOL previousSwitchState = [[NSUserDefaults standardUserDefaults] boolForKey:userId];
    self.savePasswordSwitch.on = previousSwitchState;
}

- (void)validateFields {
    // Only validate the password field if the current security type requires a password.
    BOOL passwordFieldValid = (self.currentSecurityType == SecurityTypeNone ||
                               [self.passwordTextField.text length]);

    // Only enable the done button when all the fields are non-empty.
    BOOL enableDoneButton = ([self.deviceNameTextField.text length] &&
                             [self.networkTextField.text length] &&
                             [self.securityTextField.text length] &&
                             passwordFieldValid);

    [self.footerView setDoneButtonEnabled:enableDoneButton];
}

- (PADProvisioningDetailsFooterView *)footerView {
    // Lazy instantiation of the table's footer view.

    if (!_footerView) {
        _footerView = [PADProvisioningDetailsFooterView footerViewWithDelegate:self];
    }

    return _footerView;
}

- (UIPickerView *)securityPickerView {
    // Lazy instantiation of the security type picker view.

    if (!_securityPickerView) {
        CGRect frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 100);
        _securityPickerView = [[UIPickerView alloc] initWithFrame:frame];
        _securityPickerView.delegate = self;
        _securityPickerView.dataSource = self;
    }

    return _securityPickerView;
}

- (PADPickerAccessoryView *)pickerAccessoryView {
    // Lazy instantiation of the accessory view for the security type picker.

    if (!_pickerAccessoryView) {
        _pickerAccessoryView = [PADPickerAccessoryView pickerAccessoryViewWithDelegate:self];
    }

    return _pickerAccessoryView;
}

#pragma mark - UITableViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // If password is not required for the current security type, hide the password section.
    if (self.currentSecurityType == SecurityTypeNone) {
        return TableViewSectionCount - 1;
    }

    return TableViewSectionCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case TableViewSectionDeviceName:
            return NSLocalizedString(@"Device Name", nil);
        case TableViewSectionNetworkInfo:
            return NSLocalizedString(@"Connect", nil);
        default:
            return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // If password is not required for the current security type, hide the password field.
    if (self.currentSecurityType == SecurityTypeNone &&
        indexPath.section == TableViewSectionNetworkInfo &&
        indexPath.row == 2)
    {
        return 0;
    }

    return kTableRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // If it's the last section in the table view, display the footer.
    if(section != [tableView numberOfSections] - 1) {
        return 0;
    }

    return kDoneFooterHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    // If it's the last section in the table view, display the footer.
    if(section != [tableView numberOfSections] - 1) {
        return nil;
    }

    return self.footerView;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return SecurityTypeCount;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return [PADNetworkUtilities securityStringFromSecurityType:row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return kPickerComponentHeight;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{
    self.securityTextField.text = [self pickerView:pickerView
                                       titleForRow:row
                                      forComponent:component];

    self.currentSecurityType = row;

    // Validate fields against the newly selected security type. Password requirement may have
    // changed.
    [self validateFields];

    // If a password is required by the current security type, change the accessory button label
    // accordingly. The form is finished if no password is required, otherwise the password field
    // becomes the next field.
    if (self.currentSecurityType == SecurityTypeNone) {
        [self.pickerAccessoryView setButtonTitle:NSLocalizedString(@"Done", nil)];
    } else {
        [self.pickerAccessoryView setButtonTitle:NSLocalizedString(@"Next", nil)];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    // If the security type has been switched to None in the security type picker, then the
    // password field shouldn't become editable since it will be hidden. Finish editing since the
    // security type is the last field when no password is required.
    if (textField == self.passwordTextField && self.currentSecurityType == SecurityTypeNone) {
        [self.view endEditing:YES];
        return NO;
    }

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // When editing the security type field, highlight the current security type in the picker view.
    if (textField == self.securityTextField) {
        [self.securityPickerView selectRow:self.currentSecurityType inComponent:0 animated:NO];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Automatically navigate to the next field in the form until the form is completed.
    // When the security field is the first responder, the field navigation is governed by the
    // security picker accessory view button instead of the keyboard return button.

    if (textField == self.deviceNameTextField) {
        [self.networkTextField becomeFirstResponder];
    } else if (textField == self.networkTextField) {
        [self.securityTextField becomeFirstResponder];
    } else if (textField == self.passwordTextField) {
        [self.view endEditing:YES];
    }

    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent pasting of text into the security type field.
    return !(textField == self.securityTextField);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // If the text field is not the security text field, do nothing.
    if (textField != self.securityTextField) {
        return;
    }

    // Select the row to make sure the picker is in sync with the current security type.
    [self.securityPickerView selectRow:self.currentSecurityType inComponent:0 animated:NO];

    // Reload the table view because the password requirement may have changed, and the password
    // section needs to be shown/hidden accordingly.
    [self.tableView reloadData];

    // Show the bottom separator view of the security type field if it is the last field in the
    // section (password field not showing).
    BOOL hideSeparator = (self.currentSecurityType != SecurityTypeNone);
    self.securityBottomSeparatorView.hidden = hideSeparator;

    // Since the number of sections and cells in the table changes based on whether a password is
    // required, we need to force an immediate layout so that the automatic scroll of the table view
    // works correctly.
    if (hideSeparator) {
        [self.tableView setNeedsLayout];
        [self.tableView layoutIfNeeded];
    }
}

#pragma mark - PADPickerAccessoryViewDelegate

- (void)pickerButtonTapped {
    // When the Done/Next button in the picker accessory view is tapped, depending on the current
    // security type, either the next field will be the password field or the keyboard will be
    // dismissed.
    if (self.currentSecurityType == SecurityTypeNone) {
        [self.view endEditing:YES];
    } else {
        [self.passwordTextField becomeFirstResponder];
    }
}

#pragma mark - PADProvisioningDetailsFooterViewDelegate

- (void)doneButtonTapped {
    NSString *networkName = self.networkTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *networkSSID = self.provisioningState.wifiCredentials.ssid;

    // You can only save the network credentials in the case that you were connected to that network
    // before connecting to the device.
    BOOL connectedToNetwork = [networkName isEqualToString:networkSSID];
    BOOL shouldSaveWifi = (self.savePasswordSwitch.isOn &&
                           self.currentSecurityType != SecurityTypeNone &&
                           connectedToNetwork);

    self.provisioningState.shouldSaveWifiCredentials = shouldSaveWifi;
    self.provisioningState.wifiCredentials.ssid = networkName;
    self.provisioningState.wifiCredentials.key = password;
    self.provisioningState.wifiCredentials.security = @(self.currentSecurityType);
    self.provisioningState.wifiCredentials.ACL = [PFACL ACLWithUser:[PFUser currentUser]];

    // Send data to connected device.
    NSString *deviceName = self.deviceNameTextField.text;
    [PADDeviceService postWifiCredentials:self.provisioningState.wifiCredentials
                            andDeviceName:deviceName
                            toUserSession:self.provisioningState.userSession];

    // Save the user's setting for the save password switch for next time this screen is loaded.
    [[NSUserDefaults standardUserDefaults] setBool:self.savePasswordSwitch.isOn
                                            forKey:[PFUser currentUser].objectId];

    // Update the provisioning flow step and swap to a different view controller that handles the
    // next step.
    self.provisioningState.currentStep = PADProvisioningStepDisconnecting;
    [self.delegate swapViewControllerForCurrentStep];
}

@end
