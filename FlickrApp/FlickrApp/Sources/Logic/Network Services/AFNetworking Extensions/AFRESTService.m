//
//  AFRESTService.m
//  XProject
//
//  Created by Ahmad Ansari on 6/5/16.
//  Copyright © 2016 iOS Point. All rights reserved.
//

#import "AFRESTService.h"
#import "Godzippa.h"
#import "AFgzipRequestSerializer.h"

/**
 *  Request Timeout Interval
 */
static NSTimeInterval const kRequestTimeoutInterval = 120.0;

@interface AFRESTService () {
@private
    /**
     *  The service path used along with the base url in methods such as
     * `GET:parameters:success:failure`
     */
    __strong NSString *_path;
    
    /**
     *  Session Manager which will be used to involde all methods
     */
    AFHTTPSessionManager *sessionManager;
    
    /**
     *  Server Response
     */
    id _responseObject;
    
    /**
     *  Enable/Disable Request Parameter Compression
     */
    BOOL _requestDeflate;
    
    /**
     *  Enable/Disable Response Data Decompression
     */
    BOOL _responseInflate;
    
    /**
     *  Enable/Disable Response Data Decompression
     */
    NSDictionary *authPair;
}
@end

// Sync Request Handling Flag
static BOOL _isSyncRequestInProgress = NO;

@implementation AFRESTService

+ (instancetype)instance {
    NSAssert(NO, @"Abstract Initializer Called");
    return nil;
}

- (id)initWithBaseURL:(NSString *)baseURL path:(NSString *)path {
    return [self initWithBaseURL:baseURL
                            path:path
                  requestDeflate:NO
                 responseInflate:NO];
}

- (id)initWithBaseURL:(NSString *)baseURL
                 path:(NSString *)path
       requestDeflate:(BOOL)requestDeflate
      responseInflate:(BOOL)responseInflate {
    if (self = [super init]) {
        _path = path;
        _requestDeflate = requestDeflate;
        _responseInflate = responseInflate;
        sessionManager = [[AFHTTPSessionManager alloc]
                          initWithBaseURL:[NSURL URLWithString:baseURL]];
        sessionManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
        [sessionManager setCompletionQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
        [self setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [self setResponseSerializer:[AFJSONResponseSerializer serializer]];
        // DDLogInfo(@" ---- URL ---- %@", path);
        return self;
    }
    return nil;
}


-(void)dealloc {
    DDLogVerbose(@"Destroying Service Object.");
    _path = nil;
    _responseObject = nil;
    sessionManager = nil;
}


#pragma mark - Request Serializer for POST Method
- (void)setRequestSerializer:(id<AFURLRequestSerialization>)serializer {
    @autoreleasepool {
        if (_requestDeflate) {
            [sessionManager
             setRequestSerializer:[AFgzipRequestSerializer
                                   serializerWithSerializer:serializer]];
        } else {
            [sessionManager setRequestSerializer:serializer];
        }
        [sessionManager.requestSerializer setTimeoutInterval:kRequestTimeoutInterval];
    }
}

#pragma mark - Response Serializer for POST Method
- (void)setResponseSerializer:(id<AFURLResponseSerialization>)serializer {
    @autoreleasepool {
        if(_responseInflate) {
            [sessionManager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        } else {
            [sessionManager setResponseSerializer:serializer];
        }
    }
}

#pragma mark - POST Request Methods
- (void)executeRequest:(NSDictionary *)parameters
               success:(void (^)(id))successBlock
               failure:(void (^)(NSError *))failureBlock {
    [self executeRequest:parameters
               URLString:nil
                 success:successBlock
                 failure:failureBlock];
}

- (void)executeRequest:(id)parameters
             URLString:(NSString *)URLString
               success:(void (^)(id))successBlock
               failure:(void (^)(NSError *))failureBlock {
    @autoreleasepool {
        if ([[AXNetworkManager sharedManager] isConnectedToInternet]) {
            [self setAuthorizationHeader];
            if (URLString) {
                if ([URLString characterAtIndex:0] == '/') {
                    _path = [_path stringByAppendingFormat:@"%@", URLString];
                } else {
                    _path = [_path stringByAppendingFormat:@"?%@", URLString];
                }
            }
            [sessionManager POST:_path
                      parameters:parameters
                        progress:nil
                         success:^(NSURLSessionDataTask *_Nonnull task,
                                   id _Nullable responseObject) {
                             @autoreleasepool {
                                 if(_responseInflate) {
                                     responseObject = [self inflateJSONData:responseObject];
                                 }
                                 BLOCK_EXEC(successBlock, responseObject);
                             }
                         }
                         failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                             @autoreleasepool {
                                 BLOCK_EXEC(failureBlock, error);
                             }
                         }];
        } else {
            BLOCK_EXEC(failureBlock, nil);
        }
    }
}

- (id)executeSyncRequest:(NSDictionary *)parameters {
    @autoreleasepool {
        if ([[AXNetworkManager sharedManager] isConnectedToInternet]) {
            _isSyncRequestInProgress = YES;
            [self setAuthorizationHeader];
            [sessionManager POST:_path
                      parameters:parameters
                        progress:nil
                         success:^(NSURLSessionDataTask *_Nonnull task,
                                   id _Nullable responseObject) {
                             // Success
                             _isSyncRequestInProgress = NO;
                             if(_responseInflate) {
                                 _responseObject = [self inflateJSONData:responseObject];
                             } else {
                                 _responseObject = responseObject;
                             }
                         }
                         failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                             @autoreleasepool {
                                 // Failure
                                 _isSyncRequestInProgress = NO;
                                 _responseObject = nil;
                             }
                         }];
            while (_isSyncRequestInProgress) {
                // 1/1000 of a second
                NSDate *stopDate = [NSDate dateWithTimeIntervalSinceNow:0.001];
                [[NSRunLoop currentRunLoop] runUntilDate:stopDate];
            }
            return _responseObject;
        }
    }
    return nil;
}

#pragma mark - GET Request Methods
- (void)executeGETRequest:(NSDictionary *)parameters
                  success:(void (^)(id))successBlock
                  failure:(void (^)(NSError *))failureBlock {
    [self executeGETRequest:parameters
                  URLString:nil
                    success:successBlock
                    failure:failureBlock];
}

- (void)executeGETRequest:(NSDictionary *)parameters
                URLString:(NSString *)URLString
                  success:(void (^)(id))successBlock
                  failure:(void (^)(NSError *))failureBlock {
    @autoreleasepool {
        if ([[AXNetworkManager sharedManager] isConnectedToInternet]) {
            [sessionManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
            [self setAuthorizationHeader];
            if (URLString) {
                if ([URLString characterAtIndex:0] == '/') {
                    _path = [_path stringByAppendingFormat:@"%@", URLString];
                } else {
                    _path = [_path stringByAppendingFormat:@"?%@", URLString];
                }
            }
            [sessionManager GET:_path
                     parameters:parameters
                       progress:nil
                        success:^(NSURLSessionDataTask *_Nonnull task,
                                  id _Nullable responseObject) {
                            id serviceResponse = nil;
                            if(_responseInflate) {
                                serviceResponse = [self inflateJSONData:responseObject];
                            } else {
                                serviceResponse = responseObject;
                            }
                            BLOCK_EXEC(successBlock, serviceResponse);
                        }
                        failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                            @autoreleasepool {
                                BLOCK_EXEC(failureBlock, error);
                            }
                        }];
        } else {
            BLOCK_EXEC(failureBlock, nil);
        }
    }
}

#pragma mark - Downlaod File
- (void) downloadFile:(NSString *)URLString
      destinationPath:(NSString *)destinationPath
             progress:(void (^)(NSProgress *downloadProgress))downloadProgressBlock
              success:(void (^)(NSURLResponse *response, NSURL *filePath))successBlock
              failure:(void (^)(NSError *))failureBlock {
    @autoreleasepool {
        if ([[AXNetworkManager sharedManager] isConnectedToInternet]) {
            if (URLString) {
                if ([URLString characterAtIndex:0] == '/') {
                    _path = [_path stringByAppendingFormat:@"%@", URLString];
                } else {
                    _path = [_path stringByAppendingFormat:@"?%@", URLString];
                }
            }
            DDLogDebug(@"Downloading File URL: %@", _path);
            [sessionManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
            NSError *serializationError = nil;
            NSMutableURLRequest *request =
            [sessionManager.requestSerializer requestWithMethod:@"GET"
                                                      URLString:_path
                                                     parameters:nil
                                                          error:&serializationError];
            request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
            if (serializationError) {
                BLOCK_EXEC(failureBlock, serializationError);
            } else {
                // Start the download
                NSURLSessionDownloadTask *downloadTask =
                [sessionManager
                 downloadTaskWithRequest:request
                 progress:downloadProgressBlock
                 destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                     NSURL *destinationURL = targetPath;
                     @autoreleasepool {
                         if (destinationPath) {
                             destinationURL = [NSURL fileURLWithPath:destinationPath];
                             NSFileManager *fileManager = [NSFileManager defaultManager];
                             if ([fileManager fileExistsAtPath:destinationPath]) {
                                 NSError *error = nil;
                                 BOOL fileRemoved =
                                 [fileManager removeItemAtPath:destinationPath error:&error];
                                 DDLogDebug(@"Existing File Removed: %d, Path: %@, Error: %@", fileRemoved, destinationPath, error);
                             }
                             DDLogDebug(@"Downloading File Destination: %@", destinationPath);
                         }
                     }
                     return destinationURL;
                 }
                 completionHandler:^(NSURLResponse *response, NSURL *filePath,
                                     NSError *error) {
                     @autoreleasepool {
                         DDLogDebug(@"Downloading File Complete: %@, Error: %@", filePath, error);
                         if (!error) {
                             // If there's no error, return the completion block
                             BLOCK_EXEC(successBlock, response, filePath);
                         } else {
                             // Otherwise return the error block
                             BLOCK_EXEC(failureBlock, error);
                         }
                     }
                 }];
                [downloadTask resume];
            }
        }
        else {
            BLOCK_EXEC(failureBlock, nil);
        }
    }
}

#pragma mark - HTTP Headers
- (void)setValue:(id)value forHTTPHeaderField:(NSString *)key {
    [sessionManager.requestSerializer setValue:value forHTTPHeaderField:key];
}

- (void) setAuthorizationHeader {
    NSString *authValue = [self base64EncodedAuthValue];
    if(authValue && [authValue length] > 0) {
        [self setValue:authValue forHTTPHeaderField:@"Authorization"];
    }
}
- (NSString *)base64EncodedAuthValue {
    NSString *authValue = nil;
    @autoreleasepool {
        if(!isEmpty(authPair)) {
            NSString *key = [[authPair allKeys] firstObject];
            NSString *value = [authPair valueForKey:key];
            NSString *authStr = [NSString stringWithFormat:@"%@:%@", key, value];
            NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
            authValue = [NSString
                         stringWithFormat:@"Basic %@",
                         [authData base64EncodedStringWithOptions:
                          NSDataBase64EncodingEndLineWithLineFeed]];
        }
    }
    return authValue;
}

#pragma mark - Callback Queues
- (void)setCompletionQueue:(dispatch_queue_t)completionQueue {
    if (completionQueue) {
        sessionManager.completionQueue = completionQueue;
    }
}

#pragma mark - Request Timeout
- (void)setRequestTimeout:(NSTimeInterval)timeoutInterval {
    [sessionManager.requestSerializer setTimeoutInterval:timeoutInterval];
}

#pragma mark - GZip Methods
- (id) inflateJSONData:(NSData *)deflatedData {
    id serializedObject = nil;
    @autoreleasepool {
        if(!isEmpty(deflatedData)) {
            NSError *error = nil;
            
            //Trimming String Quotes from Data
            //NSRange range = NSMakeRange(1, [deflatedData length] - 2);
            //deflatedData = [deflatedData subdataWithRange:range];
            
            //Create compressedData from Base64 Enocded String
            //NSString *base64String = [[NSString alloc] initWithData:deflatedData encoding:NSUTF8StringEncoding];
            //NSData* compressedData = [[NSData alloc] initWithBase64EncodedString:base64String options:0];
            
            //Create compressedData from Base64 Enocded Data
            NSData* compressedData = [[NSData alloc] initWithBase64EncodedData:deflatedData options:0];
            
            //Uncompressing GZIP Data
            NSData* unCompressedData = [compressedData dataByGZipDecompressingDataWithError:&error];
            NSDictionary* responseDict = nil;
            if(!isEmpty(unCompressedData)) {
                responseDict = [NSJSONSerialization JSONObjectWithData:unCompressedData options:kNilOptions error:&error];
            }
            if(!error) {
                serializedObject = responseDict;
            } else {
                DDLogError(@"GZip Error: %@", error);
            }
            //base64String = nil;
            compressedData = nil;
            unCompressedData = nil;
        }
    }
    return serializedObject;
}


#pragma mark - Memoery Beta Dev
- (void)executeStreamRequest:(NSDictionary *)parameters
                   URLString:(NSString *)URLString
                   dataBlock:(void (^)(NSData *))dataBlock
                     success:(void (^)(id))successBlock
                     failure:(void (^)(NSError *))failureBlock {
    @autoreleasepool {
        if ([[AXNetworkManager sharedManager] isConnectedToInternet]) {
            [sessionManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
            [self setAuthorizationHeader];
            if (URLString) {
                if ([URLString characterAtIndex:0] == '/') {
                    _path = [_path stringByAppendingFormat:@"%@", URLString];
                } else {
                    _path = [_path stringByAppendingFormat:@"?%@", URLString];
                }
            }
            NSString *fileName = [NSString stringWithFormat:@"JS_%@.txt", [[NSUUID UUID] UUIDString]];
            __block NSString *jsonFilePath = [[self cacheDirectoryPath] stringByAppendingPathComponent:fileName];
            [sessionManager GET:_path
                     parameters:parameters
                       progress:nil
                        success:^(NSURLSessionDataTask *_Nonnull task,
                                  id _Nullable responseObject) {
                            BLOCK_EXEC(successBlock, jsonFilePath);
                        }
                        failure:^(NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error) {
                            @autoreleasepool {
                                BLOCK_EXEC(failureBlock, error);
                            }
                        }];
            
            [[NSFileManager defaultManager] removeItemAtPath:jsonFilePath error:nil];
            [[NSFileManager defaultManager] createFileAtPath:jsonFilePath contents:nil attributes:nil];
            
            [sessionManager setDataTaskDidReceiveDataBlock:^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSData * _Nonnull data) {
                BLOCK_EXEC(dataBlock, data);
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:jsonFilePath];
                [fileHandle seekToEndOfFile];
                [fileHandle writeData:data];
                [fileHandle closeFile];
                fileHandle = nil;
                data = nil;
            }];
        } else {
            BLOCK_EXEC(failureBlock, nil);
        }
    }
}

#pragma mark - Directories
- (NSString *)documentsDirectoryPath {
    @autoreleasepool {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        return [paths firstObject];
    }
}

- (NSString *)cacheDirectoryPath {
    @autoreleasepool {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        return [paths firstObject];
    }
}

@end
