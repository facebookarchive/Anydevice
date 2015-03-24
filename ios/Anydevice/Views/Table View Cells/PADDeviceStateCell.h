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
 `SeparatorStyle` bitmask specifies the style of separators that should be used for a given
 `PADDeviceStateCell`.
 */
typedef NS_OPTIONS(NSUInteger, SeparatorStyle){
    /*! Separator on top of the `PADDeviceStateCell` */
    SeparatorStyleTop = 1 << 0,
    /*! Separator on the bottom of the `PADDeviceStateCell` */
    SeparatorStyleBottom = 1 << 1
};

/*!
 `PADDeviceStateCell` represents a table view cell which displays an option for the LED state of a
 provisioned device.
 */
@interface PADDeviceStateCell : UITableViewCell

/*!
 @abstract Outlet to the separator view on the top of the device state cell.
 */
@property (nonatomic, weak) IBOutlet UIView *topSeparatorView;

/*!
 @abstract Outlet to the label which shows an LED state.
 */
@property (nonatomic, weak) IBOutlet UILabel *messageTitleLabel;

/*!
 @abstract Outlet to the image view which conditionally displays a selected icon to indicate the
 device's current LED state.
 */
@property (nonatomic, weak) IBOutlet UIImageView *selectedImageView;

/*!
 @abstract Outlet to the loading indicator that displays when an LED state change message is in
 flight.
 */
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *loadingIndicator;

/*!
 @abstract Outlet to the separator view on the bottom of the device state cell.
 */
@property (nonatomic, weak) IBOutlet UIView *bottomSeparatorView;

/*!
 @abstract Boolean that controls the display of the loading indicator.

 @discussion Setting this to NO will stop and hide the loading indicator, while setting this
 to YES will show and animate the loading indicator.
 */
@property (nonatomic, assign, getter=isLoading) BOOL loading;

/*!
 @abstract Boolean that controls the visibility of the selected icon image view.

 @discussion Setting this to NO will hide the selected icon, while setting this to YES will show the
 selected icon.
 */
@property (nonatomic, assign, getter=isCellSelected) BOOL cellSelected;

/*!
 @abstract Sets up a cell with the given LED state title and separator style.

 @param title          Title of the LED state.
 @param separatorStyle Separator style of the device state cell.
 */
- (void)setupWithMessageTitle:(NSString *)title separatorStyle:(SeparatorStyle)separatorStyle;

@end
