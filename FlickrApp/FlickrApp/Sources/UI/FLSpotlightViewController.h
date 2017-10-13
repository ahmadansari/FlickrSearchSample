//
//  FLSpotlightViewController.h
//  FlickrApp
//
//  Created by Ahmad Ansari on 13/10/2017.
//  Copyright © 2017 Ahmad Ansari. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FLSpotlightControllerDelegate <NSObject>
@optional
- (void) didSelectHistoryKeyword:(NSString *)keyword;
@end

@interface FLSpotlightViewController : UITableViewController

//Spotlight Delegate for History Selection
@property (weak, nonatomic) id<FLSpotlightControllerDelegate> delegate;

+ (instancetype) instance;
- (void) reloadData;
- (void) updateSearchResultsForText:(NSString *)searchText;
@end
