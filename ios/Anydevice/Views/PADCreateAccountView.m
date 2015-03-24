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

#import "PADCreateAccountView.h"

#import "PADTextField.h"
#import "UIColor+CustomColors.h"

@implementation PADCreateAccountView

#pragma mark - UIView

- (void)awakeFromNib {
    UIImage *logo = [UIImage imageNamed:@"parse_logo"];
    logo = [logo imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.logoImageView.image = logo;
    self.logoImageView.backgroundColor = nil;

    [self.createAccountButton setTitleColor:[UIColor whiteColor]
                                   forState:UIControlStateNormal];

    [self.createAccountButton setTitleColor:[UIColor fadedWhite]
                                   forState:UIControlStateDisabled];

    [self.createAccountButton setTitle:NSLocalizedString(@"Create Account", nil)
                              forState:UIControlStateNormal];

    self.createAccountButton.layer.cornerRadius = 4;

    // Create Account button should be disabled until the user fills in all the required fields.
    [self setCreateAccountButtonEnabled:NO];

    self.usernameTextField.placeholder = NSLocalizedString(@"Username", nil);
    self.passwordTextField.placeholder = NSLocalizedString(@"Password", nil);
    self.confirmPasswordTextField.placeholder = NSLocalizedString(@"Re-Enter Password", nil);
    self.emailTextField.placeholder = NSLocalizedString(@"Email", nil);
    self.nameTextField.placeholder = NSLocalizedString(@"Name", nil);
}

- (void)updateConstraints {
    // Adjust vertical spacing bewteen user interface elements based on available screen space.
    // The default spacing between elements is defined in the storyboard. If the elements don't all
    // fit on the screen (e.g. iPhone 4s), reduce the spacing around the Parse logo and create
    // account button.
    CGFloat createAccountContentBottom = CGRectGetMaxY(self.createAccountButton.frame);
    CGFloat createAccountContentTop = self.logoImageView.frame.origin.y;
    CGFloat createAccountContentHeight = createAccountContentBottom - createAccountContentTop;
    CGFloat totalContentPadding = self.frame.size.height - createAccountContentHeight;
    CGFloat topBottomPadding = 15.0f;
    if (totalContentPadding > 45) {
        topBottomPadding = totalContentPadding / 3;
    }

    self.logoImageViewTopSpace.constant = topBottomPadding;
    self.logoImageViewBottomSpace.constant = topBottomPadding;
    self.createAccountButtonBottomSpace.constant = topBottomPadding;

    // Adjust width of the text fields. An explicit width of 290 points was set in the storyboard so
    // that the scroll view's content width was not ambiguous. On phones with more than 320 point
    // screen widths (e.g. iPhone 6, 6+), we adjust the text field width so that a padding of
    // 15 points is maintained on either side of the text field.
    CGFloat usernameLeadingSpace = self.usernameTextFieldLeadingSpace.constant;
    CGFloat usernameTrailingSpace = self.usernameTextFieldTrailingSpace.constant;
    CGFloat horizontalPadding = usernameLeadingSpace + usernameTrailingSpace;
    self.usernameTextFieldWidth.constant = self.frame.size.width - horizontalPadding;
    [super updateConstraints];
}

#pragma mark - Public

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

/*!
 @abstract Sets the `Create Account` button's enabled/disabled state.

 @param enabled The new enabled/disabled state of the `Create Account` button.
 */
- (void)setCreateAccountButtonEnabled:(BOOL)enabled {
    UIColor *buttonColor;
    if (enabled) {
        buttonColor = [UIColor commonButtonEnabledBackgroundColor];
    } else {
        buttonColor = [UIColor commonButtonDisabledBackgroundColor];
    }

    self.createAccountButton.backgroundColor = buttonColor;
    self.createAccountButton.enabled = enabled;
}

@end
