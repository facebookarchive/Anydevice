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
 `PADForgotPasswordView` provides a standard user interface for resetting the password of an
 existing account.
 */
@interface PADForgotPasswordView : UIView

/*!
 @abstract Outlet to the image view which displays the Parse logo.
 */
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;

/*!
 @abstract Outlet to the label which describes that an email address is to be entered.
 */
@property (nonatomic, weak) IBOutlet UILabel *enterEmailLabel;

/*!
 @abstract Outlet to the text field which takes input for email address.
 */
@property (nonatomic, weak) IBOutlet PADTextField *emailTextField;

/*!
 @abstract Outlet to the submit button.
 */
@property (nonatomic, weak) IBOutlet UIButton *submitButton;

/*!
 @abstract Outlet to the loading indicator which displays when the submit action is in progress.
 */
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIndicator;

/*!
 @abstract Boolean that controls the display of the submit loading indicator.

 @discussion Setting this to NO will stop and hide the loading indicator, while setting this
 to YES will show and animate the loading indicator.
 */
@property (nonatomic, assign, getter=isLoading) BOOL loading;

/*!
 @abstract Sets the `Submit` button's enabled/disabled state.

 @param enabled The new enabled/disabled state of the `Submit` button.
 */
- (void)setForgotPasswordButtonEnabled:(BOOL)enabled;

@end
