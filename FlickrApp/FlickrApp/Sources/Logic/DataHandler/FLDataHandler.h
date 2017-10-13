//
//  FLDataHandler.h
//  FlickrApp
//
//  Created by Ahmad Ansari on 11/10/2017.
//  Copyright © 2017 Ahmad Ansari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLDataHandler : NSObject

@property (nonatomic, strong) NSMutableSet *_Nullable searchedPhotoIDs;
@property (nonatomic, strong) NSMutableArray *_Nullable searchedKeywords;
+ (instancetype _Nonnull)sharedHandler;

- (void) searchFlickrPhotosWithText:(NSString *_Nonnull)searchText
                         completion:(void (^__nullable)(BOOL error))completion;

- (void) saveSearchKeyword:(NSString *__nullable)keyword;
@end
