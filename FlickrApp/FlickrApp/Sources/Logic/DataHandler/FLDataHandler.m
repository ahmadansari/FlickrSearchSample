//
//  FLDataHandler.m
//  FlickrApp
//
//  Created by Ahmad Ansari on 11/10/2017.
//  Copyright © 2017 Ahmad Ansari. All rights reserved.
//

#import "FLDataHandler.h"
#import "FlickrPhotoService.h"

@interface FLDataHandler () {
    BOOL FLPageFetchCompleted;
    NSInteger currentPage;
    NSString *currentSearchText;
}
@end

@implementation FLDataHandler

#pragma mark -
#pragma mark ARC Singleton Implementation
static FLDataHandler *sharedInstance = nil;
+ (instancetype)sharedHandler {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FLDataHandler alloc] init];
        // Do any other initialisation stuff here
        sharedInstance -> FLPageFetchCompleted = NO;
        sharedInstance -> currentPage = 1;
        sharedInstance.searchedPhotoIDs = [NSMutableSet set];
        
//        NSArray *keywords = [[NSUserDefaults standardUserDefaults] objectForKey:@"searchedKeywords"];
//        sharedInstance.searchedKeywords = [NSMutableArray arrayWithArray:keywords];
    });
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark Methods
- (void) searchFlickrPhotosWithText:(NSString *)searchText
                         completion:(void (^__nullable)(BOOL error))completion {
    if(!isEmpty(searchText)) {
        //Check If Search Text is Changed, than Restart Paging
        if([searchText isEqualToString:currentSearchText]) {
            currentPage +=1;
        } else {
            currentPage = 1;
            currentSearchText = searchText;
            FLPageFetchCompleted = NO;
            [self.searchedPhotoIDs removeAllObjects];
        }
        
        if(FLPageFetchCompleted == YES) {
            BLOCK_EXEC(completion, YES);
        } else {
            NSDictionary *parameters = @{@"page": @(currentPage),
                                         @"per_page": @(kFLRequestPageSize),
                                         };
            FlickrPhotoService *photoService = [[FlickrPhotoService alloc] init];
            [photoService searchPhotosForText:searchText
                                     pageInfo:parameters
                            completionHandler:^(id data, BOOL error) {
                                NSLog(@"Response: %@", data);
                                [self savePhotosData:data
                                          searchText:searchText
                                          completion:^(BOOL error) {
                                              BLOCK_EXEC(completion, error);
                                          }];
                            }];
        }
    }
}

//Save Photos Info to Database
- (void)savePhotosData:(NSDictionary *)photosData
            searchText:(NSString *)searchText
            completion:(void (^__nullable)(BOOL error))completion {
    @autoreleasepool {
        if(!isEmpty(photosData)) {
            NSInteger totalCount = [[[photosData objectForKey:@"photos"] objectForKey:@"total"] integerValue];
            if(totalCount == 0) {
                //No Search Results are found
                FLPageFetchCompleted = YES;
                BLOCK_EXEC(completion, NO);
            } else {
                NSInteger totalPages = [[[photosData objectForKey:@"photos"] objectForKey:@"pages"] integerValue];
                NSInteger requestedPage = [[[photosData objectForKey:@"photos"] objectForKey:@"page"] integerValue];
                //Check Last Requested Page with Total Pages to Stop Further Loading for Same Search Text
                if(totalPages == requestedPage) {
                    FLPageFetchCompleted = YES;
                } else {
                    NSArray *photoIDs = [[[photosData valueForKey:@"photos"] valueForKey:@"photo"] valueForKey:@"id"];
                    [self.searchedPhotoIDs addObjectsFromArray:photoIDs];
                    [Photo savePhotosData:photosData
                               completion:^(BOOL error) {
                                   //Trigger Callback Events
                                   BLOCK_EXEC(completion, error);
                               }];
                }
            }
        } else {
            FLPageFetchCompleted = YES;
            BLOCK_EXEC(completion, YES);
        }
    }
}

#pragma mark - Search History
- (void) saveSearchKeyword:(NSString *)keyword {
    NSMutableArray *keywords = [NSMutableArray arrayWithArray:[self searchedKeywords]];
    if(keywords == nil) {
        keywords = [NSMutableArray array];
    }
    
    if([keywords containsObject:keyword]) {
        [keywords removeObject:keyword];
    }
    [keywords insertObject:keyword atIndex:0];
    if([keywords count] > kFLSearchHistoryLimit) {
        [keywords removeLastObject];
    }
    [self setSearchedKeywords:keywords];
}

- (NSMutableArray *)searchedKeywords {
      return [[NSUserDefaults standardUserDefaults] objectForKey:kSearchedKeywords];
}

-(void)setSearchedKeywords:(NSMutableArray *)searchedKeywords {
    [[NSUserDefaults standardUserDefaults] setObject:searchedKeywords forKey:kSearchedKeywords];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
