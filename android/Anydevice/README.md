# Anydevice - Android

Anydevice is an Internet of Things (IoT) sample application built on Parse. It
demonstrates the usage of Parse to enable communication between an Android device
and an IoT device. The IoT device could theoretically be any hardware which runs
an [Embedded SDK](https://www.parse.com/products/iot). Specifically, this
application communicates with the Texas Instruments
[SimpleLink Wi-Fi CC3200 LaunchPad](http://www.ti.com/tool/cc3200-launchxl). We
will refer to this device as simply CC3200 throughout the README.

## CC3200 Setup

Refer to the [Quick Start for the CC3200](https://www.parse.com/apps/quickstart#embedded/ticc3200) to get your device set up.

## Parse Application Setup

Create a new app on [Parse](https://parse.com/apps). Your Application ID
and Client Key will be available to you under `Settings > Keys`.

## Cloud Code Setup

Before using the Android application, the Parse Application and associated
Cloud Code must be setup. Full instructions can be found in the [Cloud Code
repository](../../cloud).

## Android Setup

1. Open Android Studio and choose Import project.
2. Choose the Anydevice/build.gradle file
3. Copy your Parse Application ID and Client Key into `app/build.gradle`.

```java
buildConfigField "String", "PARSE_APP_ID", "\"YOUR_APPLICATION_ID\""
buildConfigField "String", "PARSE_CLIENT_KEY", "\"YOUR_PARSE_CLIENT_KEY\""
```

#### Setting up push notifications

In order to receive events that originate from a CC3200 device, you must have push notifications set up. This [tutorial](https://www.parse.com/tutorials/android-push-notifications) provides full push notification setup instructions.

## Application Overview

Anydevice allows you to control an LED on a CC3200 device, and to view the current state of that LED. The LED has three states: On, Off, and Blinking. Using Anydevice, you can send a message corresponding to one of these states from a mobile device in order to change the LED's behavior. The LED state can also be controlled from the CC3200 itself. When the LED state is updated on the CC3200, a push notification is sent to the owner's mobile devices via Parse. This way, Anydevice can correctly reflect the current state of the LED.

#### Home Screen (Registered Devices)

The home screen in Anydevice displays a list of the current user's provisioned devices. Each item contains the device name, the hardware model name, and an icon associated with the hardware. Tapping on a device in the list will take you to the [Device Details](#device-details) screen for that device. At the bottom of this page, there is a `+` button that will take you to the unregistered devices screen.

#### Unregistered Devices Screen

The unregistered devices screen performs a scan of access points in the area, and presents a list of detected devices that are currently broadcasting with recognized prefixes (such as `TL04`) for their SSIDs. Each item displays the SSID and board type with a `+` button on the right hand side. Clicking one of these buttons will bring up the [Set Up Device](#set-up-device-dialog) dialog.

#### Set Up Device Dialog

The `Set Up Device` Dialog prompts the user to enter:

1. A name for the device
2. SSID of the Internet connected WiFi
3. Security type (WEP/WPA/WPA2/None)
4. WiFi Password

When the user presses `Add Device` the device begins provisioning.

#### Provisioning the CC3200

To communicate with a mobile phone a device requires a network connection and a session on Parse. The provisioning process is executed by the [ProvisioningDispatcher](app/src/main/java/com/parse/anydevice/provisioning/ProvisioningDispatcher.java). The steps are:

1. Create a new UserSession on Parse for the device
2. Connect to the device via its wifi access point
3. Send generated installation UUID, session token, and wifi information to the device
4. Disconnect from the device and reconnect to the original wifi network
5. Wait for an event from the device to confirm the board's connection


#### Device Details

This screen contains more detailed information about a specific device. This includes the current LED state of the device and the most recent time the device was in use. In addition to the current LED state, you can see the other LED states available for the device. Tapping on an LED state sends a message to the device which updates the LED behavior accordingly. The device responds to this message with a confirmation event containing the newly updated LED state. The device details screen will update to reflect the new LED state when this event is received.

## Application Architecture

### Data Model

Anydevice has six data models: Event, InfrastructureKey, Installation, Message, Model, and UserSession.

##### Event

The [Event](app/src/main/java/com/parse/anydevice/models/Event.java) class represents an event that is sent from a CC3200 device. The event has an `installationId` property which identifies the device from which the event originated. The cloud code for the Parse application can use this to determine the owner of the device, and a push notification can then be sent to all mobile devices which have the same owner. The `value` JSONObject contains the event payload, which in Anydevice's case is the LED state of the device. During the provisioning process, an additional field `userSessionId` is used to check that the provisioning succeeded.

##### InfrastructureKey

The [InfrastructureKey](app/src/main/java/com/parse/anydevice/models/InfrastructureKey.java) class represents a Wi-Fi network that was used to provision the CC3200 device. This model is only created and stored on Parse when a user chooses to save the network details for future provisioning attempts. If the user is connected to a saved network, the saved network information is loaded automatically during the user's next provisioning attempt. The saved information includes `ssid`, `bssid`, `security` and `key`. The `key` property stores the network password and `security` represents the security type of the network (None, WEP, or WPA/WPA2) in integer format.

##### Installation

The [Installation](app/src/main/java/com/parse/anydevice/models/Installation.java) class represents a device that has been registered with Anydevice. This could be a mobile device that has Anydevice installed or it could be an embedded device that has been provisioned from within Anydevice. `Installation` objects which have a valid `deviceToken` can be used to target push notifications, as it is a subclass of the `ParseInstallation` class. Some of the properties are specific to embedded device installations. The `model` property will contain a pointer to the [Model](#model) object corresponding to the specific hardware model of the embedded device. This is empty for mobile device installations. The `deviceName` is the custom name of the CC3200 device. Finally, the `latestEvent` property contains the [Event](#event) that was most recently sent by the corresponding CC3200 device, which can be used to find the current LED state.

##### Message

The [Message](app/src/main/java/com/parse/anydevice/models/Message.java) class represents an LED state change message sent from Anydevice to a CC3200 device. A message has an `installationId` property which identifies the embedded device to which the message is being sent. The cloud code for the Parse application can use this to send the message via push notification to the correct device. The message payload is stored in the `value` property. The payload format (e.g. text/json) is specified in the `format` property.

##### Model

The [Model](app/src/main/java/com/parse/anydevice/models/Model.java) class represents the hardware model of an embedded device. It contains hardware model information such as the model name and an icon specific to the model. The `default` boolean describes whether the model should be used as a default when a device's actual model cannot be determined. There should only be one default model object stored in Parse. The `boardType` specifies the hardware model name and `icon` stores the model icon. The class level permission for this class will be set to 'Public: Read' (i.e. read only), to prevent tampering with the pre-specified list of available models.


##### UserSession

The [UserSession](app/src/main/java/com/parse/anydevice/models/UserSession.java) class represents a session for a particular device. This class is a small convenience extension of the `ParseSession` class in the Parse SDK. It contains a session token, expiry date, and installation ID.

### Authentication

A user must be signed up and logged in to Anydevice in order to use it. The login flow is presented using the [ParseUI Login](https://github.com/ParsePlatform/ParseUI-Android). Once a user is authenticated they are brought to the [Registered Devices](#home-screen-registered-devices)) screen.


## Known Issues

* Some Android 4.2 devices with dual-band (2.4 and 5GHz) WiFi take some time to detect the board's AP. The scan will work if under `Settings -> WiFi -> Advanced` you change `Wi-Fi Frequency Band` from `Auto` to `2.4 GHz only`.

## License

Copyright (c) 2015, Parse, LLC. All rights reserved.

You are hereby granted a non-exclusive, worldwide, royalty-free license to use, copy, modify, and distribute this software in source code or binary form for use in connection with the web services and APIs provided by Parse.

As with any software that integrates with the Parse platform, your use of this software is subject to the [Parse Terms of Service](https://www.parse.com/about/terms). This copyright notice shall be included in all copies or substantial portions of the software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
