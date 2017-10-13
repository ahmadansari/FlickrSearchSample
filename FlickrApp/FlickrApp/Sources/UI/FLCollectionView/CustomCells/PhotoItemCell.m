//
//  PhotoItemCell.m
//  FlickrApp
//
//  Created by Ahmad Ansari on 12/10/2017.
//  Copyright © 2017 Ahmad Ansari. All rights reserved.
//

#import "PhotoItemCell.h"

@implementation PhotoItemCell

- (void)configure:(Photo *)photo {
    if(!isEmpty(photo)) {
        self.titleLabel.text = photo.title;
        
        NSString *photoPath = [photo photoPath];
        if(!isEmpty(photoPath)) {
            NSURL *photoURL = [NSURL URLWithString:photoPath];
            [self.imageView sd_setImageWithURL:photoURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
        }
    }
}

@end
