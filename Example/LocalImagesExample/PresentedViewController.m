//
//  PresentedViewController.m
//  PhotoBrowser
//
//  Created by Moch Xiao on 5/17/16.
//  Copyright © 2016 Moch. All rights reserved.
//

#import "PresentedViewController.h"
#import "PBPresentAnimatedTransitioningController.h"

@interface PresentedViewController ()
@property (nonatomic, strong) UIView *colorView;
@property (nonatomic, strong) PBPresentAnimatedTransitioningController *transitioningController;
@end

@implementation PresentedViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];;
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
    
    [self.view addSubview:self.colorView];
    self.colorView.frame = CGRectMake(20, 80, 120, 120);
    [self _setupTransitioningController];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_setupTransitioningController {
    __weak typeof(self) weak_self = self;
    self.transitioningController.prepareForPresentActionHandler = ^(UIView *fromView, UIView *toView) {
        //        __strong typeof(weak_self) strong_self = weak_self;
    };
    self.transitioningController.duringPresentingActionHandler = ^(UIView *fromView, UIView *toView) {
        //        __strong typeof(weak_self) strong_self = weak_self;
    };
    self.transitioningController.prepareForDismissActionHandler = ^(UIView *fromView, UIView *toView) {
//        __strong typeof(weak_self) strong_self = weak_self;
    };
    self.transitioningController.duringDismissingActionHandler = ^(UIView *fromView, UIView *toView) {
        __strong typeof(weak_self) strong_self = weak_self;
        strong_self.colorView.frame = CGRectMake(20, CGRectGetHeight(strong_self.view.bounds), 120, 120);
    };
    //    self.transitioningController.coverView = self.blurBackgroundView;
}

- (UIView *)colorView {
    if (!_colorView) {
        _colorView = [UIView new];
        _colorView.backgroundColor = [UIColor orangeColor];
    }
    return _colorView;
}

- (PBPresentAnimatedTransitioningController *)transitioningController {
    if (!_transitioningController) {
        _transitioningController = [PBPresentAnimatedTransitioningController new];
    }
    return _transitioningController;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented  presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [self.transitioningController pb_prepareForPresent];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [self.transitioningController pb_prepareForDismiss];
}



@end
