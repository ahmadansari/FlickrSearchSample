//
//  FLPhotoViewController.h
//  FlickrApp
//
//  Created by Ahmad Ansari on 12/10/2017.
//  Copyright © 2017 Ahmad Ansari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLPhotoViewController : UIViewController

@property (nonatomic, weak) Photo *photo;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
