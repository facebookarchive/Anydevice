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

#import "PADProvisioningEventManager.h"

#import "PADConstants.h"
#import "PADEventsService.h"
#import "PADTimer.h"

static const NSTimeInterval PADEventReceivedTimeout = 60;

@interface PADProvisioningEventManager ()

/*!
 @abstract Success block to execute when an event is received from the connected device.
 */
@property (nonatomic, strong) PADEventManagerCompletionBlock successBlock;

/*!
 @abstract Failure block to execute when no event is received after `PADEventReceivedTimeout` seconds.
 */
@property (nonatomic, strong) PADEventManagerCompletionBlock failureBlock;

/*!
 @abstract Timer which tracks the time spent waiting for the event to be received.
 */
@property (nonatomic, strong) PADTimer *eventReceivedTimer;

/*!
 @abstract User session ID for the connected device from which the event is being received.
 */
@property (nonatomic, strong) NSString *userSessionId;

/*!
 @abstract A boolean indicating whether the provisioning event has been received or not.
 */
@property (nonatomic, assign) BOOL eventReceived;

@end

@implementation PADProvisioningEventManager

#pragma mark - NSObject

- (void)dealloc {
    [self.eventReceivedTimer stopTimer];
    [self unsubscribeFromEventNotification];
}

#pragma mark - Public

- (instancetype)initWithUserSessionId:(NSString *)userSessionId {
    self = [super init];
    if (self) {
        self.userSessionId = userSessionId;
        [self subscribeForEventNotification];
    }
    return self;
}

- (void)waitForResponseFromDeviceWithSuccess:(PADEventManagerCompletionBlock)success
                                     failure:(PADEventManagerCompletionBlock)failure
{
    self.successBlock = success;
    self.failureBlock = failure;

    [self startEventReceivedTimer];
}

#pragma mark - Private

/*!
 @abstract Starts the event received timer.
 */
- (void)startEventReceivedTimer {
    // If we have already received the event before the timer started, just call the success block
    // and return.
    if (self.eventReceived) {
        if (self.successBlock) {
            self.successBlock();
        }

        return;
    }

    self.eventReceivedTimer = [[PADTimer alloc] initWithTimeout:PADEventReceivedTimeout repeats:NO];

    __weak typeof(self) weakSelf = self;
    [self.eventReceivedTimer startTimerWithTimeoutBlock:^{
        [weakSelf eventReceivedTimerExpired];
    }];
}

/*!
 @abstract Starts listening for the provisioning event notification.

 @discussion The provisioning event notification is posted when an event is received in the
 <AppDelegate> class.

 @see AppDelegate.m
 */
- (void)subscribeForEventNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventReceived:)
                                                 name:PADProvisioningEventNotification
                                               object:nil];
}

- (void)unsubscribeFromEventNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)eventReceivedTimerExpired {
    [self unsubscribeFromEventNotification];

    if (self.failureBlock) {
        self.failureBlock();
    }
}

/*!
 @abstract Handles the receiving of the provisioning event.

 @param eventNotification The data associated with the event received notification.
 */
- (void)eventReceived:(NSNotification *)eventNotification {
    // If the event was not from the device we wanted, just ignore it.
    NSString *userSessionId = [eventNotification.userInfo objectForKey:@"userSessionId"];
    if (![userSessionId isEqualToString:self.userSessionId]) {
        return;
    }

    // Mark that we have received the event.
    self.eventReceived = YES;

    [self.eventReceivedTimer stopTimer];
    if (self.successBlock) {
        self.successBlock();
    }
}

@end
