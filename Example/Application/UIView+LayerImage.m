//
//  UIView+LayerImage.m
//  PhotoBrowser
//
//  Created by Roy Shaw on 3/1/17.
//  Copyright © 2017 Moch. All rights reserved.
//

#import "UIView+LayerImage.h"

@implementation UIView (LayerImage)

- (UIImage *)layerImage {
    return [[UIImage alloc] initWithCGImage:(__bridge CGImageRef _Nonnull)(self.layer.contents)];
}

- (void)setLayerImage:(UIImage *)layerImage {
    CGFloat iw = layerImage.size.width;
    CGFloat ih = layerImage.size.height;
    CGFloat vw = CGRectGetWidth(self.bounds);
    CGFloat vh = CGRectGetHeight(self.bounds);
    CGFloat scale = (ih / iw) / (vh / vw);
    if (!isnan(scale) && scale > 1) {
        // 高图只保留顶部
        self.contentMode = UIViewContentModeScaleToFill;
        self.layer.contentsRect = CGRectMake(0, 0, 1, (iw / ih) * (vh / vw));
    } else {
        // 宽图把左右两边裁掉
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.layer.contentsRect = CGRectMake(0, 0, 1, 1);
    }
    self.layer.contents = (__bridge id _Nullable)(layerImage.CGImage);
}


@end
