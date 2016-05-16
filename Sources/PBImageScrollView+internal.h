//
//  PBImageScrollView+internal.h
//  PhotoBrowser
//
//  Created by Moch Xiao on 5/13/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#ifndef PBImageScrollView_internal_h
#define PBImageScrollView_internal_h

#import <UIKit/UIKit.h>

@interface PBImageScrollView()

- (void)_handleZoomForLocation:(CGPoint)location;

/// Scrolling content offset'y percent.
@property (nonatomic, copy) void(^contentOffSetVerticalPercent)(CGFloat);
/// loosen hand with decelerate
@property (nonatomic, copy) void(^didEndDraggingWithScrollEnough)(void);

@end


#endif /* PBImageScrollView_internal_h */
