# PhotoBrowser

PhotoBrowser is a light weight photo browser, like the wechat, weibo image viewer.



### 0.3.1

-   修复 issue [#3 ](https://github.com/cuzv/PhotoBrowser/issues/3)
-   废弃 `setInitializePageIndex:` ，改为 `pb_startPage`。
-   废弃 `PBViewControllerDataSource` 中的 `viewController:presentImageView:forPageAtIndex:`方法，改为 `viewController:presentImageView:forPageAtIndex:progressHandler`。
-   去除 `PBViewControllerDelegate` 中的 `viewController:didSingleTapedPageAtIndex:presentedImage` 退出事件。交由实现者来决定。（例如 Twitter 单击并不退出，而是切换显示工具栏。）


### 0.3.2

-   修复 thumb 图片为加载的情况下动画问题。
-   修复状态栏显示可能不复原的问题。



### 0.4

- 添加`reload`, `reloadWithCurrentPage:`方法，`numberOfPages`, `currentPage` 属性。

### 0.5

- 增加图片显示模式兼容，长图显示头部的时候 dismiss 动画图片会还原到 thumb 显示的位置。
- 修复 present 的时候画面拉升。
- 切换图片的时候隐藏对应的 thumb view。
- 优化内部实现逻辑（0.5.9）。


### 0.6

- 调节背景亮度。

### 0.6.1

- 修复 dismiss 后滑动界面奔溃的问题。

### 0.6.2

- 支持部不隐藏 thumb view 选项。

### 0.6.3

- 添加自定义退出操作

### 0.6.4

- Fix Issues #10


### 0.6.5

- Close Issues #4 & #12

### 0.7.0

- iOS 11 compatibility