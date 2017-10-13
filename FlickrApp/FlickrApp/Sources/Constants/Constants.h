//
//  Constants.h
//  FlickrApp
//
//  Created by Ahmad Ansari on 11/10/2017.
//  Copyright © 2017 Ahmad Ansari. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Notifications
extern NSString *const kNotifCoreDataResetPerformed;

#pragma mark - Keys
extern NSString *const kSearchedKeywords;

#pragma mark Colors HEX Codes
extern uintmax_t const kColorDefaultCellBackground;
extern uintmax_t const kColorForkedCellBackground;


#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelDebug;
#endif


/**
 *  Preferences Constants
 */
extern int const kFLRequestPageSize;
extern int const kFLSearchHistoryLimit;


@interface Constants : NSObject

@end
