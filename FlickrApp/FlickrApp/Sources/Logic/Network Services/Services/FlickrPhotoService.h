//
//  FlickrPhotoService.h
//  FlickrApp
//
//  Created by Ahmad Ansari on 12/10/2017.
//  Copyright © 2017 Ahmad Ansari. All rights reserved.
//

#import "AFRESTService.h"

typedef void (^PhotoServiceHandler)(id data, BOOL error);

@interface FlickrPhotoService : AFRESTService

- (void)searchPhotosForText:(NSString *)searchText
          completionHandler:(PhotoServiceHandler)handler;

- (void)searchPhotosForText:(NSString *)searchText
                   pageInfo:(NSDictionary *)pageInfo
          completionHandler:(PhotoServiceHandler)handler;

@end
