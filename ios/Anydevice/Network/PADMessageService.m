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

#import "PADMessageService.h"

#import <Parse/Parse.h>

#import "PADInstallation.h"
#import "PADMessage.h"

@implementation PADMessageService

#pragma mark - Public

+ (void)sendDeviceState:(DeviceState)deviceState
         toInstallation:(PADInstallation *)installation
                success:(MessageSuccess)success
                failure:(Failure)failure
{
    PADMessage *messageObject = [PADMessage object];
    messageObject.owner = [PFUser currentUser];
    messageObject.installationId = installation.installationId;
    messageObject.format = @"text/json";
    messageObject.value = [PADDeviceStateUtilities messageBodyForDeviceState:deviceState];
    messageObject.ACL = [PFACL ACLWithUser:[PFUser currentUser]];

    [messageObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error && succeeded && success) {
            success();
        } else if(failure) {
            failure(error);
        }
    }];
}

@end
