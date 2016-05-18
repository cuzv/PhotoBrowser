# PhotoBrowser

PhotoBrowser is a light weight photo browser, like the wechat, weibo image viewer.



### 0.3

-   修复 issue [#3 ](https://github.com/cuzv/PhotoBrowser/issues/3)
-   废弃 `setInitializePageIndex:` ，改为 `pb_startPage`。
-   废弃 `PBViewControllerDataSource` 中的 `viewController:presentImageView:forPageAtIndex:`方法，改为 `viewController:presentImageView:forPageAtIndex:progressHandler`。
-   去除 `PBViewControllerDelegate` 中的 `viewController:didSingleTapedPageAtIndex:presentedImage` 退出事件。交由实现者来决定。（例如 Twitter 单击并不退出，而是切换显示工具栏。）

