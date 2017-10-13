//
//  PhotoItemCell.h
//  FlickrApp
//
//  Created by Ahmad Ansari on 12/10/2017.
//  Copyright © 2017 Ahmad Ansari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoItemCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)configure:(Photo *)photo;

@end
