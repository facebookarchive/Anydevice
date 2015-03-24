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
 `PADCreateAccountView` provides a standard user interface for creating a new account.
 */
@interface PADCreateAccountView : UIView

/*!
 @abstract Outlet to the scroll view which contains all the elements on the screen.
 */
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

/*!
 @abstract Outlet to the text field which takes input for username.
 */
@property (nonatomic, weak) IBOutlet PADTextField *usernameTextField;

/*!
 @abstract Outlet to the text field which takes input for password.
 */
@property (nonatomic, weak) IBOutlet PADTextField *passwordTextField;

/*!
 @abstract Outlet to the text field which takes input for confirming the password.
 */
@property (nonatomic, weak) IBOutlet PADTextField *confirmPasswordTextField;

/*!
 @abstract Outlet to the text field which takes input for email address.
 */
@property (nonatomic, weak) IBOutlet PADTextField *emailTextField;

/*!
 @abstract Outlet to the text field which takes input for the name of the user.
 */
@property (nonatomic, weak) IBOutlet PADTextField *nameTextField;

/*!
 @abstract Outlet to the image view which displays the Parse logo.
 */
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;

/*!
 @abstract Outlet to the create account button.
 */
@property (nonatomic, weak) IBOutlet UIButton *createAccountButton;

/*!
 @abstract Outlet to the loading indicator which displays when the create account action is in
 progress.
 */
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIndicator;

/*!
 @abstract Outlet to the constraint for the space between the top of Parse logo and the top of the
 scroll view.
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *logoImageViewTopSpace;

/*!
 @abstract Outlet to the constraint for the space between the bottom of the Parse logo and the top
 of the username text field.
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *logoImageViewBottomSpace;

/*!
 @abstract Outlet to the constraint for the space between the bottom of the create account button
 and the bottom of the scroll view.
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *createAccountButtonBottomSpace;

/*!
 @abstract Outlet to the constraint for the width of the username text field.
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *usernameTextFieldWidth;

/*!
 @abstract Outlet to the constraint for the space between the left side of the username text field
 and the left side of the scroll view.
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *usernameTextFieldLeadingSpace;

/*!
 @abstract Outlet to the constraint for the space between the right side of the username text field
 and the right side of the scroll view.
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *usernameTextFieldTrailingSpace;

/*!
 @abstract Boolean that controls the display of the sign up loading indicator.

 @discussion Setting this to NO will stop and hide the loading indicator, while setting this
 to YES will show and animate the loading indicator.
 */
@property (nonatomic, assign, getter=isLoading) BOOL loading;

- (void)setCreateAccountButtonEnabled:(BOOL)enabled;

@end
