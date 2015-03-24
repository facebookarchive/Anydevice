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
 `PADMainProvisioningFlowViewController` manages many of the steps involved in the provisioning of a
 new device. Many of the provisioning steps re-use the user interface that is presented and managed
 by this view controller, so this view controller is responsible for transitioning between these
 steps and updating the user interface accordingly.

 `PADMainProvisioningFlowViewController` is a child view controller of
 <PADProvisioningContainerViewController>. If a provisioning step requires a completely different
 interface, this view controller can trigger a view controller swap by sending a message to the
 parent provisioning controller using the <ProvisioningStepDelegate> delegate.
 */
@interface PADMainProvisioningFlowViewController : UIViewController <ProvisioningContainerChild>

/*!
 @abstract Outlet to the loading indicator view.
 */
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIndicator;

/*!
 @abstract Outlet to the image view which displays an icon for the current step.
 */
@property (nonatomic, weak) IBOutlet UIImageView *stepIconImageView;

/*!
 @abstract Outlet to the label which shows the name of the current step.
 */
@property (nonatomic, weak) IBOutlet UILabel *stepNameLabel;

/*!
 @abstract Outlet to the label which shows the description of the current step.
 */
@property (nonatomic, weak) IBOutlet UILabel *stepDescriptionLabel;

/*!
 @abstract Outlet to the button which performs action required for the current step.
 */
@property (nonatomic, weak) IBOutlet UIButton *stepButton;

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
