//
//  PBImageScrollView.m
//  PhotoBrowser
//
//  Created by Moch Xiao on 5/12/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import "PBImageScrollView.h"

@implementation PBImageScrollView

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
    self.delegate = self;
    [self addSubview:self.imageView];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    [self updateFrame];
    [self recenterImage];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    [self updateFrame];
    [self recenterImage];
}

#pragma mark - Private methods

- (void)updateFrame {
    self.frame = [UIScreen mainScreen].bounds;
    
    CGSize properSize = [self properPresentSizeForImage:self.imageView.image];
    NSLog(@"properSize: %@", NSStringFromCGSize(properSize));
    self.imageView.frame = CGRectMake(0, 0, properSize.width, properSize.height);
    self.contentSize = properSize;
}

- (CGSize)properPresentSizeForImage:(UIImage *)image {
    CGFloat ratio = CGRectGetWidth(self.bounds) / image.size.width;
    return CGSizeMake(CGRectGetWidth(self.bounds), ceil(ratio * image.size.height));
}

- (void)recenterImage {
    CGFloat imageViewHeight = CGRectGetHeight(self.imageView.bounds);
    CGFloat selfHeight = CGRectGetHeight(self.bounds);
    if (imageViewHeight >= selfHeight) {
        return;
    }
    
    CGFloat moveSpace = (selfHeight - imageViewHeight) / 2.0;
    CGPoint center = self.imageView.center;
    center.y = center.y + moveSpace;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.imageView.center = center;
    [CATransaction commit];
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

@end
