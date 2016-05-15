//
//  DemoViewController.m
//  PhotoBrowser
//
//  Created by Moch Xiao on 5/13/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import "RemoteImagesExampleViewController.h"
#import "PBImageScrollView.h"
#import "PBImageScrollView+internal.h"

@interface RemoteImagesExampleViewController ()
@property (nonatomic, strong) PBImageScrollView *imageScrollView;
@property (nonatomic, strong) UITapGestureRecognizer *singleTapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;

@end

@implementation RemoteImagesExampleViewController

- (void)dealloc {
    NSLog(@"~~~~~~~~~~~%s~~~~~~~~~~~", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.imageScrollView];
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"7" ofType:@"jpg"]];
    self.imageScrollView.imageView.image = image;

    [self.view addGestureRecognizer:self.doubleTapGestureRecognizer];
    
    [self.view addGestureRecognizer:self.singleTapGestureRecognizer];
    [self.singleTapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
}

- (void)handleDoubleTapAction: (UITapGestureRecognizer *)sender {
    NSLog(@"~~~~~~~~~~~%s~~~~~~~~~~~", __FUNCTION__);
    [self.imageScrollView _handleZoomForGestureRecognizer:sender];
}

- (void)dismiss {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

- (PBImageScrollView *)imageScrollView {
    if (!_imageScrollView) {
        _imageScrollView = [PBImageScrollView new];
    }
    return _imageScrollView;
}

- (UITapGestureRecognizer *)singleTapGestureRecognizer {
    if (!_singleTapGestureRecognizer) {
        _singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    }
    return _singleTapGestureRecognizer;
}

- (UITapGestureRecognizer *)doubleTapGestureRecognizer {
    if (!_doubleTapGestureRecognizer) {
        _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapAction:)];
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    }
    
    return _doubleTapGestureRecognizer;
}

@end
