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

@class PADInstallation;

/*!
 `DeviceActivityState` enum describes all the possible states in the activity of a connected device.
 */
typedef NS_ENUM(NSInteger, DeviceActivityState){
    /*! Device failed provisioning */
    DeviceActivityStateFailedProvisioning = 0,

    /*! Device has been inactive for more than 3 days */
    DeviceActivityStateInactive,

    /*! Device is active */
    DeviceActivityStateActive
};

/*!
 `PADDeviceActivityUtilities` provides utilities for determining how actively a connected device is
 being used. The activity state of a device is based on how recently the device was created and
 how recently it has sent events.
 */
@interface PADDeviceActivityUtilities : NSObject

/*!
 @abstract Determines the activity state of the <PADInstallation> object for a connected device.

 @param installation <PADInstallation> object for a connected device.

 @return Returns the device activity state.

 @see PADInstallation.h
 */
+ (DeviceActivityState)activityStateForInstallation:(PADInstallation *)installation;

/*!
 @abstract Returns a warning message which is appropriate for the given device activity state.

 @param activityState Device activity state of the connected device.

 @return Returns a warning message. If the device is active, nil is returned.
 */
+ (NSString *)warningForActivityState:(DeviceActivityState)activityState;

@end
