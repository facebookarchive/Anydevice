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

#import "PADWifiCredentialsService.h"

#import <Parse/Parse.h>

#import "PADInfrastructureKey.h"
#import "PADNetworkUtilities.h"

@implementation PADWifiCredentialsService

#pragma mark - Public

+ (void)currentWifiCredentialsWithSuccess:(PADInfrastructureKeySuccessBlock)success
                                  failure:(Failure)failure
{
    NSDictionary *currentWifiInformation = [PADNetworkUtilities currentNetworkInformation];
    if (!currentWifiInformation) {
        if (failure) {
            failure(nil);
        }

        return;
    }

    // Set up default credentials object for this network in case no credentials are loaded from the
    // Parse cloud
    PADInfrastructureKey *wifiCredentials = [PADInfrastructureKey object];
    wifiCredentials = [PADInfrastructureKey object];
    NSString *SSIDKey = (__bridge NSString *)kCNNetworkInfoKeySSID;
    NSString *BSSIDKey = (__bridge NSString *)kCNNetworkInfoKeyBSSID;
    wifiCredentials.ssid = [currentWifiInformation objectForKey:SSIDKey];
    wifiCredentials.bssid = [currentWifiInformation objectForKey:BSSIDKey];
    wifiCredentials.security = @(SecurityTypeNone);

    [self loadWifiCredentialsForSSID:wifiCredentials.ssid
                               BSSID:wifiCredentials.bssid
                             success:^(PADInfrastructureKey *savedWifiCredentials) {
         if (success) {
             success(savedWifiCredentials);
         }
    } failure:^(NSError *error) {
        // Look up failed, assume we have never saved this network's credentials before and
        // return the default info.
        if (success) {
            success(wifiCredentials);
        }
    }];
}

#pragma mark - Private

/*!
 @abstract Loads the wifi credentials from the Parse cloud for the network identified by the given
 SSID and BSSID.

 @param SSID    SSID (Service Set Identifier) of the network.
 @param BSSID   BSSID (Basic Service Set Identifier) of the network.
 @param success Success block to be executed when credentials are loaded successfully.
 @param failure Failure block to be executed when loading of credentials fails.
 */
+ (void)loadWifiCredentialsForSSID:(NSString *)SSID
                             BSSID:(NSString *)BSSID
                           success:(PADInfrastructureKeySuccessBlock)success
                           failure:(Failure)failure
{
    PFQuery *query = [PFQuery queryWithClassName:[PADInfrastructureKey parseClassName]];
    [query whereKey:@"ssid" equalTo:SSID];
    [query whereKey:@"bssid" equalTo:BSSID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *savedWifiCredentials, NSError *error) {
        if (!error && savedWifiCredentials && success) {
            success((PADInfrastructureKey *)savedWifiCredentials);
        } else if (failure) {
            failure(error);
        }
    }];
}

@end
