//
//  AXNetworkManager.h
//  XProject
//
//  Created by Ahmad Ansari on 9/11/14.
//  Copyright (c) 2014 iOS Point. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AXNetworkService.h"

@interface AXNetworkManager : NSObject

@property (nonatomic, strong) AXNetworkService *networkService;

+ (AXNetworkManager *) sharedManager;
- (void) startMonitoring;
- (void) stopMonintoring;

- (AXNetworkType) networkType;
- (BOOL) isConnectedViaWiFi;
- (BOOL) isConnectedViaMobileNetwork;
- (BOOL) isConnectedToInternet;
- (NSString *) descriptionForNetworkType:(AXNetworkType)networkType;

/**
 *  Check current connectivity state with host on runtime.
 *
 *  @return `BOOL`.
 */
- (BOOL) isConnectedToHost;

//Network Observers
- (void) addNetworkObserver:(id)target
 connectivityChangeSelector:(SEL)selector
     noConnectivitySelector:(SEL)selector;

- (void) removeNetworkObserver:(id)target;

@end
