//
//  PBImageScrollView+internal.h
//  PhotoBrowser
//
//  Created by Roy Shaw on 5/13/16.
//  Copyright © 2016 Roy Shaw (https://github.com/cuzv).
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

#ifndef PBLog
#    if INPB
#       define PBLog(FORMAT, ...)    \
            do {    \
                fprintf(stderr,"<%s> %s %s [%d] %s\n",    \
                (NSThread.isMainThread ? "UI" : "BG"),    \
                (sel_getName(_cmd)),\
                [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],    \
                __LINE__,    \
                [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);    \
            } while(0)
#   else
#        define PBLog(FORMAT, ...)
#   endif
#endif

#import "PBImageScrollView.h"

@interface PBImageScrollView()

- (void)_handleZoomForLocation:(CGPoint)location;
- (void)_scrollToTopAnimated:(BOOL)animated;

/// Scrolling content offset'y percent.
@property (nonatomic, copy) void(^contentOffSetVerticalPercentHandler)(CGFloat);

/// loosen hand with decelerate
/// velocity: > 0 up, < 0 dwon, == 0 others(no swipe, e.g. tap).
@property (nonatomic, copy) void(^didEndDraggingInProperpositionHandler)(CGFloat velocity);

@end


#endif /* PBImageScrollView_internal_h */
