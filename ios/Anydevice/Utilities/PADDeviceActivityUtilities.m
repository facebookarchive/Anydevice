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

#import "PADDeviceActivityUtilities.h"

#import "PADEvent.h"
#import "PADInstallation.h"

// 3 days in seconds.
static const NSTimeInterval kDeviceInactivityPeriod = 3 * 24 * 60 * 60;

@implementation PADDeviceActivityUtilities

+ (DeviceActivityState)activityStateForInstallation:(PADInstallation *)installation {
    PADEvent *latestEvent = installation.latestEvent;

    // Since an event is sent when provisioning succeeds, we know the device was not provisioned
    // correctly if there is no event.
    if (!latestEvent) {
        return DeviceActivityStateFailedProvisioning;
    }

    NSDate *lastSeenDate = latestEvent.createdAt;
    NSDate *currentTime = [NSDate date];
    NSTimeInterval timeDifference = [currentTime timeIntervalSinceDate:lastSeenDate];
    if (timeDifference > kDeviceInactivityPeriod) {
        return DeviceActivityStateInactive;
    }

    return DeviceActivityStateActive;
}

+ (NSString *)warningForActivityState:(DeviceActivityState)activityState {
    switch (activityState) {
        case DeviceActivityStateFailedProvisioning:
            return NSLocalizedString(@"Device did not provision successfully.",
                                     @"Provisioning error message");

        case DeviceActivityStateInactive:
            return NSLocalizedString(@"Device has been inactive for more than 3 days.",
                                     @"Device inactive error message");

        default:
            // No warning needed if the device is active.
            return nil;
    }
}

@end
