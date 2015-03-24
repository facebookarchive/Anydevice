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

#import <UIKit/UIKit.h>

#import "PADProvisioningProtocols.h"

/*!
 `PADConfirmProvisioningDetailsViewController` manages the entry and confirmation of the information
 necessary for provisioning a device. This information includes the name of the device, the network
 the device should connect to, and whether the network password should be saved and pre-populated in
 subsequent provisioning attempts. The network information includes network SSID, security type, and
 password if the security type requires one. Upon user confirmation, the information is sent to the
 connected device so it can attempt to provision.

 A portion of the information is pre-populated using the default device name and network
 information. When this view controller is displayed, it is assumed that the phone is connected to
 the device being provisioned and therefore has no internet connection.

 `PADConfirmProvisioningDetailsViewController` is a child view controller of
 <PADProvisioningContainerViewController>. Once the details confirmation step is complete, this view
 controller can trigger a swap to the next step's view controller by sending a message to the parent
 provisioning controller using the <ProvisioningStepDelegate> delegate.
 */
@interface PADConfirmProvisioningDetailsViewController : UITableViewController <ProvisioningContainerChild>

/*!
 @abstract Outlet to a label which describes the network SSID field.
 */
@property (nonatomic, weak) IBOutlet UILabel *networkLabel;

/*!
 @abstract Outlet to a label which describes the network security type field.
 */
@property (nonatomic, weak) IBOutlet UILabel *securityLabel;

/*!
 @abstract Outlet to a label which describes the network password field.
 */
@property (nonatomic, weak) IBOutlet UILabel *passwordLabel;

/*!
 @abstract Outlet to a label which describes the save password switch.
 */
@property (nonatomic, weak) IBOutlet UILabel *savePasswordLabel;

/*!
 @abstract Outlet to the text field which takes the device name input.
 */
@property (nonatomic, weak) IBOutlet UITextField *deviceNameTextField;

/*!
 @abstract Outlet to the text field which takes the network SSID input.
 */
@property (nonatomic, weak) IBOutlet UITextField *networkTextField;

/*!
 @abstract Outlet to the text field which takes the password input.
 */
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;

/*!
 @abstract Outlet to the text field which takes the security type input.
 */
@property (nonatomic, weak) IBOutlet UITextField *securityTextField;

/*!
 @abstract Outlet to the switch which takes input on whether password is to be saved or not.
 */
@property (nonatomic, weak) IBOutlet UISwitch *savePasswordSwitch;

/*!
 @abstract Outlet to the view which separates the save password section from the network section.
 */
@property (nonatomic, weak) IBOutlet UIView *securityBottomSeparatorView;

/*!
 @abstract <PADProvisioningState> object containing information about the provisioning process so
 far.

 @see PADProvisioningState.h
 */
@property (nonatomic, strong) PADProvisioningState *provisioningState;

/*!
 @abstract Delegate that responds to the change/completion of provisioning steps.

 @see PADProvisioningProtocols.h
 */
@property (nonatomic, weak) id<ProvisioningStepDelegate> delegate;

@end
