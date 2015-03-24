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
@class PADUserSession;

/*!
 `ProvisioningStep` enum describes all the steps involved in the provisioning of a new device.
 */
typedef NS_ENUM(NSUInteger, PADProvisioningStep) {
    /*! Initial installation creation */
    PADProvisioningStepInitialProvision = 0,

    /*!
     Initial installation creation failed -
     Phone is connected to a device (no internet connection)
     */
    PADProvisioningStepInitialProvisionConnectedToBoard,

    /*! Initial installation creation failed */
    PADProvisioningStepInitialProvisionFailed,

    /*! Go to wifi instructional screen */
    PADProvisioningStepGoToWifi,

    /*! Connecting to the device */
    PADProvisioningStepConnecting,

    /*! Connecting to the device failed */
    PADProvisioningStepConnectionFailed,

    /*! Device connection success screen */
    PADProvisioningStepConnected,

    /*! Confirm device and network details */
    PADProvisioningStepConfirmDevice,

    /*! Disconnecting from the device */
    PADProvisioningStepDisconnecting,

    /*! Reconnecting to wifi network */
    PADProvisioningStepReconnecting,

    /*! Reconnecting to wifi failed */
    PADProvisioningStepReconnectingFailed,

    /*! Waiting for provisioning success event from the device */
    PADProvisioningStepWaitingForEvent,

    /*! Failed to receive the provisioning success event */
    PADProvisioningStepEventFailed
};

/*!
 The `PADProvisioningState` class represents the states and properties involved in the provisioning
 of a new device. The current state of provisioning can then be passed between steps (e.g. if
 different steps in the provisioning flow are implemented with different view controllers).
 */
@interface PADProvisioningState : NSObject

/*!
 @abstract The current step in the provisioning of a new device.

 @see `PADProvisioningStep` enum above
 */
@property (nonatomic, assign) PADProvisioningStep currentStep;

/*!
 @abstract The string that uniquely identifies the hardware model of the device being provisioned.

 @discussion This model identifier is broadcasted as part of the device access point's SSID.
 */
@property (nonatomic, strong) NSString *modelIdentifier;

/*!
 @abstract The <PADUserSession> object of the new device being provisioned.

 @discussion The <PADUserSession> contains the owner of the device and the device's installation.

 @see PADUserSession.h
 */
@property (nonatomic, strong) PADUserSession *userSession;

/*!
 @abstract Network information for an access point.

 @discussion This object stores the wifi information of the access point that the user was
 connected to before connecting and sending information to the device.

 @see PADInfrastructureKey.h
 */
@property (nonatomic, strong) PADInfrastructureKey *wifiCredentials;

/*!
 @abstract Boolean representing whether the wifi credentials sent to the device should be saved
 to the Parse cloud.
 */
@property (nonatomic, assign) BOOL shouldSaveWifiCredentials;

@end
