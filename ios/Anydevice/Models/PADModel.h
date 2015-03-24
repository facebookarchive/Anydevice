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
 The `PADModel` class is a local representation of the connected device model information. This
 class is a subclass of a <PFObject>, and retains the same functionality of a <PFObject>, but
 also extends it with various model properties for a connected device.
 */
@interface PADModel : PFObject<PFSubclassing>

/*!
 @abstract Unique identifier for a model.

 @discussion This identifier can be retrieved from the connected device's access point SSID.
 */
@property (nonatomic, strong) NSString *appName;

/*!
 @abstract The hardware model name of the connected device.
 */
@property (nonatomic, strong) NSString *boardType;

/*!
 @abstract Indicates whether this model should be used for a connected device whose model
 cannot properly be determined.

 @discussion This should be YES for only one of the models stored on the Parse cloud.
 */
@property (nonatomic, assign, readonly) BOOL isDefault;

/*!
 @abstract Icon for the model

 @see PFFile.h
 */
@property (nonatomic, strong) PFFile *icon;

@end
