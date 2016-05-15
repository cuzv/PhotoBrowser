//
//  PBImageScrollerViewController.m
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

#import "PBImageScrollerViewController.h"
#import "PBImageScrollView.h"
#import "PBImageScrollView+internal.h"

@interface PBImageScrollerViewController ()
@property (nonatomic, strong, readwrite) PBImageScrollView *imageScrollView;
@property (nonatomic, weak, readwrite) UIImageView *imageView;
@end

@implementation PBImageScrollerViewController

#if DEBUG
- (void)dealloc {
    NSLog(@"~~~~~~~~~~~%s~~~~~~~~~~~", __FUNCTION__);
}
#endif

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.imageScrollView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self _prepareForReuse];
    
    if (self.fetchImageHandler) {
        self.imageView.image = self.fetchImageHandler();
    }
    if (self.configureImageViewHandler) {
        self.configureImageViewHandler(self.imageView);
    }
}

#pragma mark - Private methods

- (void)_prepareForReuse {
    self.imageView.image = nil;
}

#pragma mark - Accessor

- (PBImageScrollView *)imageScrollView {
    if (!_imageScrollView) {
        _imageScrollView = [PBImageScrollView new];
    }
    return _imageScrollView;
}

- (UIImageView *)imageView {
    return self.imageScrollView.imageView;
}

@end

