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
 `PADProvisionedDeviceCell` represents a collection view cell which displays the title and model
 information for a provisioned device.
 */
@interface PADProvisionedDeviceCell : UICollectionViewCell

/*!
 @abstract Outlet to the label which shows the name of the device.
*/
@property (nonatomic, weak) IBOutlet UILabel *deviceNameLabel;

/*!
 @abstract Outlet to the label which shows the name of the model.
 */
@property (nonatomic, weak) IBOutlet UILabel *modelNameLabel;

/*!
 @abstract Outlet to the image view which displays the model icon.
 */
@property (nonatomic, weak) IBOutlet UIImageView *modelIconImageView;

/*!
 @abstract Outlet to the constraint which holds the height of the model icon.
 */
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *modelIconImageViewHeight;

/*!
 @abstract Outlet to the image view which conditionally displays a warning icon.
 */
@property (nonatomic, weak) IBOutlet UIImageView *warningImageView;

/*!
 @abstract Sets up the user interface elements of the cell.

 @param deviceName  Name of the device.
 @param modelName   Model name of the device.
 @param showWarning Boolean describing whether or not a warning icon should be displayed on the cell.
 */
- (void)setupWithDeviceName:(NSString *)deviceName
                  modelName:(NSString *)modelName
                showWarning:(BOOL)showWarning;

/*!
 @abstract Sets up the model icon image view with the given image.

 @param image Image to be displayed as the model icon.
 */
- (void)setImage:(UIImage *)image;

@end
