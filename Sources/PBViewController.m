//
//  PBViewController.m
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

#import "PBViewController.h"
#import "PBImageScrollerViewController.h"
#import "UIView+PBSnapshot.h"
#import "PBImageScrollView.h"
#import "PBImageScrollView+internal.h"
#import "PBPresentAnimatedTransitioningController.h"

@interface PBViewController () <
    UIPageViewControllerDataSource,
    UIPageViewControllerDelegate,
    UIViewControllerTransitioningDelegate
>

@property (nonatomic, strong) NSArray<PBImageScrollerViewController *> *reusableImageScrollerViewControllers;
@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentPage;

/// Images count >9, use this for indicate
@property (nonatomic, strong) UILabel *indicatorLabel;
/// Images count <=9, use this for indicate
@property (nonatomic, strong) UIPageControl *indicatorPageControl;
/// Blur background view
@property (nonatomic, strong) UIView *blurBackgroundView;

/// Gestures
@property (nonatomic, strong) UITapGestureRecognizer *singleTapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (nonatomic, strong) PBPresentAnimatedTransitioningController *transitioningController;
//@property (nonatomic, assign) BOOL dismissing;
@property (nonatomic, assign) CGFloat verticalVelocity;

@end

@implementation PBViewController

#pragma mark - respondsToSelector

#if DEBUG
- (void)dealloc {
    NSLog(@"~~~~~~~~~~~%s~~~~~~~~~~~", __FUNCTION__);
}
#endif

- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style
                  navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation
                                options:(NSDictionary *)options {
    NSMutableDictionary *dict = [(options ?: @{}) mutableCopy];
    [dict setObject:@(20) forKey:UIPageViewControllerOptionInterPageSpacingKey];
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                    navigationOrientation:navigationOrientation
                                  options:dict];
    if (!self) {
        return nil;
    }
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.transitioningDelegate = self;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set numberOfPages
    if ([self.pb_dataSource conformsToProtocol:@protocol(PBViewControllerDataSource)] &&
        [self.pb_dataSource respondsToSelector:@selector(numberOfPagesInViewController:)]) {
        self.numberOfPages = [self.pb_dataSource numberOfPagesInViewController:self];
    }
    
    // Set visible view controllers
    self.currentPage = 0 < self.currentPage && self.currentPage < self.numberOfPages ? self.currentPage : 0;
    PBImageScrollerViewController *firstImageScrollerViewController = [self _imageScrollerViewControllerForPage:self.currentPage];
    [self setViewControllers:@[firstImageScrollerViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Set indicatorLabel
    [self _addIndicator];
    // Blur background
    [self _addBlurBackgroundView];
    
    self.view.layer.contents = (id)[self.presentingViewController.view pb_snapshotAfterScreenUpdates:NO].CGImage;

    [self.view addGestureRecognizer:self.longPressGestureRecognizer];
    [self.view addGestureRecognizer:self.doubleTapGestureRecognizer];
    [self.view addGestureRecognizer:self.singleTapGestureRecognizer];
    [self.singleTapGestureRecognizer requireGestureRecognizerToFail:self.longPressGestureRecognizer];
    [self.singleTapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];
    
    self.dataSource = self;
    self.delegate = self;
    
    [self _setupTransitioningController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self isBeingPresented]) {
        [self _hideStatusBarIfNeeded];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self _updateIndicator];
    [self _updateBlurBackgroundView];
}

#pragma mark - Public method

- (void)setInitializePageIndex:(NSInteger)pageIndex {
    self.pb_startPage = pageIndex;
}

- (void)setPb_startPage:(NSInteger)pb_startPage {
    _pb_startPage = pb_startPage;
    _currentPage = pb_startPage;
}

#pragma mark - Private methods

- (void)_addIndicator {
    if (self.numberOfPages <= 9) {
        [self.view addSubview:self.indicatorPageControl];
    } else {
        [self.view addSubview:self.indicatorLabel];
    }
}

- (void)_updateIndicator {
    if (self.numberOfPages <= 9) {
        self.indicatorPageControl.currentPage = self.currentPage;
        [self.indicatorPageControl sizeToFit];
        self.indicatorPageControl.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0f,
                                                       CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.indicatorPageControl.bounds) / 2.0f);
    } else {
        NSString *indicatorText = [NSString stringWithFormat:@"%@/%@", @(self.currentPage + 1), @(self.numberOfPages)];
        self.indicatorLabel.text = indicatorText;
        [self.indicatorLabel sizeToFit];
        self.indicatorLabel.center = CGPointMake(CGRectGetWidth(self.view.bounds) / 2.0f,
                                                 CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.indicatorLabel.bounds));
    }
}

- (void)_addBlurBackgroundView {
    [self.view addSubview:self.blurBackgroundView];
    [self.view sendSubviewToBack:self.blurBackgroundView];
}

- (void)_updateBlurBackgroundView {
    self.blurBackgroundView.frame = self.view.bounds;
}

- (void)_hideStatusBarIfNeeded {
//    self.blurBackgroundView.window.windowLevel = UIWindowLevelStatusBar;
    if ([UIApplication sharedApplication].statusBarHidden) {
        return;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)_showStatusBarIfNeeded {
//    self.blurBackgroundView.window.windowLevel = UIWindowLevelNormal;
    if (![UIApplication sharedApplication].statusBarHidden) {
        return;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (PBImageScrollerViewController *)_imageScrollerViewControllerForPage:(NSInteger)page {
    if (page > self.numberOfPages - 1 || page < 0) {
        return nil;
    }
    
    // Get the reusable `PBImageScrollerViewController`
    PBImageScrollerViewController *imageScrollerViewController = self.reusableImageScrollerViewControllers[page % 3];

    // Set new data
    if (!self.pb_dataSource) {
        [NSException raise:@"Must implement `PBViewControllerDataSource` protocol." format:@""];
    }
    
    __weak typeof(self) weak_self = self;
    if ([self.pb_dataSource conformsToProtocol:@protocol(PBViewControllerDataSource)]) {
        imageScrollerViewController.page = page;
        
        if ([self.pb_dataSource respondsToSelector:@selector(viewController:imageForPageAtIndex:)]) {
            imageScrollerViewController.fetchImageHandler = ^UIImage *(void) {
                __strong typeof(weak_self) strong_self = weak_self;
                return [strong_self.pb_dataSource viewController:strong_self imageForPageAtIndex:page];
            };
        } else if ([self.pb_dataSource respondsToSelector:@selector(viewController:presentImageView:forPageAtIndex:progressHandler:)]) {
            imageScrollerViewController.configureImageViewWithDownloadProgressHandler = ^(UIImageView *imageView, PBImageDownloadProgressHandler handler) {
                __strong typeof(weak_self) strong_self = weak_self;
                [strong_self.pb_dataSource viewController:strong_self presentImageView:imageView forPageAtIndex:page progressHandler:handler];
            };
        } else if ([self.pb_dataSource respondsToSelector:@selector(viewController:presentImageView:forPageAtIndex:)]) {
            imageScrollerViewController.configureImageViewHandler = ^(UIImageView *imageView) {
                __strong typeof(weak_self) strong_self = weak_self;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [strong_self.pb_dataSource viewController:strong_self presentImageView:imageView forPageAtIndex:page];
#pragma clang diagnostic pop
            };
        }
    }
    
    return imageScrollerViewController;
}

- (void)_setupTransitioningController {
    __weak typeof(self) weak_self = self;
    self.transitioningController.prepareForPresentActionHandler = ^(UIView *fromView, UIView *toView) {
        __strong typeof(weak_self) strong_self = weak_self;
        strong_self.blurBackgroundView.alpha = 0;
    };
    self.transitioningController.duringPresentingActionHandler = ^(UIView *fromView, UIView *toView) {
        __strong typeof(weak_self) strong_self = weak_self;
        strong_self.blurBackgroundView.alpha = 1;
    };
    self.transitioningController.prepareForDismissActionHandler = ^(UIView *fromView, UIView *toView) {
        __strong typeof(weak_self) strong_self = weak_self;
        [strong_self _prepareForDismiss];
    };
    self.transitioningController.duringDismissingActionHandler = ^(UIView *fromView, UIView *toView) {
        __strong typeof(weak_self) strong_self = weak_self;
        [strong_self _duringDismissing];
    };
}

- (void)_prepareForDismiss {
    PBImageScrollerViewController *currentScrollViewController = self.currentScrollViewController;
    PBImageScrollView *imageScrollView = currentScrollViewController.imageScrollView;
    // 干掉加载动画。
    imageScrollView.progressLayer.hidden = YES;
    // 还原 zoom.
    if (imageScrollView.zoomScale != 1) {
        [imageScrollView setZoomScale:1 animated:YES];
    }
    // 如果内容很长的话（长微博），并且当前处于图片中间某个位置，没有超出顶部或者底部，需要特殊处理。
    CGFloat contentHeight = imageScrollView.contentSize.height;
    CGFloat scrollViewHeight = CGRectGetHeight(imageScrollView.bounds);
    if (contentHeight > scrollViewHeight) {
        CGFloat offsetY = imageScrollView.contentOffset.y;
        if (offsetY < 0) {
            return;
        }
        if (offsetY + scrollViewHeight > contentHeight) {
            return;
        }
        // 无 thumbView, 并且内容长度超过屏幕，非滑动退出模式。替换图片。
        if (0 == self.verticalVelocity && !self.currentThumbView) {
            UIImage *image = [self.view pb_snapshotAfterScreenUpdates:NO];
            imageScrollView.imageView.image = image;
        }
        // 还原到页面顶部
        [imageScrollView setContentOffset:CGPointZero animated:NO];
    }
}

- (void)_duringDismissing {
    PBImageScrollView *imageScrollView = self.currentScrollViewController.imageScrollView;
    UIImageView *imageView = imageScrollView.imageView;
    UIImage *currentImage = imageView.image;
    /// 图片未加载，默认 CrossDissolve 动画。
    if (!currentImage) {
        return;
    }
    
    [self _showStatusBarIfNeeded];
    self.blurBackgroundView.alpha = 0;

    /// present 之前显示的图片视图。
    UIView *thumbView = self.currentThumbView;
    CGRect destFrame;    
    if (thumbView) {
        imageView.clipsToBounds = thumbView.clipsToBounds;
        imageView.contentMode = thumbView.contentMode;
        // 还原到起始位置然后 dismiss.
        destFrame = [thumbView.superview convertRect:thumbView.frame toView:self.currentScrollViewController.view];
        // 把 contentInset 考虑进来。
        CGFloat verticalInset = imageScrollView.contentInset.top + imageScrollView.contentInset.bottom;
        destFrame = CGRectMake(CGRectGetMinX(destFrame), CGRectGetMinY(destFrame) - verticalInset, CGRectGetWidth(destFrame), CGRectGetHeight(destFrame));
    } else {
        // 移动到屏幕外然后 dismiss.
        if (0 == self.verticalVelocity) {
            // 非滑动退出，中间
            destFrame = CGRectMake(CGRectGetWidth(imageScrollView.bounds) / 2, CGRectGetHeight(imageScrollView.bounds) / 2, 0, 0);
            // 图片渐变
            imageScrollView.alpha = 0;
        } else {
            CGFloat width = CGRectGetWidth(imageScrollView.imageView.bounds);
            CGFloat height = CGRectGetHeight(imageScrollView.imageView.bounds);
            if (0 < self.verticalVelocity) {
                // 向上
                destFrame = CGRectMake(0, -height, width, height);
            } else {
                // 向下
                destFrame = CGRectMake(0, CGRectGetHeight(imageScrollView.bounds), width, height);
            }
        }
    }
    
    imageView.frame = destFrame;
}


#pragma mark - Actions

- (void)_handleSingleTapAction:(UITapGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    if (!self.pb_delegate) {
        return;
    }
    if ([self.pb_delegate conformsToProtocol:@protocol(PBViewControllerDelegate)]) {
        if ([self.pb_delegate respondsToSelector:@selector(viewController:didSingleTapedPageAtIndex:presentedImage:)]) {
            [self.pb_delegate viewController:self didSingleTapedPageAtIndex:self.currentPage presentedImage:self.currentScrollViewController.imageScrollView.imageView.image];
        }
    }
}

- (void)_handleDoubleTapAction:(UITapGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    CGPoint location = [sender locationInView:self.view];
    PBImageScrollView *imageScrollView = self.currentScrollViewController.imageScrollView;
    [imageScrollView _handleZoomForLocation:location];
}

- (void)_handleLongPressAction:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateEnded) {
        return;
    }
    if (!self.pb_delegate) {
        return;
    }
    if ([self.pb_delegate conformsToProtocol:@protocol(PBViewControllerDelegate)]) {
        if ([self.pb_delegate respondsToSelector:@selector(viewController:didLongPressedPageAtIndex:presentedImage:)]) {
            [self.pb_delegate viewController:self didLongPressedPageAtIndex:self.currentPage presentedImage:self.currentScrollViewController.imageScrollView.imageView.image];
        }
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(PBImageScrollerViewController *)viewController {
    return [self _imageScrollerViewControllerForPage:viewController.page - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(PBImageScrollerViewController *)viewController {
    return [self _imageScrollerViewControllerForPage:viewController.page + 1];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    // 如果取消切换，还原位置和大小。
    if (!completed) {
        for (PBImageScrollerViewController *previous in previousViewControllers) {
            [previous.imageScrollView _updateUserInterfaces];
        }
        return;
    }
    PBImageScrollerViewController *imageScrollerViewController = pageViewController.viewControllers.firstObject;
    self.currentPage = imageScrollerViewController.page;
    [self _updateIndicator];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented  presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [self.transitioningController pb_prepareForPresent];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [self.transitioningController pb_prepareForDismiss];
}

#pragma mark - Accessor

- (NSArray<PBImageScrollerViewController *> *)reusableImageScrollerViewControllers {
    if (!_reusableImageScrollerViewControllers) {
        NSMutableArray *controllers = [[NSMutableArray alloc] initWithCapacity:3];
        for (NSInteger index = 0; index < 3; index++) {
            PBImageScrollerViewController *imageScrollerViewController = [PBImageScrollerViewController new];
            imageScrollerViewController.page = index;
            __weak typeof(self) weak_self = self;
            imageScrollerViewController.imageScrollView.contentOffSetVerticalPercent = ^(CGFloat percent) {
                __strong typeof(weak_self) strong_self = weak_self;
                strong_self.blurBackgroundView.alpha = 1.0f - percent;
                NSLog(@"percent: %@", @(percent));
            };
            imageScrollerViewController.imageScrollView.didEndDraggingWithScrollEnough = ^(CGFloat verticalVelocity){
                __strong typeof(weak_self) strong_self = weak_self;
                strong_self.verticalVelocity = verticalVelocity;
                [strong_self dismissViewControllerAnimated:YES completion:nil];
            };
            [controllers addObject:imageScrollerViewController];
        }
        _reusableImageScrollerViewControllers = [[NSArray alloc] initWithArray:controllers];
    }
    return _reusableImageScrollerViewControllers;
}

- (UILabel *)indicatorLabel {
    if (!_indicatorLabel) {
        _indicatorLabel = [UILabel new];
        _indicatorLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
        _indicatorLabel.textAlignment = NSTextAlignmentCenter;
        _indicatorLabel.textColor = [UIColor whiteColor];
    }
    return _indicatorLabel;
}

- (UIPageControl *)indicatorPageControl {
    if (!_indicatorPageControl) {
        _indicatorPageControl = [UIPageControl new];
        _indicatorPageControl.numberOfPages = self.numberOfPages;
        _indicatorPageControl.currentPage = self.currentPage;
    }
    return _indicatorPageControl;
}

- (UIView *)blurBackgroundView {
    if (!_blurBackgroundView) {
        UIToolbar *view = [[UIToolbar alloc] initWithFrame:self.view.bounds];
        view.barStyle = UIBarStyleBlack;
        view.translucent = YES;
        view.clipsToBounds = YES;
        view.multipleTouchEnabled = NO;
        view.userInteractionEnabled = NO;
        _blurBackgroundView = view;
        
    }
    return _blurBackgroundView;
}

- (UITapGestureRecognizer *)singleTapGestureRecognizer {
    if (!_singleTapGestureRecognizer) {
        _singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleSingleTapAction:)];
    }
    return _singleTapGestureRecognizer;
}

- (UITapGestureRecognizer *)doubleTapGestureRecognizer {
    if (!_doubleTapGestureRecognizer) {
        _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleDoubleTapAction:)];
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    }
    return _doubleTapGestureRecognizer;
}

- (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (!_longPressGestureRecognizer) {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleLongPressAction:)];
    }
    return _longPressGestureRecognizer;
}

- (PBImageScrollerViewController *)currentScrollViewController {
    return self.reusableImageScrollerViewControllers[self.currentPage % 3];
}

- (UIView *)currentThumbView {
    if (!self.pb_dataSource) {
        return nil;
    }
    if (![self.pb_dataSource conformsToProtocol:@protocol(PBViewControllerDataSource)]) {
        return nil;
    }
    if (![self.pb_dataSource respondsToSelector:@selector(thumbViewForPageAtIndex:)]) {
        return  nil;
    }
    return [self.pb_dataSource thumbViewForPageAtIndex:self.currentPage];
}

- (PBPresentAnimatedTransitioningController *)transitioningController {
    if (!_transitioningController) {
        _transitioningController = [PBPresentAnimatedTransitioningController new];
    }
    return _transitioningController;
}

@end
