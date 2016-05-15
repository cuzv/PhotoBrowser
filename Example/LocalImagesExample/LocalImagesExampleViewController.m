//
//  ViewController.m
//  PhotoBrowserSample
//
//  Created by Moch Xiao on 8/31/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import "LocalImagesExampleViewController.h"
#import "PBViewController.h"
#import "PBViewControllerDataSource.h"
#import "PBImageScrollerViewController.h"
#import "PBViewControllerDelegate.h"

@interface LocalImagesExampleViewController () <PBViewControllerDataSource, PBViewControllerDelegate>
@property (nonatomic, strong) NSArray *urls;
@end

@implementation LocalImagesExampleViewController

- (IBAction)showPhotoBrowser:(UIButton *)sender {
    PBViewController *pbViewController = [PBViewController new];
    pbViewController.pb_dataSource = self;
    pbViewController.pb_delegate = self;
    pbViewController.pb_startPage = 2;
    [self presentViewController:pbViewController animated:YES completion:nil];
}

#pragma mark - PBViewControllerDataSource

- (NSInteger)numberOfPagesInViewController:(PBViewController *)viewController {
    return 9;
}

- (UIImage *)viewController:(PBViewController *)viewController imageForPageAtIndex:(NSInteger)index {
    NSString *name = [NSString stringWithFormat:@"%@.jpg", @(index+1)];
    return [UIImage imageNamed:name];
}

#pragma mark - PBViewControllerDelegate

- (void)viewController:(PBViewController *)viewController didSingleTapedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage {
    NSLog(@"didSingleTapedPageAtIndex: %@", @(index));
    [viewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewController:(PBViewController *)viewController didLongPressedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage {
    NSLog(@"didLongPressedPageAtIndex: %@", @(index));
}

@end
