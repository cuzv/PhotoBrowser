//
//  UIView+PBSnapshot.h
//  PhotoBrowser
//
//  Created by Moch Xiao on 5/15/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PBSnapshot)
- (UIImage *)pb_snapshot;
- (UIImage *)pb_snapshotAfterScreenUpdates:(BOOL)afterUpdates;
@end
