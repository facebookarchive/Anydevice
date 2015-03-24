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

#import "PADLogInView.h"

#import "PADTextField.h"
#import "UIColor+CustomColors.h"

@implementation PADLogInView

- (void)awakeFromNib {
    UIImage *logo = [UIImage imageNamed:@"parse_logo"];
    logo = [logo imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.logoImageView.image = logo;
    self.logoImageView.backgroundColor = nil;

    self.usernameTextField.placeholder = NSLocalizedString(@"Username", nil);
    self.passwordTextField.placeholder = NSLocalizedString(@"Password", nil);

    [self.logInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logInButton setTitleColor:[UIColor fadedWhite]
                           forState:UIControlStateDisabled];

    [self.logInButton setTitle:NSLocalizedString(@"Log In", nil) forState:UIControlStateNormal];
    self.logInButton.layer.cornerRadius = 4;

    // Login button should be disabled until the user fills in all the required fields.
    [self setLoginButtonEnabled:NO];

    [self.forgotPasswordButton setTitleColor:[UIColor fadedWhite]
                                    forState:UIControlStateNormal];

    NSString *title = NSLocalizedString(@"Forgot Password", nil);
    NSDictionary *titleAttributes = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title
                                                                          attributes:titleAttributes];

    self.forgotPasswordButton.titleLabel.attributedText = attributedTitle;

    [self.createAccountButton setTitleColor:[UIColor fadedWhite]
                                   forState:UIControlStateNormal];

    [self.createAccountButton setTitle:NSLocalizedString(@"Create an Account", nil)
                              forState:UIControlStateNormal];
}

#pragma mark - Public

- (void)setLoginButtonEnabled:(BOOL)enabled {
    UIColor *buttonColor;
    if (enabled) {
        buttonColor = [UIColor commonButtonEnabledBackgroundColor];
    } else {
        buttonColor = [UIColor commonButtonDisabledBackgroundColor];
    }

    self.logInButton.backgroundColor = buttonColor;
    self.logInButton.enabled = enabled;
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
