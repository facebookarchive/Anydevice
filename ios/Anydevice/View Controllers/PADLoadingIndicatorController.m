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

#import "PADLoadingIndicatorController.h"

@interface PADLoadingIndicatorController ()

@property (nonatomic, strong) UIWindow *window;

@end

@implementation PADLoadingIndicatorController

#pragma mark - Public

/*!
 @abstract Instantiates and returns a <PADLoadingIndicatorController> object with a given message.

 @param message Message to be displayed along with the loading spinner in the loading interface.

 @return Returns a <PADLoadingIndicatorController> object with the given message.
 */
+ (instancetype)loadingControllerWithMessage:(NSString *)message {
    NSString *nibName = NSStringFromClass(self);
    PADLoadingIndicatorController *loadingController = [[self alloc] initWithNibName:nibName
                                                                              bundle:nil];

    loadingController.message = message;
    return loadingController;
}

- (void)show {
    // Display the loading interface on top of the application's window.
    [self.window makeKeyAndVisible];
}

- (void)hide {
    // Removes the custom window which takes care of removing the loading interface.
    self.window = nil;
}

#pragma mark - Private

- (UIWindow *)window {
    if (!_window) {
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _window.rootViewController = self;
    }

    return _window;
}

#pragma mark - UIViewController

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.loadingContainerView.layer.cornerRadius = 5.0f;
    self.loadingLabel.text = self.message;
}

@end
