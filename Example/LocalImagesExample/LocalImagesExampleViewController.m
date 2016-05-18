//
//  ViewController.m
//  PhotoBrowserSample
//
//  Created by Moch Xiao on 8/31/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import "LocalImagesExampleViewController.h"
#import "PBViewController.h"
#import "PBImageScrollerViewController.h"
#import "UIView+PBSnapshot.h"
#import "PhotoBrowser.h"
#import "PresentedViewController.h"

@interface LocalImagesExampleViewController () <PBViewControllerDataSource, PBViewControllerDelegate>
@property (nonatomic, strong) NSArray *frames;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *imageViews;
@property (nonatomic, assign) BOOL thumb;
@end

@implementation LocalImagesExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageViews = [@[] mutableCopy];
    for (NSInteger index = 0; index < self.frames.count; ++index) {
        UIImageView *imageView = [UIImageView new];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.backgroundColor = [UIColor blackColor];
        imageView.frame = [self.frames[index] CGRectValue];
        imageView.tag = index;
        imageView.userInteractionEnabled = YES;
        NSString *imageName = [NSString stringWithFormat:@"%@", @(index + 1)];
        imageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"]];
        [self.view addSubview:imageView];
        [self.imageViews addObject:imageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapedImageView:)];
        [imageView addGestureRecognizer:tap];
    }
    
    self.thumb = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Don't Use Thumb" style:UIBarButtonItemStylePlain target:self action:@selector(_thumb:)];

}

- (void)handleTapedImageView:(UITapGestureRecognizer *)sender {
    [self _showPhotoBrowser:(UIImageView *)sender.view];
}

- (void)_showPhotoBrowser:(UIImageView *)sender {
    PBViewController *pbViewController = [PBViewController new];
    pbViewController.pb_dataSource = self;
    pbViewController.pb_delegate = self;
    pbViewController.pb_startPage = sender.tag;
    [self presentViewController:pbViewController animated:YES completion:nil];
    
//    [self presentViewController:[PresentedViewController new] animated:YES completion:nil];
}

- (void)_thumb:(UIBarButtonItem *)sender {
    self.thumb = !self.thumb;
    sender.title = !self.thumb ? @"Use Thumb" : @"Don't Use Thumb";
}

- (NSArray *)frames {
    NSValue *frame1 = [NSValue valueWithCGRect:CGRectMake(20, 80, 80, 80)];
    NSValue *frame2 = [NSValue valueWithCGRect:CGRectMake(110, 80, 120, 90)];
    NSValue *frame3 = [NSValue valueWithCGRect:CGRectMake(240, 90, 100, 85)];
    
    NSValue *frame4 = [NSValue valueWithCGRect:CGRectMake(20, 180, 75, 110)];
    NSValue *frame5 = [NSValue valueWithCGRect:CGRectMake(110, 185, 150, 90)];
    NSValue *frame6 = [NSValue valueWithCGRect:CGRectMake(270, 190, 100, 100)];
    
    NSValue *frame7 = [NSValue valueWithCGRect:CGRectMake(20, 300, 90, 90)];
    NSValue *frame8 = [NSValue valueWithCGRect:CGRectMake(120, 290, 120, 150)];
    NSValue *frame9 = [NSValue valueWithCGRect:CGRectMake(250, 305, 100, 100)];
    
    NSValue *frame10 = [NSValue valueWithCGRect:CGRectMake(120, 470, 120, 100)];
    
    return @[frame1, frame2, frame3, frame4, frame5, frame6, frame7, frame8, frame9, frame10];
}

#pragma mark - PBViewControllerDataSource

- (NSInteger)numberOfPagesInViewController:(PBViewController *)viewController {
    return self.frames.count;
}

- (UIImage *)viewController:(PBViewController *)viewController imageForPageAtIndex:(NSInteger)index {
    return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[@(index + 1) stringValue] ofType:@"jpg"]];
}

- (UIView *)thumbViewForPageAtIndex:(NSInteger)index {
    if (self.thumb) {
        return self.imageViews[index];
    }
    
    return nil;
}

#pragma mark - PBViewControllerDelegate

- (void)viewController:(PBViewController *)viewController didSingleTapedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewController:(PBViewController *)viewController didLongPressedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage {
    NSLog(@"didLongPressedPageAtIndex: %@", @(index));
}

@end
