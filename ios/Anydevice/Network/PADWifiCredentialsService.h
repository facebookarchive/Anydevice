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

@class PADInfrastructureKey;

/*!
 `PADInfrastructureKeySuccessBlock` is a block that takes an <PADInfrastructureKey> object as parameter.

 @param PADInfrastructureKey Contains Wifi access point's information.

 @see PADInfrastructureKey.h
 */
typedef void(^PADInfrastructureKeySuccessBlock)(PADInfrastructureKey *);

/*!
 `Failure` is a block that takes an <NSError> object as a parameter.

 @param NSError Contains error description.
 */
typedef void(^Failure)(NSError *);

/*!
 `PADWifiCredentialsService` provides methods for retrieving the current network's wifi credentials
 from the Parse cloud.
 */
@interface PADWifiCredentialsService : NSObject

/*!
 @abstract Loads the wifi credentials for the current network.

 @param success Success block to be executed when wifi credentials are retrieved successfully.
 @param failure Failure block to be executed when the operation to retrieve wifi credentials failed.

 @see PADInfrastructureKey.h
 */
+ (void)currentWifiCredentialsWithSuccess:(PADInfrastructureKeySuccessBlock)success
                                  failure:(Failure)failure;

@end
