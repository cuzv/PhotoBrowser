//
//  ViewController.m
//  PhotoBrowserSample
//
//  Created by Moch Xiao on 8/31/15.
//  Copyright (c) 2015 Moch Xiao. All rights reserved.
//

#import "ViewController.h"
#import "PBViewController.h"
#import "PBViewControllerDataSource.h"
#import "PBImageScrollerViewController.h"
#import "PBViewControllerDelegate.h"

@interface ViewController () <PBViewControllerDataSource, PBViewControllerDelegate>
@property (nonatomic, strong) NSArray *urls;
@end

@implementation ViewController

- (IBAction)showPhotoBrowser:(UIButton *)sender {
    
    PBViewController *pbViewController = [PBViewController new];
    pbViewController.pb_dataSource = self;
    pbViewController.pb_delegate = self;
    [pbViewController setInitializePageIndex:2];
    [self presentViewController:pbViewController animated:YES completion:nil];
    
//    PBImageScrollerViewController *viewController = [PBImageScrollerViewController new];
//    [self presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - PBViewControllerDataSource

- (NSInteger)numberOfPagesInViewController:(PBViewController *)viewController {
    return 4;
}

- (UIImage *)viewController:(PBViewController *)viewController imageForPageAtIndex:(NSInteger)index {
    NSString *name = [NSString stringWithFormat:@"%@.jpg", @(index+1)];
    return [UIImage imageNamed:name];
//    return [UIImage imageNamed:@"zombies.jpg"];
//    return [UIImage imageNamed:@"long"];
}

//- (void)viewController:(PBViewController *)viewController presentImageView:(UIImageView *)imageView forPageAtIndex:(NSInteger)index {
////    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////        NSString *name = [NSString stringWithFormat:@"%@.jpg", @(index+1)];
////        UIImage *image = [UIImage imageNamed:name];
////        imageView.image = image;
////    });
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSString *path = self.urls[index];
//        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:path] options:0 error:nil];
//        UIImage *image = [[UIImage alloc] initWithData:data];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            // 主线程
//            imageView.image = image;
//        });
//    });
//}

#pragma mark - PBViewControllerDelegate

- (void)viewController:(PBViewController *)viewController didSingleTapedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage {
    NSLog(@"didSingleTapedPageAtIndex: %@", @(index));
    [viewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewController:(PBViewController *)viewController didLongPressedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage {
    NSLog(@"didLongPressedPageAtIndex: %@", @(index));
}

#pragma mark - 

- (NSArray *)urls {
    if (!_urls) {
        _urls = @[@"http://www.potatofeed.com/wp-content/uploads/2015/04/got-game-of-thrones-35086026-705-420.jpg",
                  @"http://i.telegraph.co.uk/multimedia/archive/02990/dragon_2990241c.jpg",
                  @"http://cdn3.denofgeek.us/sites/denofgeekus/files/got1_2.jpg",
                  @"http://cdn.wallstcheatsheet.com/wp-content/uploads/2013/05/Sean_Bean_Game_of_Thrones.jpg"];
    }
    return _urls;
}


@end
