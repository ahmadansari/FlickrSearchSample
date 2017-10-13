//
//  FlickrPhotoService.m
//  FlickrApp
//
//  Created by Ahmad Ansari on 12/10/2017.
//  Copyright © 2017 Ahmad Ansari. All rights reserved.
//

#import "FlickrPhotoService.h"

@implementation FlickrPhotoService

- (instancetype)init {
    self = [super initWithBaseURL:FL_BASE_URL
                             path:FL_PHOTO_LIST_URL];
    if (self) {
        // Do Stuff
        [self setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        [self setResponseSerializer:[AFJSONResponseSerializer serializer]];
    }
    return self;
}

- (void)searchPhotosForText:(NSString *)searchText completionHandler:(PhotoServiceHandler)handler {
    [self searchPhotosForText:searchText
                     pageInfo:nil
            completionHandler:handler];
}

- (void)searchPhotosForText:(NSString *)searchText
                   pageInfo:(NSDictionary *)pageInfo
          completionHandler:(PhotoServiceHandler)handler {
    @autoreleasepool {
        if(!isEmpty(searchText)) {
            NSDictionary *parameters = @{@"method":@"flickr.photos.search",
                                         @"api_key":FLICKR_API_KEY,
                                         @"format":@"json",
                                         @"nojsoncallback":@(1),
                                         @"safe_search":@(1),
                                         @"text":searchText,
                                         };
            if(!isEmpty(pageInfo)) {
                NSMutableDictionary *newParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
                [newParameters setObject:[pageInfo objectForKey:@"page"] forKey:@"page"];
                [newParameters setObject:[pageInfo objectForKey:@"per_page"] forKey:@"per_page"];
                parameters = newParameters;
            }
            
            [self executeGETRequest:parameters
                            success:^(id jsonObject) {
                                DDLogDebug(@"Success: %@", jsonObject);
                                BLOCK_EXEC(handler, jsonObject, NO);
                            }
                            failure:^(NSError *error) {
                                DDLogDebug(@"Service Erorr: %@", error);
                                BLOCK_EXEC(handler, error, YES);
                            }];
        }
    }
}
@end
