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

#import "PADReachability.h"

/*!
 `ReachabilityBlock` is a block that takes a <NetworkStatus> code as parameter.

 @param currentNetworkStatus Current network status.

 @see PADReachability.h
 */
typedef void(^ReachabilityBlock)(PADNetworkStatus currentNetworkStatus);

/*!
 `PADWifiReachabilityManager` determines and manages the current wifi connection state of the phone.

 A user of this class can supply a reachability change handler. When the reachability monitor is
 started, the handler will be called whenever the internet reachability changes until the monitor
 is stopped.
 */
@interface PADWifiReachabilityManager : NSObject

/*!
 @abstract The block to execute whenever reachability changes

 @warning This block is retained strongly by this class. Code inside the block should be written
 with this in mind to avoid retain cycles.
 */
@property (nonatomic, strong) ReachabilityBlock reachabilityChangedBlock;

/*!
 @abstract The block to execute when the timout period for attaining an internet connection has
 passed.

 @warning This block is retained strongly by this class. Code inside the block should be written
 with this in mind to avoid retain cycles.
 */
@property (nonatomic, strong) ReachabilityBlock reconnectingTimedOutBlock;

/*!
 @abstract Current internet reachability status.
 */
@property (nonatomic, assign, readonly) PADNetworkStatus currentNetworkStatus;

/*!
 @abstract Schedules repeated checks for the wifi reachability status and executes the
 `reachabilityChangedBlock` whenever the reachability status changes.

 @discussion When `startNotifier` is called, it makes an immediate call to
 `reachabilityChangedBlock` with the initial reachability status. The next calls to
 `reachabilityChangedBlock` are made on subsequent reachability changes. Before calling
 `startNotifier`, `reachabilityChangedBlock` should be initialized if the caller needs to
 handle reachability changes.
 */
- (void)startNotifier;

/*!
 @abstract Stops the reachability status updates.

 @discussion Does not make a call to `reachabilityChangedBlock` when the notifier is stopped.
 */
- (void)stopNotifier;

@end
