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

@class PADEvent;
@class PADModel;

/*!
 The `PADInstallation` object is a local respresentation of an installation persisted to the Parse
 cloud. This class is a subclass of a <PFInstallation>. It overrides and extends certain
 <PFInstallation> functionality, but retains the same functionality of a <PFObject>.
 */
@interface PADInstallation : PFInstallation

/*!
 @abstract The device name for the installation.
 */
@property (nonatomic, strong) NSString *deviceName;

/*!
 @abstract The model for the installation.

 @see PADModel.h
 */
@property (nonatomic, strong) PADModel *model;

/*!
 @abstract The owner of the installation.

 @see PFUser.h
 */
@property (nonatomic, strong) PFUser *owner;

/*!
 @abstract The most recent event from the installation.

 @see PADEvent.h
 */
@property (nonatomic, strong) PADEvent *latestEvent;

@end
