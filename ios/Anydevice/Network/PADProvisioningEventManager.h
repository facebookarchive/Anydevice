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

#import <Foundation/Foundation.h>

/*!
 `PADEventManagerCompletionBlock` is a block that takes no parameters.
 */
typedef void(^PADEventManagerCompletionBlock)();

/*!
 `PADProvisioningEventManager` manages waiting to receive the initial provisioning success event
 from a connected device. The event is received in the form of a push notification in the
 <AppDelegate> class. This class will start a timer that waits for notification from the
 <AppDelegate> that the provisioning event was received. If the notification is not received within
 the timeout interval, failure to provision is the assumed result. The event timeout interval is a
 configurable constant in PADProvisioningEventManager.m.

 @see AppDelegate.m
 */
@interface PADProvisioningEventManager : NSObject

/*!
 @abstract Creates and returns a `PADProvisioningEventManager` instance for a connected device.

 @param userSessionId  Unique identifier for a connected device.

 @return <PADProvisioningEventManager> instance.

 @see PADUserSession.h
 */
- (instancetype)initWithUserSessionId:(NSString *)userSessionId;

/*!
 @abstract Schedules the timer that waits for an event to be received from the connected device.

 @param success Success block to be executed when an event is received from the device.
 @param failure Failure block to be executed when no event is received after the timer expires.

 @warning The `success` and `failure` blocks are retained strongly by this class. Code inside these
 blocks should be written with this in mind to avoid retain cycles.

 @discussion When an event is received, the `success` block is executed and the timer is stopped.
 */
- (void)waitForResponseFromDeviceWithSuccess:(PADEventManagerCompletionBlock)success
                                     failure:(PADEventManagerCompletionBlock)failure;

@end
