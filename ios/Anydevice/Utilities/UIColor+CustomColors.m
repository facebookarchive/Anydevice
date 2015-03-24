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

#import "UIColor+CustomColors.h"

@implementation UIColor (CustomColors)

#pragma mark - Common

+ (UIColor *)fadedWhite {
    return [UIColor colorWithRed:1.0f
                           green:1.0f
                            blue:1.0f
                           alpha:0.5f];
}

#pragma mark - Navigation Bar

+ (UIColor *)navigationBarTintColorDefault {
    return [UIColor colorWithRed:89/255.0f
                           green:107/255.0f
                            blue:120/255.0f
                           alpha:1.0f];
}

+ (UIColor *)navigationBarTintColorDarkGrey {
    return [UIColor colorWithRed:52/255.0f
                           green:54/255.0f
                            blue:60/255.0f
                           alpha:1.0f];
}

+ (UIColor *)navigationTintColorDefault {
    return [UIColor colorWithRed:159/255.0f
                           green:178/255.0f
                            blue:189/255.0f
                           alpha:1.0f];
}

#pragma mark - TextField

+ (UIColor *)textFieldBackgroundColor {
    return [UIColor colorWithRed:84/255.0f
                           green:87/255.0f
                            blue:92/255.0f
                           alpha:0.6f];
}

+ (UIColor *)textFieldPlaceholderColor {
    return [UIColor colorWithWhite:194.0f/255.0f alpha:1.0f];
}

#pragma mark - Buttons

+ (UIColor *)commonButtonDisabledBackgroundColor {
    return [UIColor colorWithRed:51.0f/255.0f
                           green:67.f/255.0f
                            blue:77.0f/255.0f
                           alpha:1.0f];
}

+ (UIColor *)commonButtonEnabledBackgroundColor {
    return [UIColor colorWithRed:89.0f/255.0f
                           green:107.f/255.0f
                            blue:120.0f/255.0f
                           alpha:1.0f];
}

+ (UIColor *)provisioningFlowButtonEnabledBackgroundColor {
    return [UIColor colorWithRed:78.0f/255.0f
                           green:149.0f/255.0f
                            blue:255.0f/255.0f
                           alpha:1.0f];
}

+ (UIColor *)provisioningFlowButtonDisabledBackgroundColor {
    return [UIColor colorWithRed:152.0f/255.0f
                           green:191.0f/255.0f
                            blue:251.0f/255.0f
                           alpha:1.0f];
}

@end
