//
//  FLDefines.h
//  FlickrApp
//
//  Created by Ahmad Ansari on 11/10/2017.
//  Copyright © 2017 Ahmad Ansari. All rights reserved.
//

#ifndef FLDefines_h
#define FLDefines_h

/****************************************************************************/
#pragma mark - Core Data Store Constants

/**
 *
 *  XCDataModel File Name.
 */
#define kXCDataModelFile @"FlickrModel"

/**
 *  XCDataModel type. momd describes as versioned Model.
 */
#define kXCDataModelType @"momd"

/*!
 @discussion
 Persistence Data Store Type.
 */
#define kXCDataStoreType @"sqlite"

/*!
 @discussion
 Persistence Data File Name with extension.
 */
#define kXCDataSQLiteFile [NSString stringWithFormat:@"%@.sqlite", kXCDataModelFile]



//Service URLS
#define FLICKR_API_KEY @"3e7cc266ae2b0e0d78e279ce8e361736"
#define FL_BASE_URL @"https://api.flickr.com"
#define FL_PHOTO_LIST_URL @"https://api.flickr.com/services/rest"
/*
 * Flickr Photo URL
 * Format: https://farm{farm}.static.flickr.com/{server}/{id}_{secret}.jpg
 */
#define FL_PHOTO_URL @"https://farm%lld.static.flickr.com/%@/%@_%@.jpg"

#endif /* FLDefines_h */
