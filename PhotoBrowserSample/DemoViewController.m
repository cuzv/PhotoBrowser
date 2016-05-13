//
//  DemoViewController.m
//  PhotoBrowser
//
//  Created by Moch Xiao on 5/13/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import "DemoViewController.h"
#import "PBImageScrollView.h"

@interface DemoViewController ()
@property (nonatomic, strong) PBImageScrollView *imageScrollView;
@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    [self.view addSubview:self.imageScrollView];
//    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"9" ofType:@"jpg"]];
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"3" ofType:@"jpg"]];
    
        [self.imageScrollView setImage:image];
}

- (PBImageScrollView *)imageScrollView {
    if (!_imageScrollView) {
        _imageScrollView = [PBImageScrollView new];
    }
    return _imageScrollView;
}

@end
