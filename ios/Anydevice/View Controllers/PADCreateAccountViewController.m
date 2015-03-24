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

#import "PADCreateAccountViewController.h"

#import <Parse/Parse.h>

#import "PADAlertUtilities.h"
#import "PADStoryboardConstants.h"
#import "PADTextField.h"
#import "PADUtilities.h"
#import "UIColor+CustomColors.h"

@interface PADCreateAccountViewController () <UITextFieldDelegate>

@end

@implementation PADCreateAccountViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Create Account", nil);
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
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)setupTextFields {
    // Setup text field delegates. This enables automatic movement between text fields when the
    // return key on the keyboard is tapped.
    self.view.usernameTextField.delegate = self;
    self.view.passwordTextField.delegate = self;
    self.view.confirmPasswordTextField.delegate = self;
    self.view.emailTextField.delegate = self;
    self.view.nameTextField.delegate = self;

    // Validate text fields for each character entered so the `Create Account` button is enabled/
    // disabled accordingly.
    [self.view.usernameTextField addTarget:self
                                    action:@selector(validateFields)
                          forControlEvents:UIControlEventEditingChanged];

    [self.view.passwordTextField addTarget:self
                                    action:@selector(validateFields)
                          forControlEvents:UIControlEventEditingChanged];

    [self.view.confirmPasswordTextField addTarget:self
                                           action:@selector(validateFields)
                                 forControlEvents:UIControlEventEditingChanged];

    [self.view.emailTextField addTarget:self
                                 action:@selector(validateFields)
                       forControlEvents:UIControlEventEditingChanged];

    [self.view.nameTextField addTarget:self
                                action:@selector(validateFields)
                      forControlEvents:UIControlEventEditingChanged];
}

- (void)validateFields {
    // Only enable the create account button when all the fields are non-empty.
    BOOL enableCreateAccountButton = ([self.view.usernameTextField.text length] &&
                                      [self.view.passwordTextField.text length] &&
                                      [self.view.confirmPasswordTextField.text length] &&
                                      [self.view.emailTextField.text length] &&
                                      [self.view.nameTextField.text length]);

    [self.view setCreateAccountButtonEnabled:enableCreateAccountButton];
}

#pragma mark - Actions

- (IBAction)dismissButtonTapped:(id)sender {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)createAccountButtonTapped:(id)sender {
    // Prevent multiple sign up requests when one is already in progress.
    if (self.view.isLoading) {
        return;
    }

    [self.view endEditing:YES];

    // Ensure the original password matches the confirmed password matches.
    NSString *password = self.view.passwordTextField.text;
    NSString *confirmedPassword = self.view.confirmPasswordTextField.text;
    if (![password isEqualToString:confirmedPassword]) {
        [PADAlertUtilities showAlertWithTitle:NSLocalizedString(@"Error", nil)
                                      message:NSLocalizedString(@"Passwords do not match.", nil)
                         presentingController:self];

        return;
    }

    // Perform the user sign up request.
    PFUser *newUser = [PFUser object];
    newUser.username = self.view.usernameTextField.text;
    newUser.password = password;
    newUser.email = self.view.emailTextField.text;
    [newUser setObject:self.view.nameTextField.text forKey:@"name"];

    self.view.loading = YES;
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.view.loading = NO;
        if (!error && succeeded) {
            // This segue will navigate to the user's home screen by dismissing all authentication
            // related modal view controllers (log in and create acccount).
            [self performSegueWithIdentifier:PADCreateAccountDismissSegue sender:nil];
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
    // Adjust scroll view inset when the keyboard is up so all fields and buttons can be reached.

    NSDictionary *userInfo = [notification userInfo];
    CGFloat keyboardHeight = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.view.scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.view.scrollView.contentInset = UIEdgeInsetsZero;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Automatically navigate to the next field in the form until the form is completed.

    if (textField == self.view.usernameTextField) {
        [self.view.passwordTextField becomeFirstResponder];
    } else if (textField == self.view.passwordTextField) {
        [self.view.confirmPasswordTextField becomeFirstResponder];
    } else if (textField == self.view.confirmPasswordTextField) {
        [self.view.emailTextField becomeFirstResponder];
    } else if (textField == self.view.emailTextField) {
        [self.view.nameTextField becomeFirstResponder];
    } else if (textField == self.view.nameTextField) {
        [self.view endEditing:YES];
    }

    return YES;
}

@end
