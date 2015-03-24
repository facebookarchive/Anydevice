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

#import "PADLogInViewController.h"

#import <Parse/Parse.h>

#import "PADAlertUtilities.h"
#import "PADCreateAccountViewController.h"
#import "PADEventsService.h"
#import "PADInstallation.h"
#import "PADTextField.h"
#import "UIColor+CustomColors.h"

@interface PADLogInViewController () <UITextFieldDelegate>

/*!
 @abstract Scroll offset when the keyboard is displayed on the log in screen.
 */
@property (nonatomic, assign) CGFloat keyboardOffset;

@end

@implementation PADLogInViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self registerForKeyboardNotifications];
    [self setupTextFields];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)setupTextFields {
    // Setup text field delegates. This enables automatic movement between text fields when the
    // return key on the keyboard is tapped.
    self.view.usernameTextField.delegate = self;
    self.view.passwordTextField.delegate = self;

    // Validate text fields for each character entered so the log in button is enabled/disabled
    // accordingly.
    [self.view.usernameTextField addTarget:self
                                    action:@selector(validateFields)
                          forControlEvents:UIControlEventEditingChanged];

    [self.view.passwordTextField addTarget:self
                                    action:@selector(validateFields)
                          forControlEvents:UIControlEventEditingChanged];
}

- (void)validateFields {
    // Only enable the log in button when all the fields are non-empty.
    BOOL enableLoginButton = ([self.view.usernameTextField.text length] &&
                              [self.view.passwordTextField.text length]);

    [self.view setLoginButtonEnabled:enableLoginButton];
}

#pragma mark - Actions

- (IBAction)logInButtonTapped:(id)sender {
    // Prevent multiple log in requests when one is already in progress.
    if (self.view.isLoading) {
        return;
    }

    [self.view endEditing:YES];

    // Perform log in request.
    NSString *username = self.view.usernameTextField.text;
    NSString *password = self.view.passwordTextField.text;

    self.view.loading = YES;
    [PFUser logInWithUsernameInBackground:username
                                 password:password
                                    block:^(PFUser *user, NSError *error) {
        self.view.loading = NO;

        if (user) {
            [PADEventsService registerForEvents];
            [self dismissViewControllerAnimated:YES completion:nil];

        } else {
            [PADAlertUtilities showErrorAlertWithTitle:NSLocalizedString(@"Error", nil)
                                                 error:error
                                  presentingController:self];
        }
    }];
}

- (IBAction)dismissKeyboardTap:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    // When the keyboard is about to show, we move the log in view up so that the log in button
    // is just visible above the keyboard. If the log in button is already visible (e.g. on
    // iPhone 6, 6+) then we don't need to adjust the view.

    NSDictionary *userInfo = [notification userInfo];
    CGFloat keyboardHeight = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGRect logInButtonRect = [self.view convertRect:self.view.logInButton.bounds
                                           fromView:self.view.logInButton];

    CGFloat logInButtonPosition = CGRectGetMaxY(logInButtonRect);
    CGFloat screenHeight = CGRectGetMaxY(self.view.bounds);
    CGFloat spaceBelowLoginButton = screenHeight - logInButtonPosition;
    self.keyboardOffset = keyboardHeight - spaceBelowLoginButton;

    if (self.keyboardOffset > 0) {
        CGRect frame = self.view.frame;
        frame.origin.y -= self.keyboardOffset;
        self.view.frame = frame;

    } else {
        self.keyboardOffset = 0;
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // Undo any view frame adjustment that was added when the keyboard was displayed.

    CGRect frame = self.view.frame;
    frame.origin.y += self.keyboardOffset;
    self.view.frame = frame;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.view.usernameTextField) {
        [self.view.passwordTextField becomeFirstResponder];
    } else {
        [self.view endEditing:YES];
    }

    return YES;
}

@end
