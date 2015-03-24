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

#import "PADEvent.h"

#import "PADUtilities.h"

@implementation PADEvent

@dynamic alarm;
@dynamic value;
@dynamic installationId;
@dynamic createdAt;

#pragma mark - NSObject

+ (void)load {
    [self registerSubclass];
}

#pragma mark - <PFSubclassing>

+ (NSString *)parseClassName {
    return @"Event";
}

#pragma mark - Public

+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary {
    PADEvent *event = [PADEvent object];
    event.objectId = [dictionary objectForKey:@"objectId"];
    event.alarm = [[dictionary objectForKey:@"alarm"] boolValue];
    event.installationId = [dictionary objectForKey:@"installationId"];
    event.value = [dictionary objectForKey:@"value"];
    NSString *timeString = [dictionary objectForKey:@"createdAt"];
    event.createdAt = [PADUtilities dateFromString:timeString];
    return event;
}

@end
