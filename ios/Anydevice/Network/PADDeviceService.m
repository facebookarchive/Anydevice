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

#import "PADDeviceService.h"

#import <Parse/Parse.h>

#import "PADConstants.h"
#import "PADInfrastructureKey.h"
#import "PADNetworkUtilities.h"
#import "PADUserSession.h"
#import "PADUtilities.h"

@implementation PADDeviceService

#pragma mark - Public

+ (void)postWifiCredentials:(PADInfrastructureKey *)wifiCredentials
              andDeviceName:(NSString *)deviceName
              toUserSession:(PADUserSession *)userSession
{
    NSString *securityType = [NSString stringWithFormat:@"%@", wifiCredentials.security];

    // The order of the parameters is specific to the application running on the device.
    NSDictionary *postBody = @{@"__SL_P_USA" : wifiCredentials.ssid,
                               @"__SL_P_USB" : securityType,
                               @"__SL_P_USC" : wifiCredentials.key,
                               @"__SL_P_USD" : PADApplicationId,
                               @"__SL_P_USE" : PADClientKey,
                               @"__SL_P_USF" : [PADUtilities generateUUID],
                               @"__SL_P_USG" : userSession.sessionToken,
                               @"__SL_P_USH" : deviceName,
                               @"__SL_P_USZ" : @"Add"};

    NSURL *deviceUrl = [NSURL URLWithString:PADDeviceUrl];
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:deviceUrl];
    postRequest.HTTPMethod = @"POST";
    [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    postRequest.HTTPBody = [PADNetworkUtilities urlEncodedFormBodyFromDictionary:postBody];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *postTask = [session dataTaskWithRequest:postRequest
                                                completionHandler:nil];

    [postTask resume];
}

@end
