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

#ifndef PADProvisioningProtocols_h
#define PADProvisioningProtocols_h

@class PADProvisioningState;

/*!
 The `ProvisioningStepDelegate` protocol defines the methods required for handling the change/
 completion of provisioning steps, and for handling the completion/cancellation of the entire
 provisioning flow.
 */
@protocol ProvisioningStepDelegate <NSObject>

/*!
 @abstract Instantiates and displays the child view controller that correctly handles the current
 provisioning step.
 */
- (void)swapViewControllerForCurrentStep;

/*!
 @abstract Handles clean up and dismissal of the provisioning flow.
 */
- (void)provisioningFlowFinished;

/*!
 @abstract Handles completion of the provisioning flow.

 @discussion This includes the option to display a provisioning cancellation alert and the option to
 delete the device that has been created and provisioned so far.

 @param confirmation Boolean that determines whether or not a confirmation alert should be
 presented.

 @param deleteDevice Boolean that determines whether or not the device created so far should be
 deleted.
 */
- (void)finishProvisioningWithCancelConfirmation:(BOOL)confirmation
                                    deleteDevice:(BOOL)deleteDevice;

@end

/*!
 The `ProvisioningContainerChild` protocol defines the properties required by a view controller that
 will be embedded in <PADProvisioningContainerViewController> as a child view controller in order to
 manage one or many steps in the provisioning flow.
 */
@protocol ProvisioningContainerChild <NSObject>

/*!
 @abstract <PADProvisioningState> object containing information about the provisioning process so far.

 @see PADProvisioningState.h
 */
@property (nonatomic, strong) PADProvisioningState *provisioningState;

/*!
 @abstract Delegate that responds to the change/completion of provisioning steps. This should be a
 reference to <PADProvisioningContainerViewController>.

 @see PADProvisioningProtocols.h
 */
@property (nonatomic, weak) id<ProvisioningStepDelegate> delegate;

@end

#endif
