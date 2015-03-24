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

#import <Parse/Parse.h>

/*!
 The `PADMessage` class is a local representation of messages sent from a phone to a device. This
 class is a subclass of a <PFObject>, and retains the same functionality of a <PFObject>, but
 also extends it with various message specific properties.
 */
@interface PADMessage : PFObject<PFSubclassing>

/*!
 @abstract The owner of the message.

 @see PFUser.h
 */
@property (nonatomic, strong) PFUser *owner;

/*!
 @abstract The installationId of the <PADInstallation> which sent the message.
 */
@property (nonatomic, strong) NSString *installationId;

/*!
 @abstract The format of the message body.

 @discussion For example, when sending a JSON message, the format is 'text/json'.
 */
@property (nonatomic, strong) NSString *format;

/*!
 @abstract The body of the message.
 */
@property (nonatomic, strong) NSString *value;

@end
