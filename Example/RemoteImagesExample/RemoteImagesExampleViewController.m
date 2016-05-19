//
//  DemoViewController.m
//  PhotoBrowser
//
//  Created by Moch Xiao on 5/13/16.
//  Copyright © 2016 Moch Xiao. All rights reserved.
//

#import "RemoteImagesExampleViewController.h"
#import "PBViewController.h"
#import "PBImageScrollerViewController.h"
#import "UIView+PBSnapshot.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface RemoteImagesExampleViewController () <PBViewControllerDataSource, PBViewControllerDelegate>
@property (nonatomic, strong) NSArray *frames;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *imageViews;
@property (nonatomic, assign) BOOL thumb;
@end

@implementation RemoteImagesExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.thumb = YES;
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
    
    UIBarButtonItem *clear = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStylePlain target:self action:@selector(_clear)];
    UIBarButtonItem *thumb = [[UIBarButtonItem alloc] initWithTitle:@"Don't Use Thumb" style:UIBarButtonItemStylePlain target:self action:@selector(_thumb:)];
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 44, CGRectGetWidth(self.view.bounds), 44);
    [toolbar setItems:@[clear, thumb] animated:NO];
    [self.view addSubview:toolbar];
}

- (void)handleTapedImageView:(UITapGestureRecognizer *)sender {
    [self _showPhotoBrowser:sender.view];
}

- (void)_showPhotoBrowser:(UIView *)sender {
    PBViewController *pbViewController = [PBViewController new];
    pbViewController.pb_dataSource = self;
    pbViewController.pb_delegate = self;
    pbViewController.pb_startPage = sender.tag;
    [self presentViewController:pbViewController animated:YES completion:nil];
}


- (void)_clear {
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        NSLog(@"Cache clear complete.");
    }];
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
    
//    NSValue *frame10 = [NSValue valueWithCGRect:CGRectMake(120, 470, 120, 100)];
//    return @[frame1, frame2, frame3, frame4, frame5, frame6, frame7, frame8, frame9, frame10];
    
    return @[frame1, frame2, frame3, frame4, frame5, frame6, frame7, frame8, frame9];
}

#pragma mark - PBViewControllerDataSource

- (NSInteger)numberOfPagesInViewController:(PBViewController *)viewController {
    return self.frames.count;
}

- (void)viewController:(PBViewController *)viewController presentImageView:(UIImageView *)imageView forPageAtIndex:(NSInteger)index progressHandler:(void (^)(NSInteger, NSInteger))progressHandler {
    NSString *url = [NSString stringWithFormat:@"https://raw.githubusercontent.com/cuzv/PhotoBrowser/dev/Example/Assets/%@.jpg", @(index + 1)];
    UIImage *placeholder = self.imageViews[index].image;
    [imageView sd_setImageWithURL:[NSURL URLWithString:url]
                 placeholderImage:placeholder
                          options:0
                         progress:progressHandler
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            
                        }];
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
