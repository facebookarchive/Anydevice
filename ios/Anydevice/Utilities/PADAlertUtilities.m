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

#import "PADAlertUtilities.h"

#import <UIKit/UIKit.h>

@implementation PADAlertUtilities

+ (void)showErrorAlertWithTitle:(NSString *)title
                          error:(NSError *)error
           presentingController:(UIViewController *)presentingController
{
    [self showErrorAlertWithTitle:title
                            error:error
             presentingController:presentingController
                  completionBlock:nil];
}

+ (void)showErrorAlertWithTitle:(NSString *)title
                          error:(NSError *)error
           presentingController:(UIViewController *)presentingController
                completionBlock:(void(^)())completionBlock
{
    NSString *message = nil;

    // Extract the error description from the error object
    if (error.userInfo[@"originalError"]) {
        message = [error.userInfo[@"originalError"] localizedDescription];
    } else if (error.userInfo[@"error"]) {
        message = error.userInfo[@"error"];
    } else {
        message = [error localizedDescription];
    }

    [self showAlertWithTitle:title
                     message:message
        presentingController:presentingController
             completionBlock:completionBlock];
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
      presentingController:(UIViewController *)presentingController
{
    [self showAlertWithTitle:title
                     message:message
        presentingController:presentingController
             completionBlock:nil];
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
      presentingController:(UIViewController *)presentingController
           completionBlock:(void(^)())completionBlock
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                       style:UIAlertActionStyleDefault
                                                     handler:completionBlock];

    [alert addAction:okAction];
    [presentingController presentViewController:alert animated:YES completion:nil];
}

+ (void)showConfirmationActionSheetWithTitle:(NSString *)title
                                     message:(NSString *)message
                           actionButtonTitle:(NSString *)actionButtonTitle
                        presentingController:(UIViewController *)presentingController
                             completionBlock:(void(^)())completionBlock
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:actionButtonTitle
                                                       style:UIAlertActionStyleDestructive
                                                     handler:completionBlock];

    [alert addAction:okAction];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];

    [alert addAction:cancelAction];
    [presentingController presentViewController:alert animated:YES completion:nil];
}

+ (UIAlertController *)showActionAlertWithTitle:(NSString *)title
                                        message:(NSString *)message
                                   alertActions:(NSArray *)alertActions
                           presentingController:(UIViewController *)presentingController
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alertActions enumerateObjectsUsingBlock:^(UIAlertAction *action, NSUInteger idx, BOOL *stop) {
        [alert addAction:action];
    }];

    [presentingController presentViewController:alert animated:YES completion:nil];
    return alert;
}

@end
