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

/*!
 `PADPickerAccessoryViewDelegate` protocol defines the methods required for handling a tap on the
 accessory view button.
 */
@protocol PADPickerAccessoryViewDelegate <NSObject>

/*!
 @abstract Called when picker accessory button is tapped.
 */
- (void)pickerButtonTapped;

@end

/*!
 `PADPickerAccessoryView` provides a styled picker accessory bar containing a customizable button.
 For example, the button can be used as a 'Done' button which dismisses the corresponding picker
 view.
 */
@interface PADPickerAccessoryView : UIView

/*!
 @abstract Outlet to the button on the picker accessory view.
 */
@property (nonatomic, weak) IBOutlet UIButton *pickerButton;

/*!
 @abstract Delegate that responds to taps on the picker button.
 */
@property (nonatomic, weak) id<PADPickerAccessoryViewDelegate> delegate;


/*!
 @abstract Instantiates and returns a `PADPickerAccessoryView` object which handles button taps by
 deferring to the given delegate.

 @param delegate Delegate that responds to the taps on the picker button.

 @return Returns a `PADPickerAccessoryView` object.
 */
+ (instancetype)pickerAccessoryViewWithDelegate:(id<PADPickerAccessoryViewDelegate>)delegate;

/*!
 @abstract Sets the picker accessory button's title to the given string.

 @param title Desired title of the button.
 */
- (void)setButtonTitle:(NSString *)title;

@end
