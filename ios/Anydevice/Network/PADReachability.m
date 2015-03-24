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

#import "PADReachability.h"

#import <netinet/in.h>

#import <SystemConfiguration/SystemConfiguration.h>

NSString *const PADReachabilityChangedNotification = @"kNetworPADReachabilityChangedNotification";

@interface PADReachability ()

/*!
 @abstract Reference to an <SCNetworkReachabilityRef> object that allows this application to
 determine the current network configuration status.
 */
@property (nonatomic, assign) SCNetworkReachabilityRef reachabilityRef;

@end

@implementation PADReachability

/*!
 @abstract Callback that is triggered by a reachability notification.

 @see <SCNetworkReachabilityCallBack> in SCNetworkReachability.h
 */
static void ReachabilityCallback(SCNetworkReachabilityRef target,
                                 SCNetworkReachabilityFlags flags,
                                 void *info)
{
    PADReachability *notificationObject = (__bridge PADReachability *)info;
    [[NSNotificationCenter defaultCenter] postNotificationName:PADReachabilityChangedNotification
                                                        object:notificationObject];
}

#pragma mark - NSObject

- (void)dealloc {
    if (self.reachabilityRef) {
        [self stopNotifier];

        // Must release CoreFoundation objects explicitly.
        CFRelease(self.reachabilityRef);
        self.reachabilityRef = nil;
    }
}

#pragma mark - Public

+ (instancetype)reachabilityForInternetConnection {
    PADReachability *instance = NULL;

    // Use api.parse.com to determine reachability.
    const char *hostName = [@"api.parse.com" UTF8String];
    SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithName(NULL, hostName);

    if (reachabilityRef) {
        instance = [[self alloc] initWithReachabilityRef:reachabilityRef];
    }

    return instance;
}

- (PADNetworkStatus)currentReachabilityStatus {
    PADNetworkStatus returnValue = PADNetworkStatusNotReachable;
    SCNetworkReachabilityFlags flags;

    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        returnValue = [self networkStatusForFlags:flags];
    }

    return returnValue;
}

#pragma mark - Private

/*!
 @abstract Instantiates and returns a <PADReachability> object for a given reachability reference.

 @param reachabilityRef <SCNetworkReachabilityRef> object is a handle to a network address or name.

 @see SCNetworkReachability.h

 @return Returns a <PADReachability> object
 */
- (instancetype)initWithReachabilityRef:(SCNetworkReachabilityRef)reachabilityRef {
    self = [super init];
    if (self) {
        _reachabilityRef = reachabilityRef;

        // Start the notifier to allow for the callback to execute immediately once
        [self startNotifier];
    }

    return self;
}

/*!
 @abstract Start listening for reachability notifications on the current run loop.

 @return Returns a Boolean describing whether the notifier successfully started or not.
 */
- (BOOL)startNotifier {
    BOOL started = NO;
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};

    if (SCNetworkReachabilitySetCallback(self.reachabilityRef, ReachabilityCallback, &context)) {
        started = SCNetworkReachabilityScheduleWithRunLoop(self.reachabilityRef,
                                                           CFRunLoopGetCurrent(),
                                                           kCFRunLoopDefaultMode);
    }

    return started;
}

/*!
 @abstract Stops listening for reachability notifications on the current run loop.
 */
- (void)stopNotifier {
    if (self.reachabilityRef) {
        SCNetworkReachabilityUnscheduleFromRunLoop(self.reachabilityRef,
                                                   CFRunLoopGetCurrent(),
                                                   kCFRunLoopDefaultMode);
    }
}

/*!
 @abstract Determines the network's reachability status based on the reachability flags obtained
 from a reachability notification.

 @param flags The network's reachability flags, obtained from a reachability notification.

 @return Returns the reachability status of the network.
 */
- (PADNetworkStatus)networkStatusForFlags:(SCNetworkReachabilityFlags)flags {
    if (flags & kSCNetworkReachabilityFlagsReachable) {
        return PADNetworkStatusReachable;
    }

    return PADNetworkStatusNotReachable;
}

@end
