# PhotoBrowser

PhotoBrowser is a light weight photo browser, like the wechat, weibo image viewer.



### TODO

-   [x] Present & Dismissal animation

-   [ ] GIF support



## How does it look like?

<p align="left">

​	<img src="http://ww3.sinaimg.cn/mw690/a0f0598cgw1f4105ulkifg20a60ibkjp.gif" width=44%"></p>

## How to use

- Like the `UITableView` API, We have `DataSource` an `Delegate` for load data and handle action


- Tell `PhotoBrowser` how many pages would you like to present by conforms protocol `PBViewControllerDataSource` and implement `numberOfPagesInViewController:` selector


- Optional set the initialize page by `pb_startPage` property


- Use for static Image

  Conforms protocol `PBViewControllerDataSource` and implement `viewController:imageForPageAtIndex:` selector

- Use for web image

   Conforms protocol `PBViewControllerDataSource` and implement `viewController:presentImageView:forPageAtIndex:progressHandler` selector

-   Support animation

     Conforms protocol `PBViewControllerDataSource` and implement `thumbViewForPageAtIndex:` tell the start and ended imageView position

-   Conforms protocol `PBViewControllerDataSource` and implement `viewController:didSingleTapedPageAtIndex:presentedImage:` or `viewController:didLongPressedPageAtIndex:presentedImage:` handle single tap or long press action



## Demo

``` objective-c
...
PBViewController *pbViewController = [PBViewController new];
pbViewController.pb_dataSource = self;
pbViewController.pb_delegate = self;
pbViewController.pb_startPage = sender.tag;
[self presentViewController:pbViewController animated:YES completion:nil];
...

...
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

```

For more information checkout the Example in project.

## License

`PhotoBrowser` is available under the MIT license. See the LICENSE file for more info.

## Contact

Follow me on Twitter ([@mochxiao](https://twitter.com/mochxiao))
