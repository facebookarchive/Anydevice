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

/*!
 `PADHomeViewController` displays the list of connected devices that the currently logged
 in user has provisioned. This is the root screen of the application for a logged in user, from
 which the user can add a new device, see details for an existing device, and log out.
 */
@interface PADHomeViewController : UIViewController

/*!
 @abstract Outlet to the empty devices view.

 @discussion If the user doesn't have any provisioned devices, we show this view to
 communicate that there are no devices. Otherwise, this view is hidden.
 */
@property (nonatomic, weak) IBOutlet UIView *noDevicesView;

/*!
 @abstract Outlet to collection view that displays provisioned devices.
 */
@property (nonatomic, weak) IBOutlet UICollectionView *provisionedDevicesCollectionView;

/*!
 @abstract Loading indicator UI element.

 @discussion Displayed above the devices list when the devices are being fetched from the
 server.
 */
@property (nonatomic, strong) UIRefreshControl *refreshIndicator;

/*!
 @abstract Navigates to the device details screen for the given installation in response to an
 event.

 @param installationId Unique identifier for a device's installation.
 @param event          Event from the device that was received via a push notification.
 */
- (void)navigateToDeviceDetailsForInstallationId:(NSString *)installationId
                                       withEvent:(PADEvent *)event;

@end
