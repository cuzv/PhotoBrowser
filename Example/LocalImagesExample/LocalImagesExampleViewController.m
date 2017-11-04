//
//  ViewController.m
//  PhotoBrowserSample
//
//  Created by Roy Shaw on 8/31/15.
//  Copyright (c) 2015 Roy Shaw. All rights reserved.
//

#import "LocalImagesExampleViewController.h"
#import "PBViewController.h"
#import "UIView+LayerImage.h"
#import <SDWebImage/UIImage+GIF.h>

@interface LocalImagesExampleViewController () <PBViewControllerDataSource, PBViewControllerDelegate>
@property (nonatomic, strong) NSArray *frames;
@property (nonatomic, strong) NSMutableArray<UIView *> *imageViews;
@property (nonatomic, assign) BOOL thumb;
@end

@implementation LocalImagesExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageViews = [@[] mutableCopy];
    for (NSInteger index = 0; index < self.frames.count; ++index) {
        UIView *imageView = [UIView new];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.backgroundColor = [UIColor orangeColor];
        imageView.frame = [self.frames[index] CGRectValue];
        imageView.tag = index;
        imageView.userInteractionEnabled = YES;
        imageView.layer.borderColor = [UIColor redColor].CGColor;
        imageView.layer.borderWidth = 1;
        NSString *imageName = [NSString stringWithFormat:@"little_%@", @(index + 1)];
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"]];
//        imageView.layer.contents = (__bridge id _Nullable)(image.CGImage);
        imageView.layerImage = image;
        [self.view addSubview:imageView];
        [self.imageViews addObject:imageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapedImageView:)];
        [imageView addGestureRecognizer:tap];
    }
    
    self.thumb = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Don't Use Thumb" style:UIBarButtonItemStylePlain target:self action:@selector(_thumb:)];

}

- (void)handleTapedImageView:(UITapGestureRecognizer *)sender {
    [self _showPhotoBrowser:sender.view];
}

- (void)_showPhotoBrowser:(UIView *)sender {
    PBViewController *pbViewController = [PBViewController new];
    pbViewController.blurBackground = NO;
//    pbViewController.hideThumb = NO;
    pbViewController.pb_dataSource = self;
    pbViewController.pb_delegate = self;
    pbViewController.pb_startPage = sender.tag;
    [self presentViewController:pbViewController animated:YES completion:^{
    }];
}

- (void)_thumb:(UIBarButtonItem *)sender {
    self.thumb = !self.thumb;
    sender.title = !self.thumb ? @"Use Thumb" : @"Don't Use Thumb";
}

- (NSArray *)frames {
    NSValue *frame1 = [NSValue valueWithCGRect:CGRectMake(20, 70, 80, 80)]; // 正方形
    NSValue *frame2 = [NSValue valueWithCGRect:CGRectMake(110, 70, 120, 80)]; // 长方形 (w>h)
    NSValue *frame3 = [NSValue valueWithCGRect:CGRectMake(240, 70, 80, 100)]; // 长方形 (h>w)
    
    NSValue *frame4 = [NSValue valueWithCGRect:CGRectMake(20, 180, 80, 80)]; // 正方形
    NSValue *frame5 = [NSValue valueWithCGRect:CGRectMake(110, 180, 120, 80)]; // 长方形 (w>h)
    NSValue *frame6 = [NSValue valueWithCGRect:CGRectMake(240, 180, 80, 100)]; // 长方形 (h>w)
    
    NSValue *frame7 = [NSValue valueWithCGRect:CGRectMake(20, 290, 80, 80)]; // 正方形
    NSValue *frame8 = [NSValue valueWithCGRect:CGRectMake(110, 290, 120, 80)]; // 长方形 (w>h)
    NSValue *frame9 = [NSValue valueWithCGRect:CGRectMake(240, 290, 80, 100)]; // 长方形 (h>w)
    
    NSValue *frame10 = [NSValue valueWithCGRect:CGRectMake(20, 400, 80, 80)]; // 正方形
    NSValue *frame11 = [NSValue valueWithCGRect:CGRectMake(110, 400, 120, 80)]; // 长方形 (w>h)
    NSValue *frame12 = [NSValue valueWithCGRect:CGRectMake(270, 400, 80, 130)]; // 长方形 (h>w)
    
    NSValue *frame13 = [NSValue valueWithCGRect:CGRectMake(20, 490, 120, 120)]; // 正方形
    NSValue *frame14 = [NSValue valueWithCGRect:CGRectMake(150, 490, 100, 160)]; // 等比例
    NSValue *frame15 = [NSValue valueWithCGRect:CGRectMake(270, 550, 100, 100)]; // GIF
    
    return @[frame1, frame2, frame3, frame4, frame5, frame6, frame7, frame8, frame9, frame10, frame11, frame12, frame13, frame14, frame15];
}

#pragma mark - PBViewControllerDataSource

- (NSInteger)numberOfPagesInViewController:(PBViewController *)viewController {
    return self.frames.count;
}

- (UIImage *)viewController:(PBViewController *)viewController imageForPageAtIndex:(NSInteger)index {
    NSString *path = [[NSBundle mainBundle] pathForResource:[@(index + 1) stringValue] ofType:@"jpg"];
    if (index == 14) {
        // GIF Support.
        NSData *rawData = [NSData dataWithContentsOfFile:path];
        return [UIImage sd_animatedGIFWithData:rawData];
    } else {
        return [UIImage imageWithContentsOfFile:path];
    }
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
