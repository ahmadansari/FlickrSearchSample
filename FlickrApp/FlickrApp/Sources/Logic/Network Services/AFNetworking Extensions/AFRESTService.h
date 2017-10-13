//
//  AFRESTService.h
//  XProject
//
//  Created by Ahmad Ansari on 6/5/16.
//  Copyright © 2016 iOS Point. All rights reserved.
//

#import <Foundation/Foundation.h>

@import AFNetworking;
@class AFRESTService;

@interface AFRESTService : NSObject

+ (instancetype)instance;
- (id)initWithBaseURL:(NSString *)baseURL path:(NSString *)path;
- (id)initWithBaseURL:(NSString *)baseURL
                 path:(NSString *)path
       requestDeflate:(BOOL)requestDeflate
      responseInflate:(BOOL)responseInflate;

- (void)setRequestSerializer:(id<AFURLRequestSerialization>)serializer;
- (void)setResponseSerializer:(id<AFURLResponseSerialization>)serializer;

#pragma mark - POST Request Methods

- (void)executeRequest:(NSDictionary *)parameters
               success:(void (^)(id))successBlock
               failure:(void (^)(NSError *))failureBlock;

- (void)executeRequest:(id)parameters
             URLString:(NSString *)URLString
               success:(void (^)(id))successBlock
               failure:(void (^)(NSError *))failureBlock;

- (id)executeSyncRequest:(NSDictionary *)parameters;

#pragma mark - GET Request Methods
- (void)executeGETRequest:(NSDictionary *)parameters
                  success:(void (^)(id))successBlock
                  failure:(void (^)(NSError *))failureBlock;

- (void)executeGETRequest:(NSDictionary *)parameters
                URLString:(NSString *)URLString
                  success:(void (^)(id))successBlock
                  failure:(void (^)(NSError *))failureBlock;

- (void)executeStreamRequest:(NSDictionary *)parameters
                   URLString:(NSString *)URLString
                   dataBlock:(void (^)(NSData *))dataBlock
                     success:(void (^)(id))successBlock
                     failure:(void (^)(NSError *))failureBlock;

#pragma mark - Download Method
- (void)
downloadFile:(NSString *)URLString
destinationPath:(NSString *)destinationPath
progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
success:(void (^)(NSURLResponse *response, NSURL *filePath))successBlock
failure:(void (^)(NSError *))failureBlock;

#pragma mark - HTTP Headers
- (void)setValue:(id)value forHTTPHeaderField:(NSString *)key;

#pragma mark - Callback Queues
- (void)setCompletionQueue:(dispatch_queue_t)completionQueue;

#pragma mark - Request Timeout
- (void)setRequestTimeout:(NSTimeInterval)timeoutInterval;

@end
