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

#import "PADDeviceStateUtilities.h"

#import "PADEvent.h"

@implementation PADDeviceStateUtilities

#pragma mark - Public

+ (NSString *)messageTitleForDeviceState:(DeviceState)deviceState {
    NSString *messageTitle;
    switch (deviceState) {
        case DeviceStateOn:
            messageTitle = NSLocalizedString(@"LED On", nil);
            break;
        case DeviceStateOff:
            messageTitle = NSLocalizedString(@"LED Off", nil);
            break;
        case DeviceStateBlink:
            messageTitle = NSLocalizedString(@"LED Blink", nil);
            break;
        default:
            messageTitle = @"";
            break;
    }

    return messageTitle;
}

+ (NSString *)messageBodyForDeviceState:(DeviceState)deviceState {
    NSString *messageBody;
    switch (deviceState) {
        case DeviceStateOn:
            messageBody = @"{\"alert\": \"on\"}";
            break;
        case DeviceStateOff:
            messageBody = @"{\"alert\": \"off\"}";
            break;
        case DeviceStateBlink:
            messageBody = @"{\"alert\": \"blink\"}";
            break;
        default:
            messageBody = @"";
            break;
    }

    return messageBody;
}

+ (DeviceState)deviceStateFromDeviceStateString:(NSString *)deviceStateString {
    if ([deviceStateString isEqualToString:@"on"]) {
        return DeviceStateOn;
    } else if ([deviceStateString isEqualToString:@"blink"]) {
        return DeviceStateBlink;
    } else {
        return DeviceStateOff;
    }
}

+ (NSString *)deviceStateFromBlinkEvent:(PADEvent *)blinkEvent {
    return [blinkEvent.value objectForKey:@"state"];
}

@end
