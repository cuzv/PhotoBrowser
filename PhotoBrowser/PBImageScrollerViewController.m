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

static NSString * const PBObservedKeyPath = @"imageView.image";

@interface PBImageScrollerViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, assign, getter=isObserved) BOOL observed;
@end

@implementation PBImageScrollerViewController

- (void)dealloc {
    if (self.isObserved) {
        [self removeObserver:self forKeyPath:PBObservedKeyPath];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.scrollView addSubview:self.imageView];
    [self.view addSubview:self.scrollView];
    
    [self.view addSubview:self.indicatorView];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.scrollView addGestureRecognizer:doubleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPress:)];
    [self.scrollView addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.scrollView addGestureRecognizer:singleTap];
    
    [self addObserver:self forKeyPath:PBObservedKeyPath options:NSKeyValueObservingOptionNew context:nil];
    self.observed = YES;
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

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self _setZoomParametersForSize:self.scrollView.bounds.size];
    CGFloat zoomScale = self.scrollView.zoomScale;
    CGFloat minimumZoomScale = self.scrollView.minimumZoomScale;
    if (zoomScale < minimumZoomScale) {
        self.scrollView.zoomScale = minimumZoomScale;
    }
    [self _recenterImage];
    
    self.indicatorView.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2.0, CGRectGetHeight(self.view.bounds)/2.0);
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.imageView.image) {
        [self.indicatorView stopAnimating];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (![keyPath isEqualToString:PBObservedKeyPath]) {
        return;
    }
    if (!self.imageView.image) {
        return;
    }
    
    [self _updateUserInterface];
    [self.indicatorView stopAnimating];
}

#pragma mark - Inner methods

- (void)_updateUserInterface {
    CGSize size = self.imageView.image.size;
    self.imageView.frame = CGRectMake(0, 0, size.width, size.height);
    self.scrollView.contentSize = size;
    [self _setZoomParametersForSize:self.scrollView.bounds.size];
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    [self _recenterImage];
}

- (void)_setZoomParametersForSize:(CGSize)scrollViewSize {
    CGSize imageSize = self.imageView.bounds.size;
    
    CGFloat widthScale = scrollViewSize.width / imageSize.width;
    CGFloat heightScale = scrollViewSize.height / imageSize.height;
    CGFloat minScale = MIN(widthScale, heightScale);
    
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 2.0;
}

- (void)_recenterImage {
    CGSize scrollViewSize = self.scrollView.bounds.size;
    CGSize imageSize = self.imageView.frame.size;
    
    CGFloat horizontalSpace = imageSize.width < scrollViewSize.width ?
    (scrollViewSize.width - imageSize.width) / 2 : 0;
    CGFloat verticalSpace = imageSize.height < scrollViewSize.height ?
    (scrollViewSize.height - imageSize.height) / 2 : 0;
    
    self.scrollView.contentInset = UIEdgeInsetsMake(verticalSpace, horizontalSpace, verticalSpace, horizontalSpace);
}

- (void)_handleSingleTap:(UITapGestureRecognizer *)sender {
    if (self.didSingleTaped) {
        self.didSingleTaped(self.imageView.image);
    }
}

- (void)_handleDoubleTap:(UITapGestureRecognizer *)sender {
    if (!self.imageView.image) {
        return;
    }
    
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    } else {
        [self _zoomRectWithCenter:[sender locationInView:self.imageView]];
    }
}

- (void)_handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    if (self.didLongPressed) {
        self.didLongPressed(self.imageView.image);
    }
}

- (void)_zoomRectWithCenter:(CGPoint)center{
    CGRect rect;
    CGFloat zoomScale = self.scrollView.minimumZoomScale * 3;
    rect.size = CGSizeMake(self.scrollView.frame.size.width / zoomScale, self.scrollView.frame.size.height / zoomScale);
    rect.origin.x = MAX((center.x - (rect.size.width / 2.0f)), 0.0f);
    rect.origin.y = MAX((center.y - (rect.size.height / 2.0f)), 0.0f);
    
    CGRect frame = [self.scrollView.superview convertRect:self.scrollView.frame toView:self.scrollView.superview];
    CGFloat borderX = frame.origin.x;
    CGFloat borderY = frame.origin.y;
    
    if (borderX > 0.0f && (center.x < borderX || center.x > self.scrollView.frame.size.width - borderX)) {
        if (center.x < (self.scrollView.frame.size.width / 2.0f)) {
            rect.origin.x += (borderX / zoomScale);
        } else {
            rect.origin.x -= ((borderX / zoomScale) + rect.size.width);
        }
    }
    
    if (borderY > 0.0f && (center.y < borderY || center.y > self.scrollView.frame.size.height - borderY)) {
        if (center.y < (self.scrollView.frame.size.height / 2.0f)) {
            rect.origin.y += (borderY / zoomScale);
        } else {
            rect.origin.y -= ((borderY / zoomScale) + rect.size.height);
        }
    }
    
    [self.scrollView zoomToRect:rect animated:YES];
}

- (void)_prepareForReuse {
    self.imageView.image = nil;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self _recenterImage];
}

#pragma mark - Accessor

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.backgroundColor = [UIColor blackColor];
    }
    return _imageView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.backgroundColor = [UIColor blackColor];
        _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    return _indicatorView;
}

@end

