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
 `PADReachability` provides methods to determine the current internet reachability of the phone, and
 to notify listeners when the internet reachability changes.
 */
@interface PADReachability : NSObject

/*!
 @abstract Notification identifier for the reachability status changed notification.
 */
extern NSString *const PADReachabilityChangedNotification;

/*!
 `PADNetworkStatus` enum describes all the possible states for internet reachability.
 */
typedef NS_ENUM(NSInteger, PADNetworkStatus){
    /*! Internet is not reachable */
    PADNetworkStatusNotReachable = 0,

    /*! Internet is reachable */
    PADNetworkStatusReachable
};

/*!
 @abstract Instantiates a `PADReachability` object which monitors internet reachability using the
 Parse API host name (api.parse.com).

 @discussion The reachability change notifier is started immediately upon initialization.

 @return Returns a `PADReachability` object.
 */
+ (instancetype)reachabilityForInternetConnection;

/*!
 @abstract Determines the current status of internet reachability.

 @return Returns the current internet reachability status.
 */
- (PADNetworkStatus)currentReachabilityStatus;

@end
