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

#import "PADForgotPasswordView.h"

#import "PADTextField.h"
#import "UIColor+CustomColors.h"

@implementation PADForgotPasswordView

#pragma mark - NSObject

- (void)awakeFromNib {
    UIImage *logo = [UIImage imageNamed:@"parse_logo"];
    logo = [logo imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.logoImageView.image = logo;
    self.logoImageView.backgroundColor = nil;

    [self.submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.submitButton setTitleColor:[UIColor fadedWhite]
                            forState:UIControlStateDisabled];

    [self.submitButton setTitle:NSLocalizedString(@"Submit", nil) forState:UIControlStateNormal];
    self.submitButton.layer.cornerRadius = 4;

    // Submit button should be disabled until the user fills in the email address field.
    [self setForgotPasswordButtonEnabled:NO];

    self.emailTextField.placeholder = NSLocalizedString(@"Email", nil);

    [self.enterEmailLabel setText:NSLocalizedString(@"Enter your email to recover your password",
                                                    @"Enter email message")];
}

#pragma mark - Public

- (void)setForgotPasswordButtonEnabled:(BOOL)enabled {
    UIColor *buttonColor;
    if (enabled) {
        buttonColor = [UIColor commonButtonEnabledBackgroundColor];
    } else {
        buttonColor = [UIColor commonButtonDisabledBackgroundColor];
    }

    self.submitButton.backgroundColor = buttonColor;
    self.submitButton.enabled = enabled;
}

- (BOOL)isLoading {
    return [self.loadingIndicator isAnimating];
}

- (void)setLoading:(BOOL)loading {
    if (loading == self.isLoading) {
        return;
    }

    if (loading) {
        [self.loadingIndicator startAnimating];
    } else {
        [self.loadingIndicator stopAnimating];
    }
}

@end
