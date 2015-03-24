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
 `TimeoutBlock` is a block that takes no parameters.
 */
typedef void(^TimeoutBlock)();

/*!
 `PADTimer` is a timer class utility making it easy to schedule, start and stop timers. It simply
 wraps NSTimer to remove boilerplate and have a block-based interface for the timer callback.
 */
@interface PADTimer : NSObject

/*!
 @abstract Initializes a `PADTimer` object with a timeout interval and a boolean for whether the
 timer repeats or not.

 @param timeout Timeout interval.
 @param repeats `YES` if timer should repeat after every timeout period, `NO` otherwise.

 @return Returns a `PADTimer` object
 */
- (instancetype)initWithTimeout:(NSTimeInterval)timeout repeats:(BOOL)repeats;

/*!
 @abstract Starts the timer with a timeout handler block that is executed when the timeout interval
 has elapsed.

 @param timeoutBlock Block to be executed when the timeout interval has elapsed.

 @warning The `timeoutBlock` block is retained strongly by this class. Code inside the block should
 be written with this in mind to avoid retain cycles.
 */
- (void)startTimerWithTimeoutBlock:(TimeoutBlock)timeoutBlock;

/*!
 @abstract Stops the timer.
 */
- (void)stopTimer;

@end
