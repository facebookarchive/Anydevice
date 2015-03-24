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

#import "PADProvisioningService.h"

#import <Parse/Parse.h>

#import "PADInstallation.h"
#import "PADModel.h"
#import "PADReachability.h"
#import "PADUserSession.h"
#import "PADUtilities.h"

// Connected device type information specific to this application.
static NSString *const PADInstallationDeviceType = @"embedded";

@implementation PADProvisioningService

#pragma mark - Public

+ (void)startProvisioningNewDeviceWithSuccess:(PADProvisionSuccess)success
                                      failure:(PADProvisionFailureBlock)failure
{
    PADUserSession *userSession = [PADUserSession object];

    [userSession saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error && succeeded && success) {
            success(userSession);
        } else {
            [self handleFailureWithBlock:failure error:error];
        }
    }];
}

+ (void)deleteDeviceWithUserSession:(PADUserSession *)userSession
                            success:(Success)success
                            failure:(PADProvisionFailureBlock)failure
{
    [userSession deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error && succeeded && success) {
            success();
        } else {
            [self handleFailureWithBlock:failure error:error];
        }
    }];
}

+ (void)fetchProvisionedDevicesWithSuccess:(PADProvisionFetchSuccessBlock)success
                                   failure:(PADProvisionFailureBlock)failure
{
    PFQuery *installationQuery = [PADInstallation query];
    PFQuery *userSessionQuery = [PFQuery queryWithClassName:[PADUserSession parseClassName]];
    [installationQuery whereKey:@"installationId"
                     matchesKey:@"installationId"
                        inQuery:userSessionQuery];

    [installationQuery includeKey:@"model"];
    [installationQuery includeKey:@"latestEvent"];
    [installationQuery whereKey:@"deviceType" equalTo:PADInstallationDeviceType];
    [installationQuery orderByDescending:@"createdAt"];

    [installationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error && success) {
            success(objects);
        } else {
            [self handleFailureWithBlock:failure error:error];
        }
    }];
}

+ (void)fetchUserSessionForInstallation:(PADInstallation *)installation
                                success:(PADProvisionSuccess)success
                                failure:(PADProvisionFailureBlock)failure
{
    PFQuery *userSessionQuery = [PFQuery queryWithClassName:[PADUserSession parseClassName]];
    [userSessionQuery whereKey:@"installationId" equalTo:installation.installationId];
    userSessionQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;

    [userSessionQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        PADUserSession *userSession = (PADUserSession *)object;
        if (!error && success) {
            success(userSession);
        } else {
            [self handleFailureWithBlock:failure error:error];
        }
    }];
}

+ (void)updateCurrentPhoneInstallation {
    PADInstallation *currentInstallation = [PADInstallation currentInstallation];
    currentInstallation.owner = [PFUser currentUser];
    [currentInstallation saveInBackground];
}

#pragma mark - Private

+ (void)handleFailureWithBlock:(PADProvisionFailureBlock)block error:(NSError *)error {
    if (error && block) {
        block(error);
    }
}

@end
