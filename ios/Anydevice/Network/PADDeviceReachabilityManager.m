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

#import "PADDeviceReachabilityManager.h"

#import "PADConstants.h"
#import "PADTimer.h"

static const NSTimeInterval kDevicePingTimeout = 3.0f;
static const NSTimeInterval kDeviceReachabilityCheckInterval = 5.0f;

@interface PADDeviceReachabilityManager ()

/*!
 *  @abstract Timer that manages the scheduling of device reachability checks.
 */
@property (nonatomic, strong) PADTimer *reachabilityCheckTimer;

/*!
 *  @abstract Most recent device reachability status.
 */
@property (nonatomic, assign) DeviceStatus currentStatus;

@end

@implementation PADDeviceReachabilityManager

#pragma mark - NSObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentStatus = PADDeviceStatusNotDetermined;
    }
    return self;
}

#pragma mark - Public

+ (void)deviceReachabilityStatusWithCompletionBlock:(PADDeviceReachabilityBlock)completionBlock {
    NSURL *deviceUrl = [NSURL URLWithString:PADDeviceUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:deviceUrl];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];

    // This request timeout interval determines how long to wait before declaring the device as unreachable.
    configuration.timeoutIntervalForResource = kDevicePingTimeout;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];

    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!completionBlock) {
            return;
        }

        // A successful request means the device is reachable
        BOOL reachable = (!error && data);
        DeviceStatus deviceStatus = reachable ? PADDeviceStatusReachable : PADDeviceStatusNotReachable;

        // Execute the completion block on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(deviceStatus);
        });
    }];

    [dataTask resume];
}

- (void)startNotifier {
    [self.reachabilityCheckTimer stopTimer];
    self.reachabilityCheckTimer = [[PADTimer alloc] initWithTimeout:kDeviceReachabilityCheckInterval
                                                            repeats:YES];

    // Make an immediate call back with the initial reachability status
    [self handleReachabilityCheck];

    __weak typeof(self) weakSelf = self;
    [self.reachabilityCheckTimer startTimerWithTimeoutBlock:^{
        [weakSelf handleReachabilityCheck];
    }];
}

- (void)stopNotifier {
    [self.reachabilityCheckTimer stopTimer];
}

#pragma mark - Private

/*!
 @abstract Checks for device reachability. If reachability changes, it executes the reachability
 changed block.
 */
- (void)handleReachabilityCheck {
    [[self class] deviceReachabilityStatusWithCompletionBlock:^(DeviceStatus deviceStatus) {
        // If reachability has changed and handler has been assigned, execute handler

        BOOL statusChanged = (self.currentStatus != deviceStatus);
        self.currentStatus = deviceStatus;

        if (statusChanged && self.reachabilityChangedBlock) {
            self.reachabilityChangedBlock(deviceStatus);
        }
    }];
}

@end
