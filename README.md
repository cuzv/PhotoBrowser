# PhotoBrowser

PhotoBrowser is a light weight photo browser, like the wechat, weibo image viewer.



### TODO

-   [x] Present & Dismissal animation

- [ ] GIF support



## How does it look like?

<p align="left">

	<img src="./Preview/demo.gif" width=44%">

</p>



## How to use

- Like the `UITableView` API, We have `DataSource` an `Delegate` for load data and handle action


- Tell `PhotoBrowser` how many pages would you like to present by conforms protocol `PBViewControllerDataSource` and implement `numberOfPagesInViewController:` selector


- Optional set the initialize page by invoke `setInitializePageIndex:` method


- Use for static Image

  	Conforms protocol `PBViewControllerDataSource` and implement `viewController:imageForPageAtIndex:` selector

- Use for web image

   Conforms protocol `PBViewControllerDataSource` and implement `viewController:presentImageView:forPageAtIndex:` selector

- Handle action

   Conforms protocol `PBViewControllerDataSource` and implement `viewController:didSingleTapedPageAtIndex:presentedImage:` or `viewController:didLongPressedPageAtIndex:presentedImage:` handle single tap or long press action



## Demo



``` objective-c
...
PBViewController *pbViewController = [PBViewController new];
pbViewController.pb_dataSource = self;
pbViewController.pb_delegate = self;
[pbViewController setInitializePageIndex:2];
[self presentViewController:pbViewController animated:YES completion:nil];
...

...
#pragma mark - PBViewControllerDataSource

- (NSInteger)numberOfPagesInViewController:(PBViewController *)viewController {
    return self.urls.count;
}

- (void)viewController:(PBViewController *)viewController presentImageView:(UIImageView *)imageView forPageAtIndex:(NSInteger)index {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *path = self.urls[index];
        NSData *data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:path] options:0 error:nil];
        UIImage *image = [[UIImage alloc] initWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
        });
    });
}
...

...
#pragma mark - PBViewControllerDelegate

- (void)viewController:(PBViewController *)viewController didSingleTapedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage {
    NSLog(@"didSingleTapedPageAtIndex: %@", @(index));
    [viewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewController:(PBViewController *)viewController didLongPressedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage {
    NSLog(@"didLongPressedPageAtIndex: %@", @(index));
}
```

For more information checkout the Sample in project



## License

`PhotoBrowser` is available under the MIT license. See the LICENSE file for more info.



## Contact

Follow me on Twitter ([@mochxiao](https://twitter.com/mochxiao))
