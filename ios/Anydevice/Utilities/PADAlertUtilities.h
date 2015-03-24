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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/*!
 `PADAlertUtilities` provides utilities for displaying alerts and action sheets for multiple use cases.
 */
@interface PADAlertUtilities : NSObject

/*!
 @abstract Displays an error alert with an 'OK' button by using the description from an <NSError>
 object.

 @param title                Title of the alert.
 @param error                <NSError> object containing the error description.
 @param presentingController View controller on top of which the alert is to be presented.
 */
+ (void)showErrorAlertWithTitle:(NSString *)title
                          error:(NSError *)error
           presentingController:(UIViewController *)presentingController;

/*!
 @abstract Displays an error alert with an `OK` button by using the description from the <NSError>
 object. A completion handler is called when the alert is dismissed.

 @param title                Title of the alert.
 @param error                <NSError> object containing the error description.
 @param presentingController View controller on top of which the alert is to be presented.
 @param completionBlock      Block to be executed when the user taps the 'OK' button.
 */
+ (void)showErrorAlertWithTitle:(NSString *)title
                          error:(NSError *)error
           presentingController:(UIViewController *)presentingController
                completionBlock:(void(^)())completionBlock;

/*!
 @abstract Displays an alert with an 'OK' button for any message.

 @param title                Title of the alert.
 @param message              Message to be displayed on the alert.
 @param presentingController View controller on top of which the alert is to be presented.
 */
+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
      presentingController:(UIViewController *)presentingController;

/*!
 @abstract Displays an alert with an 'OK' button for any message. A completion handler is called
 when the alert is dismissed.

 @param title                Title of the alert.
 @param message              Message to be displayed on the alert.
 @param presentingController View controller on top of which the alert is to be presented.
 @param completionBlock      Block to be executed when the user taps the 'OK' button.
 */
+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
      presentingController:(UIViewController *)presentingController
           completionBlock:(void(^)())completionBlock;

/*!
 @abstract Displays a confirmation action sheet with a custom confirmation action and a 'Cancel'
 action. A completion handler is executed only when the confirmation action button is tapped.

 @param title                Title of the action sheet.
 @param message              Message to be displayed on the action sheet.
 @param actionButtonTitle    Title of the confirmation action button.
 @param presentingController View controller on top of which the action sheet is to be presented.
 @param completionBlock      Block to be executed when the user taps the confirmation action button.
 */
+ (void)showConfirmationActionSheetWithTitle:(NSString *)title
                                     message:(NSString *)message
                           actionButtonTitle:(NSString *)actionButtonTitle
                        presentingController:(UIViewController *)presentingController
                             completionBlock:(void(^)())completionBlock;

/*!
 @abstract Displays an alert which contains the custom actions provided by the caller.

 @param title                Title of the alert.
 @param message              Message to be displayed on the alert.
 @param alertActions         <NSArray> contanining the <UIAlertAction> objects that define the
 buttons.
 @param presentingController View controller on top of which the alert is to be presented.

 @return Returns the alert view controller object being displayed.
 */
+ (UIAlertController *)showActionAlertWithTitle:(NSString *)title
                                        message:(NSString *)message
                                   alertActions:(NSArray *)alertActions
                           presentingController:(UIViewController *)presentingController;

@end
