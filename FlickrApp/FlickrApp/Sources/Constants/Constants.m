//
//  Constants.m
//  FlickrApp
//
//  Created by Ahmad Ansari on 11/10/2017.
//  Copyright © 2017 Ahmad Ansari. All rights reserved.
//

#import "Constants.h"

#pragma mark - Notification Names
NSString *const kNotifCoreDataResetPerformed = @"NotifCoreDataResetPerformed";

#pragma mark - Keys
NSString *const kSearchedKeywords = @"SearchedKeywords";

#pragma mark Colors HEX Codes
uintmax_t const kColorDefaultCellBackground = 0xF2F2F2; //Light Gray
uintmax_t const kColorForkedCellBackground = 0xCCFF66;//Light Green

/**
 *  Preferences Constants
 */
int const kFLRequestPageSize = 50;
int const kFLSearchHistoryLimit = 20;

@implementation Constants

@end
