//
//  PBPresentAnimatedTransitioningController.m
//  PhotoBrowser
//
//  Created by Moch Xiao on 5/17/16.
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

#import "PBPresentAnimatedTransitioningController.h"

@interface PBPresentAnimatedTransitioningController ()
@property (nonatomic, assign) BOOL isPresenting;
@end

@implementation PBPresentAnimatedTransitioningController

#if DEBUG
- (void)dealloc {
    NSLog(@"~~~~~~~~~~~%s~~~~~~~~~~~", __FUNCTION__);
}
#endif

#pragma mark - Public methods

- (nonnull PBPresentAnimatedTransitioningController *)pb_prepareForPresent {
    self.isPresenting = YES;
    return self;
}

- (nonnull PBPresentAnimatedTransitioningController *)pb_prepareForDismiss {
    self.isPresenting = NO;
    return self;
}

#pragma mark - Private methods

- (UIViewAnimationOptions)_animationOptions {
    return 7 << 16;
}

- (void)_runAnimations:(void (^)(void))animations completion:(void (^)(BOOL flag))completion {
    [UIView animateWithDuration:0.25 delay:0 options:[self _animationOptions] animations:animations completion:completion];
}

- (void)_runPresentAnimationsWithContainer:(UIView *)container from:(UIView *)fromView to:(UIView *)toView completion:(void (^)(BOOL flag))completion {
    self.coverView.frame = container.frame;
    self.coverView.alpha = 0;
    [container addSubview:self.coverView];
    toView.frame = container.bounds;
    [container addSubview:toView];
    
    if (self.prepareForPresentActionHandler) {
        self.prepareForPresentActionHandler(fromView, toView);
    }
    __weak typeof(self) weak_self = self;
    [self _runAnimations:^{
        __strong typeof(weak_self) strong_self = weak_self;
        strong_self.coverView.alpha = 1;
        if (strong_self.duringPresentingActionHandler) {
            strong_self.duringPresentingActionHandler(fromView, toView);
        }
    } completion:^(BOOL flag) {
        __strong typeof(weak_self) strong_self = weak_self;
        if (strong_self.didPresentedActionHandler) {
            strong_self.didPresentedActionHandler(fromView, toView);
        }
        completion(flag);
    }];
}

- (void)_runDismissAnimationsWithContainer:(UIView *)container from:(UIView *)fromView to:(UIView *)toView completion:(void (^)(BOOL flag))completion {
    [container addSubview:fromView];
    if (self.prepareForDismissActionHandler) {
        self.prepareForDismissActionHandler(fromView, toView);
    }
    __weak typeof(self) weak_self = self;
    [self _runAnimations:^{
        __strong typeof(weak_self) strong_self = weak_self;
        strong_self.coverView.alpha = 0;
        if (strong_self.duringDismissingActionHandler) {
            strong_self.duringDismissingActionHandler(fromView, toView);
        }
    } completion:^(BOOL flag) {
        __strong typeof(weak_self) strong_self = weak_self;
        if (strong_self.didDismissedActionHandler) {
            strong_self.didDismissedActionHandler(fromView, toView);
        }
        completion(flag);
    }];
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *container = [transitionContext containerView];
    if (!container) {
        return;
    }
    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if (!fromController) {
        return;
    }
    UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (!toController) {
        return;
    }
    
    if (self.isPresenting) {
        [self _runPresentAnimationsWithContainer:container from:fromController.view to:toController.view completion:^(BOOL flag) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    } else {
        [self _runDismissAnimationsWithContainer:container from:fromController.view to:toController.view completion:^(BOOL flag) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }];
    }
}

#pragma mark - Accessor

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [UIView new];
        _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _coverView;
}

@end