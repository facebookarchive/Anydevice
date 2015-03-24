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

@class PADEvent;

/*!
 `DeviceState` enum describes all possible states of a connected device's LED
 */
typedef NS_ENUM(NSUInteger, DeviceState){
    /*! LED is off */
    DeviceStateOff = 0,

    /*! LED is on */
    DeviceStateOn,

    /*! LED is blinking */
    DeviceStateBlink,

    /*! Number of LED states */
    DeviceStateCount
};

/*!
 `PADDeviceStateUtilities` provides utilities for working with the LED state of a connected device.
 E.g. Converting the device states to user facing strings, converting device state strings sent from
 the device as strings to the appropriate <DeviceState> code, creating LED state change messages to
 send to the device, etc.
 */
@interface PADDeviceStateUtilities : NSObject

/*!
 @abstract Returns an appropriate title string that represents the given device state.

 @param deviceState LED state of the connected device.

 @return Returns a title for the LED state.
 */
+ (NSString *)messageTitleForDeviceState:(DeviceState)deviceState;

/*!
 @abstract Returns a json string that can be sent as an LED state change message to the connected
 device.

 @param deviceState Desired LED state of the connected device.

 @return Returns an LED state change message in the correct json format.
 */
+ (NSString *)messageBodyForDeviceState:(DeviceState)deviceState;

/*!
 @abstract Determines the LED state of the device from a state provided as a string.

 @param deviceStateString LED state of the device in string format.

 @return Returns a device state for the connected device.
 */
+ (DeviceState)deviceStateFromDeviceStateString:(NSString *)deviceStateString;

/*!
 @abstract Retrieves the LED state string from an <PADEvent> object sent from the connected device.

 @param blinkEvent LED state <PADEvent> sent by the connected device.

 @return Returns the LED state in string format.

 @see PADEvent.h
 */
+ (NSString *)deviceStateFromBlinkEvent:(PADEvent *)blinkEvent;

@end
