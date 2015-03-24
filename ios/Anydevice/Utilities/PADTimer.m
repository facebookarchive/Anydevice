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

#import "PADTimer.h"

@interface PADTimer ()

/*!
 @abstract Boolean to describe whether or not the timer should continue or stop after the
 first time the interval has elapsed.
 */
@property (nonatomic, assign) BOOL repeats;

/*!
 @abstract Timeout interval.
 */
@property (nonatomic, assign) NSTimeInterval timeout;

/*!
 @abstract Block to be executed when the timout interval has elapsed.
 */
@property (nonatomic, strong) TimeoutBlock timeoutBlock;

/*!
 @abstract The underlying <NSTimer> object.
 */
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation PADTimer

#pragma mark - Public

- (instancetype)initWithTimeout:(NSTimeInterval)timeout repeats:(BOOL)repeats {
    self = [super init];
    if (self) {
        self.timeout = timeout;
        self.repeats = repeats;
    }

    return self;
}

- (void)startTimerWithTimeoutBlock:(TimeoutBlock)timeoutBlock {
    self.timeoutBlock = timeoutBlock;
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeout
                                                  target:self
                                                selector:@selector(handleTimeout)
                                                userInfo:nil
                                                 repeats:self.repeats];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - Private

- (void)handleTimeout {
    if (self.timeoutBlock) {
        self.timeoutBlock();
    }
}

@end
