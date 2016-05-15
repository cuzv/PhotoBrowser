//
//  PBImageScrollerViewController.m
//  PhotoBrowser
//
//  Created by Moch Xiao on 8/24/15.
//  Copyright (c) 2015 Moch Xiao (https://github.com/cuzv).
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PBImageScrollerViewController.h"
#import "PBImageScrollView.h"
#import "PBImageScrollView+internal.h"

@interface PBImageScrollerViewController ()
@property (nonatomic, strong) PBImageScrollView *imageScrollView;
@property (nonatomic, strong) UITapGestureRecognizer *singleTapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;

@property (nonatomic, assign) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation PBImageScrollerViewController

#if DEBUG
- (void)dealloc {
    NSLog(@"~~~~~~~~~~~%s~~~~~~~~~~~", __FUNCTION__);
}
#endif

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.imageScrollView];
    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"9" ofType:@"jpg"]];
    self.imageScrollView.imageView.image = image;
    
    
    [self.view addGestureRecognizer:self.doubleTapGestureRecognizer];
    
    [self.view addGestureRecognizer:self.singleTapGestureRecognizer];
    [self.singleTapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self _prepareForReuse];
    
    if (self.fetchImageBlock) {
        self.imageView.image = self.fetchImageBlock();
    }
    if (self.configureImageViewBlock) {
        self.configureImageViewBlock(self.imageView);
    }
    
    if (!self.imageView.image) {
        [self.indicatorView startAnimating];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.imageView.image) {
        [self.indicatorView stopAnimating];
    }
}

- (void)_prepareForReuse {
    self.imageView.image = nil;
}

- (void)handleDoubleTapAction: (UITapGestureRecognizer *)sender {
    [self.imageScrollView _handleZoomForGestureRecognizer:sender];
}

- (void)dismiss {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    if (self.didSingleTaped) {
        self.didSingleTaped(self.imageView.image);
    }
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


- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _indicatorView;
}

- (UIImageView *)imageView {
    return self.imageScrollView.imageView;
}

@end

