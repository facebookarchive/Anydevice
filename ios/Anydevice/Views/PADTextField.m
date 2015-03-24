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

#import "PADTextField.h"

#import "UIColor+CustomColors.h"

@implementation PADTextField

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }

    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor textFieldBackgroundColor];
    self.font = [UIFont systemFontOfSize:17.0f];
    self.textColor = [UIColor whiteColor];
}

#pragma mark - Frame

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(20.0f, 0.0f, CGRectGetWidth(bounds) - 30.0f, CGRectGetHeight(bounds));
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

#pragma mark - Placeholder

- (void)setPlaceholder:(NSString *)placeholder {
    NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor fadedWhite]};
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder
                                                                 attributes:attributes];
}

@end
