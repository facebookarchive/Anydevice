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

/*!
 `PADProvisioningContainerViewController` manages the entire flow for provisioning a new device. It
 acts as a container for child view controllers that handle the logic and user interface for a
 given provisioning step. Each child view controller maintains a reference to this view controller
 using the <ProvisioningStepDelegate> protocol. This parent view controller implements the protocol,
 which provides methods to swap between child view controllers and finish provisioning. All child
 view controllers being embedded within this view controller to handle a provisioning step must
 implement the <ProvisioningContainerChild> protocol in order to setup this relationship and access
 the provisioning state information.

 For example, the <PADMainProvisioningFlowViewController> handles all initial steps up to the
 details confirmation step. At this step, the <PADMainProvisioningFlowViewController> informs this
 view controller that it should transition to another view controller for the next step, and this
 view controller instantiates and displays the <PADConfirmProvisioningDetailsViewController> as its
 new child view controller.

 @see PADProvisioningProtocols.h
 */
@interface PADProvisioningContainerViewController : UIViewController

@end
