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

@class PADEvent;
@class PADInstallation;

/*!
 `PADDeviceDetailsViewController` displays for the details of a single device from the user's list
 of provisioned devices. The details include the device name, device model, current LED state, and
 last seen date of the provisioned device. It also provides interface that allows the user to send
 LED state changes to the device.
 */
@interface PADDeviceDetailsViewController : UIViewController

/*!
 @abstract Outlet to the bar button which lets the user delete a provisioned device.
 */
@property (nonatomic, weak) IBOutlet UIBarButtonItem *deleteButton;

/*!
 @abstract Outlet to the image view which displays the device icon.
 */
@property (nonatomic, weak) IBOutlet UIImageView *deviceIconImageView;

/*!
 @abstract Outlet to the label which shows the name of the device.
 */
@property (nonatomic, weak) IBOutlet UILabel *deviceNameLabel;

/*!
 @abstract Outlet to the label which shows the model of the device.
 */
@property (nonatomic, weak) IBOutlet UILabel *modelNameLabel;
/*!
 @abstract Outlet to the label which shows the last time the device was seen.
 */
@property (nonatomic, weak) IBOutlet UILabel *lastSeenTimeLabel;

/*!
 @abstract Outlet to the table view which lists LED state change options for the device.
 */
@property (nonatomic, weak) IBOutlet UITableView *deviceStateTableView;

/*!
 @abstract Outlet to the label which displays a warning if the device has not provisioned
 successfully or if the device has not been active in three days.
 */
@property (nonatomic, weak) IBOutlet UILabel *warningLabel;

/*!
 @abstract Outlet to the constraint which holds the height of the warning view.
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *warningViewHeightConstraint;

/*!
 @abstract The event which was most recently sent from the provisioned device.

 @see PADEvent.h
 */
@property (nonatomic, strong) PADEvent *latestEvent;

/*!
 @abstract The installation for the provisioned device.

 @see PADInstallation.h
 */
@property (nonatomic, strong) PADInstallation *installation;

@end
