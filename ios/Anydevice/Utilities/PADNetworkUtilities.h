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
#import <SystemConfiguration/CaptiveNetwork.h>

#import "PADInfrastructureKey.h"

/*!
 `PADNetworkUtilities` provides utilities for getting network-related information and for performing
 network-related tasks.
 */
@interface PADNetworkUtilities : NSObject

/*!
 @abstract Retrieves network information about the access point to which the phone is currently
 connected. This includes information such as network SSID and BSSID.

 @see CaptiveNetwork.h in the SystemConfiguration framework.

 @return Returns a dictionary containing the network information.
 */
+ (NSDictionary *)currentNetworkInformation;

/*!
 @abstract Converts a dictionary of name/value parameters to an http POST request body using the
 application/x-www-form-urlencoded MIME type.

 @param dictionary <NSDictionary> of name/value parameters.

 @return Returns the http POST body corresponding to the given parameters as an <NSData> object.
 */
+ (NSData *)urlEncodedFormBodyFromDictionary:(NSDictionary *)dictionary;

/*!
 @abstract Creates a user facing string representation for a network security type.

 @param securityType <SecurityType> enum.

 @return Returns a user facing string representation of the security type.

 @see PADInfrastructureKey.h
 */
+ (NSString *)securityStringFromSecurityType:(SecurityType)securityType;

@end
