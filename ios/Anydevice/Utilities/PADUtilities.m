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

#import "PADUtilities.h"

#import <UIKit/UIKit.h>

@implementation PADUtilities

#pragma mark - Public

+ (NSString *)generateUUID {
    return [[[NSUUID UUID] UUIDString] lowercaseString];
}

+ (NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"h:mma dd MMM yy";
    return [dateFormatter stringFromDate:date];
}

+ (NSDate *)dateFromString:(NSString *)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

    // The dates strings we are coverting are GMT time.
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    return [dateFormatter dateFromString:string];
}

+ (NSString *)modelIdentiferFromSSID:(NSString *)SSID {
    // Find first occurrence of '-'.
    NSRange range = [SSID rangeOfString:@"-"];

    // If a '-' is not found or it is the only character in the SSID, return the entire SSID.
    if (range.location == NSNotFound || range.location >= ([SSID length] - 1)) {
        return SSID;
    }

    NSString *parsedSSID = [SSID substringFromIndex:(range.location + 1)];

    // Find the second occurrence of '-'. If not found, return what we have.
    range = [parsedSSID rangeOfString:@"-"];
    if (range.location == NSNotFound) {
        return parsedSSID;
    }

    // Return the substring that was in between the '-' characters.
    return [parsedSSID substringToIndex:range.location];
}

@end
