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

@class PADTextField;

/*!
 'PADLogInView' contains the UI elements of the log in screen.
 */
@interface PADLogInView : UIView

/*!
 @abstract Outlet to the image view that displays the Parse logo.
 */
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;

/*!
 @abstract Outlet to the text field that takes username input for log in.
 */
@property (nonatomic, weak) IBOutlet PADTextField *usernameTextField;

/*!
 @abstract Outlet to the text field that takes password input for log in.
 */
@property (nonatomic, weak) IBOutlet PADTextField *passwordTextField;

/*!
 @abstract Outlet to the loading indicator that displays when log in is in progress.
 */
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIndicator;

/*!
 @abstract Outlet to the log in button.
 */
@property (nonatomic, weak) IBOutlet UIButton *logInButton;

/*!
 @abstract Outlet to the button that navigates to the forgot password screen.
 */
@property (nonatomic, weak) IBOutlet UIButton *forgotPasswordButton;

/*!
 @abstract Outlet to the button that navigates to the create account screen.
 */
@property (nonatomic, weak) IBOutlet UIButton *createAccountButton;

/*!
 @abstract Boolean that controls the display of the log in loading indicator.

 @discussion Setting this to NO will stop and hide the loading indicator, while setting this
 to YES will show and animate the loading indicator.
 */
@property (nonatomic, assign, getter=isLoading) BOOL loading;

/*!
 @abstract Sets the log in button's enabled/disabled state.

 @param enabled The new enabled/disabled state of the log in button.
 */
- (void)setLoginButtonEnabled:(BOOL)enabled;

@end
