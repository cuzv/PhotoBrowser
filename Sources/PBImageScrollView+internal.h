//
//  PBImageScrollView+internal.h
//  PhotoBrowser
//
//  Created by Moch Xiao on 5/13/16.
//  Copyright © 2016 Moch Xiao (http://mochxiao.com).
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

#ifndef PBImageScrollView_internal_h
#define PBImageScrollView_internal_h

#import "PBImageScrollView.h"

@interface PBImageScrollView()

- (void)_handleZoomForLocation:(CGPoint)location;

/// Scrolling content offset'y percent.
@property (nonatomic, copy) void(^contentOffSetVerticalPercentHandler)(CGFloat);

/// loosen hand with decelerate
/// direction: > 0 up, < 0 dwon, == 0 others(no swipe, e.g. tap).
@property (nonatomic, copy) void(^didEndDraggingInProperpositionHandler)(CGFloat direction);

@end


#endif /* PBImageScrollView_internal_h */
