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

#import "PADDeviceStateCell.h"

@implementation PADDeviceStateCell

#pragma mark - UITableViewCell

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Public

- (void)setupWithMessageTitle:(NSString *)title separatorStyle:(SeparatorStyle)separatorStyle {
    self.messageTitleLabel.text = title;
    self.topSeparatorView.hidden = !(separatorStyle & SeparatorStyleTop);
    self.bottomSeparatorView.hidden = !(separatorStyle & SeparatorStyleBottom);
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;

    // Since the loading indicator and the selected icon are in the same position, a cell that is
    // loading never displays the selected icon.
    self.selectedImageView.hidden = _loading;
    _loading ? [self.loadingIndicator startAnimating] : [self.loadingIndicator stopAnimating];
}

- (void)setCellSelected:(BOOL)cellSelected {
    _cellSelected = cellSelected;
    if(_cellSelected) {
        self.selectedImageView.image = [UIImage imageNamed:@"checkmark"];
    } else {
        self.selectedImageView.image = nil;
    }
}

@end
