# PhotoBrowser

PhotoBrowser is a light weight photo browser, like the wechat, weibo image viewer.



### 0.3

-   修复 issue #3 
-   废弃 `setInitializePageIndex:` ，改为 `pb_startPage`。
-   废弃 `PBViewControllerDataSource` 中的 `viewController:presentImageView:forPageAtIndex:`方法，改为 `viewController:presentImageView:forPageAtIndex:progressHandler`。
-   移除`PBViewControllerDelegate` 中的 `viewController:didSingleTapedPageAtIndex:presentedImage` 方法。