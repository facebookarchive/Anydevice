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

#import <UIKit/UIKit.h>

/*!
 `PADLoadingIndicatorController` presents and manages a full screen loading indicator interface. The
 interface includes a loading spinner and a customizable message. The interface is presented in its
 own Window so that it blocks all content behind it.
 */
@interface PADLoadingIndicatorController : UIViewController

/*!
 @abstract Outlet to the view which contains the loading indicator and message.
 */
@property (nonatomic, weak) IBOutlet UIView *loadingContainerView;

/*!
 @abstract Outlet to the label which displays the custom message.
 */
@property (nonatomic, weak) IBOutlet UILabel *loadingLabel;

/*!
 @abstract The custom message to show along with the loading indicator.
 */
@property (nonatomic, copy) NSString *message;

/*!
 @abstract Static method which creates and returns an instance of `PADLoadingIndicatorController`
 with the given message.

 @param message The message to show along with the loading indicator.

 @return Returns the new instance of `PADLoadingIndicatorController`.
 */
+ (instancetype)loadingControllerWithMessage:(NSString *)message;

/*!
 @abstract Displays the loading interface in a new Window.
 */
- (void)show;

/*!
 @abstract Removes the loading interface from the screen.
 */
- (void)hide;

@end
