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

#import "PADForgotPasswordViewController.h"

#import <Parse/Parse.h>

#import "PADAlertUtilities.h"
#import "PADTextField.h"
#import "PADUtilities.h"
#import "UIColor+CustomColors.h"

@interface PADForgotPasswordViewController () <UITextFieldDelegate>

/*!
 @abstract Vertical offset of the view when the keyboard becomes visible.
 */
@property (nonatomic, assign) CGFloat keyboardOffset;

@end

@implementation PADForgotPasswordViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Forgot Password", nil);
    self.navigationController.navigationBar.barTintColor = [UIColor navigationBarTintColorDarkGrey];
    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;

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
    self.view.emailTextField.delegate = self;

    // Validate the email field for each character entered so the `Submit` button is enabled/
    // disabled accordingly.
    [self.view.emailTextField addTarget:self
                                 action:@selector(validateFields)
                       forControlEvents:UIControlEventEditingChanged];
}

- (void)validateFields {
    // Only enable the submit button when the email is non-empty.
    [self.view setForgotPasswordButtonEnabled:[self.view.emailTextField.text length]];
}

#pragma mark - Actions

- (IBAction)dismissButtonTapped:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)submitButtonTapped:(id)sender {
    // Prevent multiple submit requests when one is already in progress.
    if (self.view.isLoading) {
        return;
    }

    [self.view endEditing:YES];
    NSString *email = self.view.emailTextField.text ?: @"";

    self.view.loading = YES;
    __weak typeof(self) weakSelf = self;
    [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error) {
        weakSelf.view.loading = NO;
        if (!error && succeeded) {
            // Show an alert to inform the user that a reset link is sent to the email they entered.

            NSString *formatString = NSLocalizedString(@"An email with reset instructions has been sent to '%@'.",
                                                       @"Success message after sending password reset instructions");

            NSString *alertMessage = [NSString stringWithFormat:formatString, email];
            [PADAlertUtilities showAlertWithTitle:NSLocalizedString(@"Success", nil)
                                          message:alertMessage
                             presentingController:weakSelf
                                  completionBlock:^{
                [weakSelf dismissViewControllerAnimated:YES completion:nil];
            }];

        } else {
            [PADAlertUtilities showErrorAlertWithTitle:NSLocalizedString(@"Error", nil)
                                                 error:error
                                  presentingController:weakSelf];
        }
    }];
}

- (IBAction)dismissKeyboardTap:(id)sender {
    [self.view endEditing:YES];
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    // When the keyboard is about to show, we move the forgot password view up so that the `Submit`
    // button is just visible above the keyboard. If the `Submit` button is already visible (e.g. on
    // iPhone 6, 6+) then we don't need to adjust the view.

    NSDictionary *userInfo = [notification userInfo];
    CGFloat keyboardHeight = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGRect submitButtonRect = [self.view convertRect:self.view.submitButton.bounds
                                            fromView:self.view.submitButton];

    CGFloat submitButtonPosition = CGRectGetMaxY(submitButtonRect);
    CGFloat screenHeight = CGRectGetMaxY(self.view.bounds);
    CGFloat spaceBelowSubmitButton = screenHeight - submitButtonPosition;
    self.keyboardOffset = keyboardHeight - spaceBelowSubmitButton;

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
    [self.view endEditing:YES];
    return YES;
}

@end
