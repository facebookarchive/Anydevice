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
 `DeviceStatus` enum represents the reachability states of a device
 */
typedef NS_ENUM(NSInteger, DeviceStatus) {
    /*! Device reachability unknown */
    PADDeviceStatusNotDetermined = 0,

    /*! Device is not reachable */
    PADDeviceStatusNotReachable,

    /*! Device is reachable */
    PADDeviceStatusReachable
};

/*!
 `PADDeviceReachabilityBlock` is a block that takes the current reachability status as a parameter.
 */
typedef void(^PADDeviceReachabilityBlock)(DeviceStatus);

/*!
 `PADDeviceReachabilityManager` determines and manages the current connection state of the phone and
 a connected device. This class assumes that the connected device is running a web server that
 will respond when a GET request is sent to http://192.168.1.1:8080/parse_config.html (this URL
 is configurable in Constants.m). This GET request is used to determine the reachability of the
 device.

 A user of this class can supply a reachability change handler. When the reachability monitor is
 started, the handler will be called whenever the device reachability changes until the monitor
 is stopped.
 */
@interface PADDeviceReachabilityManager : NSObject

/*!
 @abstract The block to execute whenever reachability changes.

 @warning This block is retained strongly by this class. Code inside the block should be written
 with this in mind to avoid retain cycles.
 */
@property (nonatomic, strong) PADDeviceReachabilityBlock reachabilityChangedBlock;

/*!
 @abstract Pings the connected device to check reachability and executes the completion block
 once reachability is determined.

 @param completionBlock The block to execute when reachability status is determined. It should
 have the following signature: ^(DeviceStatus deviceStatus). `deviceStatus` will be set to the
 current reachability status of the connected device.

 @discussion An HTTP GET request is made to the connected device to which it responds with a
 status of 200. If no result is returned within 5 seconds (this timeout period is configurable in
 PADDeviceReachabilityManager.m), then the request times out and returns the
 `PADDeviceStatusNotReachable` status to the completion block. Otherwise, the status
 `PADDeviceStatusReachable` is returned to the completion block.
 */
+ (void)deviceReachabilityStatusWithCompletionBlock:(PADDeviceReachabilityBlock)completionBlock;

/*!
 @abstract Schedules repeated checks for the current reachability status and executes
 `reachabilityChangedBlock` whenever the reachability status changes.

 @discussion When `startNotifier` is called, it makes an immediate call to
 `reachabilityChangedBlock` with the initial reachability status. The next calls to
 `reachabilityChangedBlock` are made on subsequent reachability changes. Before calling
 `startNotifier`, `reachabilityChangedBlock` should be initialized if the caller needs to
 handle reachability changes.
 */
- (void)startNotifier;

/*!
 @abstract Stops reachability status updates.

 @discussion Does not make a call to `reachabilityChangedBlock` when the notifer is stopped.
 */
- (void)stopNotifier;

@end
