//
//  FLPhotoViewController.m
//  FlickrApp
//
//  Created by Ahmad Ansari on 12/10/2017.
//  Copyright © 2017 Ahmad Ansari. All rights reserved.
//

#import "FLPhotoViewController.h"

@interface FLPhotoViewController ()

@end

@implementation FLPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    [self loadPhotoData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadPhotoData {
    if(!isEmpty(self.photo)) {
        self.title = self.photo.title;
        NSString *photoPath = [self.photo photoPath];
        if(!isEmpty(photoPath)) {
            NSURL *photoURL = [NSURL URLWithString:photoPath];
            [self.imageView sd_setImageWithURL:photoURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
        }
    }
}
@end
