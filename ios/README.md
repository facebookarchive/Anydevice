# Anydevice - iOS

Anydevice is an Internet of Things (IoT) sample application built on Parse. It
demonstrates the usage of Parse to enable communication between an iOS device
and an IoT device. The IoT device could theoretically be any hardware which runs
an [Embedded SDK](https://www.parse.com/products/iot). Specifically, this
application communicates with the Texas Instruments
[SimpleLink Wi-Fi CC3200 LaunchPad](http://www.ti.com/tool/cc3200-launchxl). We
will refer to this device as simply 'CC3200' throughout the README.

## CC3200 Setup

Refer to the [Quick Start for the CC3200](https://www.parse.com/apps/quickstart#embedded/ticc3200) to get your device set up.

## Parse Application Setup

Create a new app on [Parse](https://parse.com/apps). Your
Application ID, Master Key, and Client Key will be available to you under
`Settings > Keys`.

## Cloud Code Setup

Before using the iOS application, the Parse Application and associated Cloud
Code must be setup. Full instructions can be found in the [Cloud Code
repository](../cloud).

## iOS Setup

Anydevice requires Xcode 6 and iOS 8.

#### Setting up your Xcode project

1. Open the Xcode workspace at `Anydevice.xcworkspace`.

2. Copy your new Parse Application ID and Client Key into `PADConstants.m`.

  ```objective-c
  NSString * const PADApplicationId = @"YOUR_APPLICATION_ID";
  NSString * const PADClientKey = @"YOUR_CLIENT_KEY";
  ```

#### Setting up push notifications

In order to receive events that originate from a CC3200 device, you must
have push notifications set up. This
[tutorial](https://www.parse.com/tutorials/ios-push-notifications) provides full
push notification setup instructions.

## Application Overview

Anydevice allows you to control an LED on a CC3200 device, and to view the
current state of that LED. The LED has three states: On, Off, and Blinking.
Using Anydevice, you can send a message corresponding to one of these states
from a mobile device in order to change the LED's behavior. The LED state can
also be controlled from the CC3200 itself. When the LED state is updated on the
CC3200, a push notification is sent to the owner's mobile devices via Parse.
This way, Anydevice can correctly reflect the current state of the LED.

#### Provisioning the CC3200

In order to enable the communication between Anydevice and the CC3200 device,
the CC3200 device must go through a provisioning process whereby the device
registers on Parse and then connects to a wifi network. When you are adding a
new device via Anydevice, you are guided through the steps needed to complete
the device provisioning. An overview of the provisioning process is given below:

1. Once the '+' button on the home screen is tapped, the appropriate device
objects are created and initialized on Parse.

2. After initialization, you must connect to the CC3200's wireless access
point. The first step is to navigate to the Wi-Fi section in the iOS Settings
application.

3. Select the network corresponding to the CC3200 device's access point.

4. Upon connecting to the CC3200 device, navigate back to Anydevice. When you do
this, the connection with the CC3200 device is verified.

5. Confirm the provisioning details. These details include the wifi network SSID
to which the CC3200 device should connect along with the wifi password.

6. Send the network information to the CC3200 device. This will happen when the
'Done' button is tapped on the confirmation screen.

7. After provisioning begins, the CC3200 device will stop broadcasting its
access point. Anydevice will then attempt to reconnect to a wifi network
automatically.

8. Wait for the confirmation event which is sent from the CC3200 device after it
provisions successfully. The provisioning flow will dismiss automatically when
this event is received (the event is sent via a push notification).

#### Home Screen

The home screen in Anydevice displays a list of provisioned devices for the
currently logged in user. Each item contains the device name given during
provisioning, the hardware model name, and an icon associated with the hardware
model. Tapping on a device in the list will take you to the device details
screen for that device.

#### Device Details

This screen contains more detailed information about a specific device. This
includes the current LED state of the device and the most recent time the device
was in use. In addition to the current LED state, you can see the other LED
states available for the device. When you tap on an LED state, a message is sent
to the device which tells it to change the LED behavior accordingly. The device
responds to this message with a confirmation event containing the newly updated
LED state. The device details screen will update to reflect the new LED state
when this event is received.

## Application Architecture

### Data Model

Anydevice has seven data model classes that are persisted using the Parse cloud:
PADEvent, PADInfrastructureKey, PADInstallation, PADMessage, PADModel, PFUser
and PADUserSession.

##### PADEvent

The [PADEvent](Anydevice/Models/PADEvent.h) class represents an event that is
sent from a CC3200 device. The event has an `installationId` property which
identifies the device from which the event originated. The cloud code for the
Parse application can use this to determine the owner of the device, and a push
notification can then be sent to all mobile devices which have the same owner.
The `value` dictionary contains the event payload, which in Anydevice's case is
the LED state of the device.

##### PADInfrastructureKey

The [PADInfrastructureKey](Anydevice/Models/PADInfrastructureKey.h) class
represents a Wi-Fi network that was used to provision a CC3200 device. This
model is only created and stored on Parse when a user chooses to save the
network details for future provisioning attempts. If the user is connected to a
saved network, the saved network information is loaded automatically during the
user's next provisioning attempt. The saved information includes `ssid`,
`bssid`, `security` and `key`. The `key` property stores the network password
and `security` represents the security type of the network (None, WEP, or
WPA/WPA2) in integer format. The mapping between security type and the integers
is defined in the `SecurityType` enum.

##### PADInstallation

The [PADInstallation](Anydevice/Models/PADInstallation.h) class represents a
device that has been registered with Anydevice. This could be a mobile device
that has Anydevice installed, or it could be a CC3200 device that has been
provisioned from within Anydevice. `Installation` objects which have a valid
`deviceToken` can be used to target push notifications, as it is a subclass of
the `PFInstallation` class. Some of the properties are specific to CC3200
installations. The `model` property will contain a pointer to the `PADModel`
object corresponding to the specific hardware model of the CC3200 device. This
is simply empty for mobile device installations. The `deviceName` is the custom
name of the CC3200 device. Finally, the `latestEvent` property contains the
event that was most recently sent by the corresponding CC3200 device. This can
be used to find the current LED state of the CC3200 device in Anydevice.

##### PADMessage

The [PADMessage](Anydevice/Models/PADMessage.h) class represents an LED state
change message sent from Anydevice to a CC3200 device. A message has an
`installationId` property which identifies the CC3200 device to which the
message is being sent. The cloud code for the Parse application can use this to
send the message via push notification to the correct CC3200 device. The message
payload is stored in the `value` property. The payload format (e.g. text/json)
is specified in the `format` property.

##### PADModel

The [PADModel](Anydevice/Models/PADModel.h) class represents the hardware model
of a CC3200 device. It contains hardware model information such as the model
name and an icon specific to the model. The `default` boolean describes whether
the model should be used as a default when a CC3200 device's actual model cannot
be determined. There should only be one default model object stored in Parse.
The class level permission for this class will be set to 'Public: Read' (i.e.
read only), to prevent tampering with the pre-specified list of available
models.

##### PFUser

The `PFUser` class represents a user who has created an account from within
Anydevice. This class is a built in part of the Parse SDK, and there is no
custom behavior added to it in Anydevice. It contains user information that
allows Anydevice to identify the user and to authenticate login attempts. This
includes properties such as `username`, `password`, and `email`. The
`username` and `email` fields are unique for every user.

##### PADUserSession

The [PADUserSession](Anydevice/Models/PADUserSession.h) class represents a
session for a particular device. A session relates the owner of a device to the
device's installation by installation ID. The device could be a mobile device
that has Anydevice installed (e.g. a session is created when the user logs in
and gets deleted when they log out), or it could be a CC3200 device that has
been provisioned from within Anydevice (e.g. a session is created during
provisioning and is deleted when the user manually deletes the device).

### Authentication

A user must be signed up and logged in to Anydevice in order to use it. A login
interface is presented and managed by the
[PADLogInViewController](Anydevice/View\ Controllers/PADLogInViewController.h).
The user enters their username and password to log in. If the user needs to sign
up, they can navigate to the
[PADCreateAccountViewController](Anydevice/View\ Controllers/PADCreateAccountViewController.h)
from the login screen. This view controller presents and manages a sign up form.
There is also a screen which allows the user to generate a new password if they
forgot their existing one. This functionality is provided by
[PADForgotPasswordViewController](Anydevice/View\ Controllers/PADForgotPasswordViewController.h).

### Provisioning Architecture

As described in the [Provisioning](#provisioning-the-cc3200) section of the
application overview, the user must be guided through a number of steps in a
specific order when adding a new CC3200 device. This provisioning process is
modeled in code using a state machine. All possible provisioning steps are
described by the
[PADProvisioningStep](Anydevice/Models/PADProvisioningState.h) enum. There are a
few view controllers that work together in order to implement the state machine.

##### PADProvisioningContainerViewController
[PADProvisioningContainerViewController](Anydevice/View\ Controllers/PADProvisioningContainerViewController.h)
manages the entire flow for provisioning a new device. When the user taps the
`+` button to enter the provisioning flow, this view controller is presented
modally. It then creates and embeds the child view controller responsible for
handling the current provisioning step. The child view controller keeps a
reference to this view controller. When the child view controller is finished
handling the current step, it informs this view controller via the
[ProvisioningStepDelegate](Anydevice/View\ Controllers/PADProvisioningProtocols.h).
By calling the `swapViewControllerForCurrentStep` method on this view
controller, this view controller can create and embed the view controller
responsible for handling the next step. Here is an example:

When the provisioning flow starts, the `PADProvisioningContainerViewController`
embeds the view controller to handle the initial step:

```objective-c
self.provisioningState.currentStep = PADProvisioningStepInitialProvision;

// Perform a segue to embed the view controller which handles the beginning
// of the provisioning flow.
[self performSegueWithIdentifier:PADEmbedProvisioningFlowSegue sender:nil];

...

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Pass along the provisioning state and set up parent-child relationship reference.
    UIViewController<ProvisioningContainerChild> *childViewController = segue.destinationViewController;
    childViewController.provisioningState = self.provisioningState;
    childViewController.delegate = self;
}

```
When the child view controller is finished handling a sequence of steps, it
updates the current provisioning step and calls back to the
`PADProvisioningContainerViewController` using delegation:

```objective-c
switch (self.provisioningState.currentStep) {
    ...
    ...
    case ProvisioningStepConnected:
        // Navigate to the confirm provisioning details controller.
        self.provisioningState.currentStep = PADProvisioningStepConfirmDevice;
        [self.delegate swapViewControllerForCurrentStep];
        break;
    ...
}
```

The `PADProvisioningContainerViewController` can then create and present the
view controller for handling the next step:

```objective-c
- (void)swapViewControllerForCurrentStep {
    if (self.provisioningState.currentStep == PADProvisioningStepConfirmDevice) {
        ...
        // Perform a segue to embed the <PADConfirmProvisioningDetailsViewController>.
        [self performSegueWithIdentifier:PADEmbedConfirmDeviceSegue sender:nil];

    }
    ...
}
```

The provisioning flow continues this way until completion, at which point the
flow is dismissed by dismissing `PADProvisioningContainerViewController`.

##### Provisioning Child View Controllers

|PADMainProvisioningFlowViewController|PADConfirmProvisioningDetailsViewController|
|-------------------------------------|-------------------------------------------|
|This is a child view controller that is responsible for handling provisioning logic. Since many of the provisioning steps re-use the same interface, this view controller handles all of the provisioning steps except the provisioning details confirmation step. As a result, this view controller can handle the transition between steps itself. Calling back to `PADProvisioningContainerViewController` is only necessary when the confirm details step is reached, since this step is handled by the `PADConfirmProvisioningDetailsViewController`. | This is a child view controller that is responsible for handling the details confirmation step. This view controller presents an interface which allows the user to edit and confirm details such as device name and the wifi network information to use for provisioning. |

##### Provisioning State

As the provisioning flow progresses, state information is created and updated.
The [PADProvisioningState](Anydevice/Models/PADProvisioningState.h) class
encapsulates this information so that it can be passed between the
`PADProvisioningContainerViewController` and its child view controllers. For
example, the current provisioning step needs to be tracked throughout the
provisioning flow so that the view controllers know what logic to execute at
any given time.

### Home Screen

The [PADHomeViewController](Anydevice/View\ Controllers/PADHomeViewController.h)
manages the display of a list of devices provisioned by the currently logged in
user. It does this by fetching the `PADInstallation` objects that are owned by
the user and whose device type is 'embedded', and by displaying them in a
`UICollectionView`. The device list will be refreshed each time the user visits
the home screen. The collection view also has pull-to-refresh implemented for
manually refreshing the list. The user can navigate to the device details screen
for a particular device by tapping on a cell in the collection view.

### Device Details Screen

The [PADDeviceDetailsViewController](Anydevice/View\ Controllers/PADDeviceDetailsViewController.h)
manages the display of information for a specific CC3200 device. It is also
responsible for the interface which allows you to send an LED state change
message to the device. A device can be deleted if the trash icon on the top
right is tapped.

### Event Handling (Push Notifications)

When the LED state of a CC3200 device changes, an Event is created and saved in
the Parse cloud. After an Event is saved, the cloud code sends a push
notification to all mobile devices owned by the user of the CC3200 device.
Anydevice has push notification handling logic built into the
[AppDelegate](Anydevice/AppDelegate.m) class. There are two methods that can
be triggered when a push notification is received:

1. If Anydevice is already running when a push notification is received,
`application:didReceiveRemoteNotification:` method is called directly with the
push notification payload as a parameter.

2. If Anydevice is not running, and the application is launched by tapping on a
notification in Notification Center,
`application:didFinishLaunchingWithOptions:` is called. In this case, the push
notification payload is retrieved from the `launchOptions` dictionary.

In both of these cases, the logic for handling the notification payload is the
same. This logic resides in `handleEventWithPayload:applicationState:`. This
method decides how to handle the notification as follows:

First, the push notification is not processed if it is not an Event. There is
no action required for any other type of push notification.
```objective-c
- (void)handleEventWithPayload:(NSDictionary *)payload
              applicationState:(UIApplicationState)applicationState
{
    // If the notification is not an event, do nothing.
    NSString *pushActionString = [payload objectForKey:@"action"];
    if (![pushActionString isEqualToString:@"com.parse.anydevice.EVENT"]) {
      return;
    }
    ...
}
```

If the push notification is an Event, we can set up the local variables we need
for handling it.
```objective-c
...
NSDictionary *eventDictionary = [payload objectForKey:@"event"];
PADEvent *event = [PADEvent objectFromDictionary:eventDictionary];
NSString *userSessionId = [payload objectForKey:@"userSessionId"];
NSString *installationId = [payload objectForKey:@"installationId"];

// Get reference to the application's root view controller in preparation for deep linking.
UINavigationController *rootNavigationController = (UINavigationController *)self.window.rootViewController;
PADHomeViewController *homeViewController = (PADHomeViewController *)[rootNavigationController.viewControllers firstObject];

// Get a reference to the modally presented navigation controller, if there is one.
UINavigationController *modalNavigationController;
UIViewController *modalViewController = rootNavigationController.presentedViewController;
if ([modalViewController isKindOfClass:[UINavigationController class]]) {
    modalNavigationController = (UINavigationController *)modalViewController;
}
...
```

If the user is in the middle of the device provisioning flow, they may be
waiting for the provisioning success event. A notification is posted so that the
provisioning flow can handle this if necessary. No other action is needed in
this case.
```objective-c
...
if ([modalNavigationController.topViewController isKindOfClass:[PADProvisioningContainerViewController class]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PADProvisioningEventNotification
                                                            object:self
                                                          userInfo:@{@"userSessionId" : userSessionId}];
        return;
    }
...
```

If the user is already on the device details screen for the same device that
sent the event, we can just update the UI of that screen. When the `latestEvent`
property of the view controller is set, the UI update is triggered.
```objective-c
...
UIViewController *topViewController = rootNavigationController.topViewController;
if ([topViewController isKindOfClass:[PADDeviceDetailsViewController class]]) {
    PADDeviceDetailsViewController *deviceDetailsVC = (PADDeviceDetailsViewController *)topViewController;
    if ([deviceDetailsVC.installation.installationId isEqualToString:installationId]) {
        deviceDetailsVC.latestEvent = event;
        return;
    }
}
...
```

If Anydevice is active and the user is not on the device details screen for the
device that sent the event, then we discard the notification. We don't want to
navigate to a new screen while the user is using the application. If Anydevice
was not active when the notification was tapped, then we navigate to the
appropriate device details screen. This is done by first popping any view
controllers in the main navigation stack. Then, by providing the installation ID
from the Event payload, the `PADHomeScreenViewController` can determine which
`PADInstallation`'s details screen should be displayed.
```objective-c
...
if (applicationState != UIApplicationStateActive) {
    [rootNavigationController popToRootViewControllerAnimated:NO];
    [homeViewController navigateToDeviceDetailsForInstallationId:installationId
                                                       withEvent:event];

}
...
```

## Known Issues

* At the beginning of the provisioning flow, the user is instructed to navigate
to the iOS Settings to change their Wi-Fi network. A 'Go to Settings' button is
provided that will deep link into Settings automatically. However, this deep
link takes the user into the settings screen for Anydevice, and not the main
screen where the Wi-Fi settings can be found. The user must back out of the
Anydevice settings and scroll to the top of the main screen to find the Wi-Fi
settings. This issue cannot be fixed with the help of any public APIs since
Apple does not allow deep linking into specific sections of the Settings
application programmatically.

## License

Copyright (c) 2015, Parse, LLC. All rights reserved.

You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
copy, modify, and distribute this software in source code or binary form for use
in connection with the web services and APIs provided by Parse.

As with any software that integrates with the Parse platform, your use of
this software is subject to the
[Parse Terms of Service](https://www.parse.com/about/terms). This copyright
notice shall be included in all copies or substantial portions of the software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
