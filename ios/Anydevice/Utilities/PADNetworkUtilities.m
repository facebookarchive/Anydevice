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

#import "PADNetworkUtilities.h"

@implementation PADNetworkUtilities

#pragma mark - Public

+ (NSDictionary *)currentNetworkInformation {
    CFArrayRef networkInterfaces = CNCopySupportedInterfaces();
    if (!networkInterfaces) {
        return nil;
    }

    CFStringRef currentNetworkInterface = CFArrayGetValueAtIndex(networkInterfaces, 0);
    CFDictionaryRef cfCurrentNetworkInfo = CNCopyCurrentNetworkInfo(currentNetworkInterface);
    CFRelease(networkInterfaces);

    return (__bridge_transfer NSDictionary *)cfCurrentNetworkInfo;
}

+ (NSData *)urlEncodedFormBodyFromDictionary:(NSDictionary *)dictionary {
    NSMutableString *urlEncodedFormBodyString = [NSMutableString string];
    BOOL first = true;

    for (NSString *key in dictionary.allKeys) {
        NSString *encodedKey = [self urlEncodedStringFromString:key];
        NSString *encodedValue = [self urlEncodedStringFromString:[dictionary objectForKey:key]];

        NSString *parameter;

        // For the first parameter, no & is to be added.
        if(first) {
            first = false;
            parameter = [NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue];
        } else {
            parameter = [NSString stringWithFormat:@"&%@=%@", encodedKey, encodedValue];
        }

        [urlEncodedFormBodyString appendString:parameter];
    }

    return [urlEncodedFormBodyString dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *)securityStringFromSecurityType:(SecurityType)securityType {
    switch (securityType) {
        case SecurityTypeNone:
            return NSLocalizedString(@"None", nil);
        case SecurityTypeWEP:
            return NSLocalizedString(@"WEP", @"Wired Equivalent Privacy");
        case SecurityTypeWPA_WPA2:
            return NSLocalizedString(@"WPA/WPA2", @"Wi-Fi Protected Access");
        default:
            return @"";
    }
}

#pragma mark - Private

/*!
 @abstract Creates a URL encoded string for a given string by escaping the characters specified by
 RFC 3986.

 @discussion Spaces are replaced with '+' as required by the x-www-form-urlencoded content type.

 @see http://tools.ietf.org/html/rfc3986#section-2.2

 @param string String to be encoded.

 @return Returns the url encoded version of the given string.
 */
+ (NSString *)urlEncodedStringFromString:(NSString *)string {
    CFStringRef charactersToEscape = (CFStringRef)@"!*'();:@&=+$,/?%#[]";
    CFStringRef charactersToLeaveUnescaped = (CFStringRef)@" ";
    CFStringRef cfString = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                   (__bridge CFStringRef)string,
                                                                   charactersToLeaveUnescaped,
                                                                   charactersToEscape,
                                                                   kCFStringEncodingUTF8);

    NSString *encodedString = (__bridge_transfer NSString *)cfString;
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@" " withString:@"+"];

    return encodedString;
}

@end
