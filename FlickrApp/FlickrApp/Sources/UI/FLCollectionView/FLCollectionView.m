//
//  FLCollectionView.m
//  FlickrApp
//
//  Created by Ahmad Ansari on 09/10/2017.
//  Copyright © 2017 Ahmad Ansari. All rights reserved.
//

#import "FLCollectionView.h"

// Cell Identifiers
NSString *const collectionCellPhotoItem = @"collectionCellPhotoItem";

@implementation FLCollectionView

- (void)registerCustomCells {
    //Registering Custom Collection Cells
    [self registerClass:[PhotoItemCell class] forCellWithReuseIdentifier:collectionCellPhotoItem];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
