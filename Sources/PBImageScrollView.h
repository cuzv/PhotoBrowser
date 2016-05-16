//
//  PBImageScrollView.h
//  PhotoBrowser
//
//  Created by Moch Xiao on 5/12/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PBImageDownloadProgressHandler)(NSInteger receivedSize, NSInteger expectedSize);

@interface PBImageScrollView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong, readonly) UIImageView *imageView;
/// Download progress callback.
@property (nonatomic, copy, readonly) PBImageDownloadProgressHandler downloadProgressHandler;

@end
