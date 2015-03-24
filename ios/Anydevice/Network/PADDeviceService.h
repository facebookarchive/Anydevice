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

@class PADInfrastructureKey;
@class PADUserSession;

/*!
 `PADDeviceService` provides methods for communicating directly with a connected device. Therefore,
 these methods assume that the phone is connected to a device access point.
 */
@interface PADDeviceService : NSObject

/*!
 @abstract Posts wifi information of an access point and the desired device name to the connected
 device. The device will drop its access point and attempt to connect to the provided access point.

 @param wifiCredentials Contains wifi information of the access point.
 @param andDeviceName   Desired name of the device.
 @param toUserSession   <PADUserSession> object of the connected device.

 @see PADInfrastructureKey.h
 @see PADUserSession.h
 */
+ (void)postWifiCredentials:(PADInfrastructureKey *)wifiCredentials
              andDeviceName:(NSString *)deviceName
              toUserSession:(PADUserSession *)userSession;

@end
