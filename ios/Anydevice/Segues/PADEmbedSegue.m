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

#import "PADEmbedSegue.h"

@implementation PADEmbedSegue

#pragma mark - UIStoryboardSegue

- (void)perform {
    UIViewController *parentViewController = self.sourceViewController;
    UIViewController *childViewController = self.destinationViewController;
    
    // Remove other child view controllers already embedded in the parent view controller.
    for (UIViewController *viewController in parentViewController.childViewControllers) {
        [viewController willMoveToParentViewController:nil];
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
    }
    
    // Start the embed of the new child view controller.
    [parentViewController addChildViewController:childViewController];
    
    // Layout the child view controller's view within the parent using constraints. The child view
    // will fill the parent by setting the child view's Top, Left, Bottom, and Right layout
    // attributes to match those of the parent.
    childViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [parentViewController.view addSubview:childViewController.view];
    NSLayoutConstraint *topConstraint = [self constraintFromChildView:childViewController.view
                                                         toParentView:parentViewController.view
                                                   withEqualAttribute:NSLayoutAttributeTop];
    
    NSLayoutConstraint *leftConstraint = [self constraintFromChildView:childViewController.view
                                                          toParentView:parentViewController.view
                                                    withEqualAttribute:NSLayoutAttributeLeft];
    
    NSLayoutConstraint *bottomConstraint = [self constraintFromChildView:childViewController.view
                                                            toParentView:parentViewController.view
                                                      withEqualAttribute:NSLayoutAttributeBottom];
    
    NSLayoutConstraint *rightConstraint = [self constraintFromChildView:childViewController.view
                                                           toParentView:parentViewController.view
                                                     withEqualAttribute:NSLayoutAttributeRight];
    
    NSArray *childConstraints = @[topConstraint, leftConstraint, bottomConstraint, rightConstraint];
    [parentViewController.view addConstraints:childConstraints];
    
    // Finish the embed of the new child view controller.
    [childViewController didMoveToParentViewController:parentViewController];
}

#pragma mark - Private

/*!
 @abstract Creates an <NSLayoutConstraint> from a given child view to a given parent view for the
 given attribute. The attribute of the child view is set to equal that of its parent view.
 
 @param childView  Reference to the child view.
 @param parentView Reference to the parent view.
 @param attribute  <NSLayoutAttribute> object.
 
 @return Returns an <NSLayoutConstraint> object.
 */
- (NSLayoutConstraint *)constraintFromChildView:(UIView *)childView
                                   toParentView:(UIView *)parentView
                             withEqualAttribute:(NSLayoutAttribute)attribute {
    return [NSLayoutConstraint constraintWithItem:childView
                                        attribute:attribute
                                        relatedBy:NSLayoutRelationEqual
                                           toItem:parentView
                                        attribute:attribute
                                       multiplier:1.0f
                                         constant:0.0f];
}

@end
