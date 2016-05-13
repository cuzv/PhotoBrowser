//
//  PBImageScrollView.m
//  PhotoBrowser
//
//  Created by Moch Xiao on 5/12/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import "PBImageScrollView.h"

#define system_version ([UIDevice currentDevice].systemVersion.doubleValue)
#define observe_keypath @"image"

@interface PBImageScrollView ()
@property (nonatomic, weak) id <NSObject> notification;
@end

@implementation PBImageScrollView

- (void)dealloc {
    [self _removeObserver];
    [self _removeNotificationIfNeeded];
    NSLog(@"~~~~~~~~~~~%s~~~~~~~~~~~", __FUNCTION__);
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.frame = [UIScreen mainScreen].bounds;
    self.multipleTouchEnabled = YES;
    self.showsVerticalScrollIndicator = YES;
    self.showsHorizontalScrollIndicator = YES;
    self.alwaysBounceVertical = YES;
    self.minimumZoomScale = 1;
    self.maximumZoomScale = 1;
    self.delegate = self;
    
    [self addSubview:self.imageView];
    [self _addObserver];
    [self _addNotificationIfNeeded];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self _updateFrame];
    [self _recenterImage];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (![keyPath isEqualToString:observe_keypath]) {
        return;
    }
    if (![object isEqual:self.imageView]) {
        return;
    }

    [self _updateFrame];
    [self _recenterImage];
    [self _setMaximumZoomScale];
}

#pragma mark - Internal Methods

- (void)_handleZoomForGestureRecognizer:(UITapGestureRecognizer *)sender {
    if (self.zoomScale > 1) {
        [self setZoomScale:1 animated:YES];
    } else {
        CGPoint touchPoint = [sender locationInView:self.imageView];
        CGFloat newZoomScale = self.maximumZoomScale;
        CGFloat horizontalSize = CGRectGetWidth(self.bounds) / newZoomScale;
        CGFloat verticalSize = CGRectGetHeight(self.bounds) / newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - horizontalSize / 2.0f, touchPoint.y - verticalSize / 2.0f, horizontalSize, verticalSize) animated:YES];
    }
}

#pragma mark - Private methods

- (void)_addObserver {
    [self.imageView addObserver:self forKeyPath:observe_keypath options:NSKeyValueObservingOptionNew context:nil];
}

- (void)_removeObserver {
    [self.imageView removeObserver:self forKeyPath:observe_keypath];
}

- (void)_addNotificationIfNeeded {
    if (system_version >= 8.0) {
        return;
    }
    
    __weak typeof(self) weak_self = self;
    self.notification = [[NSNotificationCenter defaultCenter] addObserverForName:UIDeviceOrientationDidChangeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(weak_self) strong_self = weak_self;
        [strong_self _updateFrame];
        [strong_self _recenterImage];
    }];
}

- (void)_removeNotificationIfNeeded {
    if (system_version >= 8.0) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.notification];
}

- (void)_updateFrame {
    self.frame = [UIScreen mainScreen].bounds;
    
    CGSize properSize = [self _properPresentSizeForImage:self.imageView.image];
    self.imageView.frame = CGRectMake(0, 0, properSize.width, properSize.height);
    self.contentSize = properSize;
}

- (CGSize)_properPresentSizeForImage:(UIImage *)image {
    CGFloat ratio = CGRectGetWidth(self.bounds) / image.size.width;
    return CGSizeMake(CGRectGetWidth(self.bounds), ceil(ratio * image.size.height));
}

- (void)_recenterImage {
    CGFloat contentWidth = self.contentSize.width;
    CGFloat horizontalDiff = CGRectGetWidth(self.bounds) - contentWidth;
    CGFloat horizontalAddition = horizontalDiff > 0.f ? horizontalDiff : 0.f;
    
    CGFloat contentHeight = self.contentSize.height;
    CGFloat verticalDiff = CGRectGetHeight(self.bounds) - contentHeight;
    CGFloat verticalAdditon = verticalDiff > 0 ? verticalDiff : 0.f;
    
    self.imageView.center = CGPointMake((contentWidth + horizontalAddition) / 2.0f, (contentHeight + verticalAdditon) / 2.0f);
}

- (void)_setMaximumZoomScale {
    CGSize imageSize = self.imageView.image.size;
    self.maximumZoomScale = MAX(MIN(imageSize.width / CGRectGetWidth(self.bounds), imageSize.height / CGRectGetHeight(self.bounds)), 3);
}

#pragma mark - Accessor

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _imageView;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self _recenterImage];
}

@end
