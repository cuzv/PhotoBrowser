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
#import "PBViewControllerDataSource.h"
#import "PBViewControllerDelegate.h"

@interface PBViewController () <
    UIPageViewControllerDataSource,
    UIPageViewControllerDelegate
>

@property (nonatomic, strong) NSArray *reusableImageScrollerViewControllers;
@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) UILabel *indicatorLabel;
@end

@implementation PBViewController

- (instancetype)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style
                  navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation
                                options:(NSDictionary *)options {
    options = options ?: @{};
    NSMutableDictionary *dict = [options mutableCopy];
    [dict setObject:@(20) forKey:UIPageViewControllerOptionInterPageSpacingKey];
    self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                    navigationOrientation:navigationOrientation
                                  options:dict];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor blackColor];
    
    // Set numberOfPages
    if ([self.pb_dataSource conformsToProtocol:@protocol(PBViewControllerDataSource)] &&
        [self.pb_dataSource respondsToSelector:@selector(numberOfPagesInViewController:)]) {
        self.numberOfPages = [self.pb_dataSource numberOfPagesInViewController:self];
    }
    
    // Set indicatorLabel
    [self.view addSubview:self.indicatorLabel];

    // Set visible view controllers
    self.currentPage = 0 < self.currentPage && self.currentPage < self.numberOfPages ? self.currentPage : 0;
    PBImageScrollerViewController *firstImageScrollerViewController = [self _imageScrollerViewControllerForPage:self.currentPage];
    [self setViewControllers:@[firstImageScrollerViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    self.dataSource = self;
    self.delegate = self;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self _updateIndicator];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - Inner methods

- (PBImageScrollerViewController *)_imageScrollerViewControllerForPage:(NSInteger)page {
    if (page > self.numberOfPages-1 ||
        page < 0) {
        return nil;
    }
    
    // Get the reusable `PBImageScrollerViewController`
    NSInteger index = page % 3;
    NSLog(@"page:%@ -> index: %@", @(page), @(index));
    // Get reusable controller
    PBImageScrollerViewController *imageScrollerViewController = [self.reusableImageScrollerViewControllers objectAtIndex:index];

    __weak typeof(self) weak_self = self;

    // Set new data
    if (self.pb_dataSource &&
        [self.pb_dataSource conformsToProtocol:@protocol(PBViewControllerDataSource)]) {
        imageScrollerViewController.page = page;
        if ([self.pb_dataSource respondsToSelector:@selector(viewController:imageForPageAtIndex:)]) {
            imageScrollerViewController.fetchImageBlock = ^UIImage*(void) {
                __strong typeof(weak_self) strong_self = weak_self;
                UIImage *image = [strong_self.pb_dataSource viewController:strong_self imageForPageAtIndex:page];
                return image;
            };
        }
        if ([self.pb_dataSource respondsToSelector:@selector(viewController:presentImageView:forPageAtIndex:)]) {
            imageScrollerViewController.configureImageViewBlock = ^(UIImageView *imageView) {
                __strong typeof(weak_self) strong_self = weak_self;
                [strong_self.pb_dataSource viewController:strong_self presentImageView:imageView forPageAtIndex:page];
            };
        }
    }
    // Set delegate callback
    if (self.pb_delegate &&
        [self.pb_delegate conformsToProtocol:@protocol(PBViewControllerDelegate)]) {
        if ([self.pb_delegate respondsToSelector:@selector(viewController:didSingleTapedPageAtIndex:presentedImage:)]) {
            imageScrollerViewController.didSingleTaped = ^(UIImage *image) {
                __strong typeof(weak_self) strong_self = weak_self;
                [strong_self.pb_delegate viewController:strong_self didSingleTapedPageAtIndex:page presentedImage:image];
            };
        }
        if ([self.pb_delegate respondsToSelector:@selector(viewController:didLongPressedPageAtIndex:presentedImage:)]) {
            imageScrollerViewController.didLongPressed = ^(UIImage *image) {
                __strong typeof(weak_self) strong_self = weak_self;
                [strong_self.pb_delegate viewController:strong_self didLongPressedPageAtIndex:page presentedImage:image];
            };
        }
    }

    return imageScrollerViewController;
}

- (void)_updateIndicator {
    NSString *indicator = [NSString stringWithFormat:@"%@/%@", @(self.currentPage+1), @(self.numberOfPages)];
    self.indicatorLabel.text = indicator;
    [self.indicatorLabel sizeToFit];
    self.indicatorLabel.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2.0,
                                             CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.indicatorLabel.bounds)/2);
}

#pragma mark - Public method

- (void)setInitializePageIndex:(NSInteger)pageIndex {
    self.currentPage = pageIndex;
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(PBImageScrollerViewController *)viewController {
    return [self _imageScrollerViewControllerForPage:viewController.page-1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(PBImageScrollerViewController *)viewController {
    return [self _imageScrollerViewControllerForPage:viewController.page+1];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    PBImageScrollerViewController *imageScrollerViewController = pageViewController.viewControllers.firstObject;
    self.currentPage = imageScrollerViewController.page;
    [self _updateIndicator];
}

#pragma mark - Accessor

- (NSArray *)reusableImageScrollerViewControllers {
    if (!_reusableImageScrollerViewControllers) {
        NSMutableArray *controllers = [NSMutableArray new];
        for (NSInteger index = 0; index < 3; index++) {
            PBImageScrollerViewController *imageScrollerViewController = [PBImageScrollerViewController new];
            imageScrollerViewController.page = index;
            [controllers addObject:imageScrollerViewController];
        }
        _reusableImageScrollerViewControllers = [NSArray arrayWithArray:controllers];
    }
    return _reusableImageScrollerViewControllers;
}

- (UILabel *)indicatorLabel {
    if (!_indicatorLabel) {
        _indicatorLabel = [UILabel new];
        _indicatorLabel.textColor = [UIColor whiteColor];
    }
    return _indicatorLabel;
}

@end
