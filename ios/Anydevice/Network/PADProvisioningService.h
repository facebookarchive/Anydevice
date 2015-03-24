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

@class PADInstallation;
@class PADModel;
@class PADUserSession;

/*!
 `PADProvisionSuccess` is a block that takes a <PADUserSession> object as a parameter.

 @param PADUserSession <PADUserSession> object.
 */
typedef void (^PADProvisionSuccess)(PADUserSession *);

/*!
 `ProvisioningFetchSuccess` is a block that takes an <NSArray> object as a parameter.

 @param NSArray Array of <PADInstallation> objects.
 */
typedef void (^PADProvisionFetchSuccessBlock)(NSArray *);

/*!
 `Success` is a block that takes no parameters.
 */
typedef void (^Success)();

/*!
 `PADProvisionFailureBlock` is a block that takes an <NSError> object as a parameter.

 @param NSError Contains error description.
 */
typedef void (^PADProvisionFailureBlock)(NSError *);

/*!
 `PADProvisioningService` provides methods to provision a new device and maintain provisioned
 devices.
 */
@interface PADProvisioningService : NSObject

/*!
 @abstract Starts the provisioning process by creating a new user session on the Parse cloud.

 @param success Success block to be executed when the session is created successfully.
 @param failure Failure block to be executed if session creation fails.
 */
+ (void)startProvisioningNewDeviceWithSuccess:(PADProvisionSuccess)success
                                      failure:(PADProvisionFailureBlock)failure;

/*!
 @abstract Deletes a connected device from the parse cloud.

 @param userSession <PADUserSession> object for the device to be deleted.
 @param success     Success block to be executed when the device is deleted successfully.
 @param failure     Failure block to be executed when the device deletion fails.

 @see PADUserSession.h
 */
+ (void)deleteDeviceWithUserSession:(PADUserSession *)userSession
                            success:(Success)success
                            failure:(PADProvisionFailureBlock)failure;

/*!
 @abstract Fetches the list of provisioned devices for the user currently logged into the
 application.

 @param success Success block to be executed when the provisioned devices are fetched.
 @param failure Failure block to be executed when the fetch operation fails.
 */
+ (void)fetchProvisionedDevicesWithSuccess:(PADProvisionFetchSuccessBlock)success
                                   failure:(PADProvisionFailureBlock)failure;

/*!
 @abstract Fetches the session object associated with the given connected device.

 @param success Success block to be executed when the session is fetched successfully.
 @param failure Failure block to be executed when the session fetch fails.
 */
+ (void)fetchUserSessionForInstallation:(PADInstallation *)installation
                                success:(PADProvisionSuccess)success
                                failure:(PADProvisionFailureBlock)failure;

/*!
 @abstract Updates the phone's installation to reflect the currently logged in user.
 */
+ (void)updateCurrentPhoneInstallation;

@end
