//
//  NSNotificationCenter+Additions.h
//  XProject
//
//  Created by Ahmad Ansari on 5/19/16.
//  Copyright © 2016 Acacus Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (Additions)

- (void)postNotificationOnMainThread:(NSNotification *)notification;
- (void)postNotificationOnMainThread:(NSNotification *)notification
                       waitUntilDone:(BOOL)wait;

- (void)postNotificationOnMainThreadWithName:(NSString *)name object:(id)object;
- (void)postNotificationOnMainThreadWithName:(NSString *)name
                                      object:(id)object
                                    userInfo:(NSDictionary *)userInfo;
- (void)postNotificationOnMainThreadWithName:(NSString *)name
                                      object:(id)object
                                    userInfo:(NSDictionary *)userInfo
                               waitUntilDone:(BOOL)wait;

@end
