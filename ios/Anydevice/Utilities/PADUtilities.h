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
 `PADUtilities` provides miscellaneous utilities for various kinds of tasks such as date-string
 conversions, generating a random UUID, etc.
 */
@interface PADUtilities : NSObject

/*!
 @abstract Generates a random UUID.

 @return Returns the generated UUID.
 */
+ (NSString *)generateUUID;

/*!
 @abstract Converts a date object to a string with the format `h:mma dd MMM yy`.

 @discussion E.g. `12:30PM 27 Feb 2015`.

 @param date <NSDate> object.

 @return Returns the formatted date string.
 */
+ (NSString *)stringFromDate:(NSDate *)date;

/*!
 @abstract Converts a date in string format to an <NSDate> object.

 @param string Date in string format. This date string is assumed to follow the format
 `yyyy-MM-dd'T'HH:mm:ss.SSS'Z'`. E.g. `2015-02-27T19:19:53.929Z`

 @discussion The time portion of the string is assumed to be GMT time.

 @return Returns the passed date as an <NSDate> object.
 */
+ (NSDate *)dateFromString:(NSString *)string;

/*!
 @abstract Parses an SSID of a connected device in string format to retrieve the unique identifier
 for the hardware model.

 @discussion Expects the SSID to be in the format <string>-<model identifier>-<string>,
 e.g. `TL04-fbdr000001a-292F68`.

 @param SSID The Service set identifier of a wireless LAN.

 @return Returns the model identifier.
 */
+ (NSString *)modelIdentiferFromSSID:(NSString *)SSID;

@end
