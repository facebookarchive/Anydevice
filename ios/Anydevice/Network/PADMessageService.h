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

#import "PADDeviceStateUtilities.h"

@class PADInstallation;

/*!
 `MessageSuccess` is a block that takes no parameters.
 */
typedef void(^MessageSuccess)();

/*!
 `Failure` is a block that takes an <NSError> object as a parameter.

 @param NSError Contains error description.
 */
typedef void(^Failure)(NSError *);

/*!
 `PADMessageService` provides methods to send messages to a connected device.
 */
@interface PADMessageService : NSObject

/*!
 @abstract Sends a message to the connected device that will change the LED status of the device.

 @param deviceState     The new LED state to which the connected device should change.
 @param toInstallation  <PADInstallation> object for the connected device.
 @param success         Success block to execute if message is sent successfully.
 @param failure         Failure block to execute if message fails to send.

 @warning The success block is called when the message is successfully saved to the Parse cloud.
 This does not guarantee that the connected device actually received the message, as the Parse
 cloud must forward the message via a push notification to the connected device.

 @see PADDeviceStateUtilities.h
 @see PADInstallation.h
 */
+ (void)sendDeviceState:(DeviceState)deviceState
         toInstallation:(PADInstallation *)installation
                success:(MessageSuccess)success
                failure:(Failure)failure;

@end
