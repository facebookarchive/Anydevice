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
 The `PADEvent` class is a local representation of an event sent from a connected device to a phone.
 This class is a subclass of a <PFObject>, and retains the same functionality of a <PFObject>,
 but also extends it with other event specific properties.
 */
@interface PADEvent : PFObject<PFSubclassing>

/*!
 @abstract Boolean that controls whether or not event notifications are to be sent

 @discussion Setting this to NO will prevent push notifications from being sent to the phone
 when the event is saved on the Parse cloud.
 */
@property (nonatomic, assign) BOOL alarm;

/*!
 @abstract Dictionary containing event information, such as state of the device.
 */
@property (nonatomic, strong) NSDictionary *value;

/*!
 @abstract Object ID for the installation from which the event originated.
 */
@property (nonatomic, strong) NSString *installationId;

/*!
 @abstract Date and time at which the event was created.
 */
@property (nonatomic, strong) NSDate *createdAt;

/*!
 @abstract Creates an `PADEvent` object from a dictionary

 @param dictionary Dictionary containing key value pairs for an event

 @return Returns a new `PADEvent` object.
 */
+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary;

@end
