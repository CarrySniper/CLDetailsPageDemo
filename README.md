# CLDetailsPageDemo
仿淘宝商品详情页上拉、下拉显示另一页效果。

 ![](https://github.com/cjq002/CLDetailsPageDemo/raw/master/Media/demo.gif) 
 
#### 定义两个滚动视图控件
```
/** 信息使用TableView展示，可以展示轮播图，标题、描述，价格属性列表等 */
@property (nonatomic, strong) UITableView *infoTableView;

/** 更多详情使用WebView展示，使用H5效果会比较省操作，也可以用UIScrollView的子类，一定要可以滚动的 */
@property (nonatomic, strong) WKWebView *detailsWebView;
```
#### 监听滚动方法实现判断
```
#pragma mark - UIScrollViewDelegate
#pragma mark 实时滚动监听
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	/// 如果滚动的是tableView
	if ([scrollView isEqual:self.infoTableView]) {
		/// 滚动到底部为0.0，超出底部为负-，未到底部为正+
		CGFloat offsetY = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
		NSLog(@"%f", offsetY);
		self.tipsUpLabel.center = CGPointMake(ScreenWidth/2, scrollView.contentSize.height + kHeightOfTips/2);
		/// 已超过临界值，松手就到详情页
		if (offsetY < 0 && -offsetY > kMaxMoveOffSet) {
			self.tipsUpLabel.text = @"释放，进入详情";
		} else {
			self.tipsUpLabel.text = @"上拉，展示详情";
		}
	}
	/// 如果滚动的是webView,页面的滚动
	else if ([scrollView isEqual:self.detailsWebView.scrollView]) {
		CGFloat offsetY = scrollView.contentOffset.y;
		/// 已超过临界值，松手就返回上页
		if (offsetY < 0 && -offsetY > kMaxMoveOffSet) {
			self.tipsDownLabel.text = @"释放，返回列表";
		}else {
			self.tipsDownLabel.text = @"下拉，返回列表";
		}
	}
}

#pragma mark 滚动结束时，判断是否跳转
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	/// 如果滚动的是tableView
	if ([scrollView isEqual:self.infoTableView]) {
		/// 滚动到底部为0.0，超出底部为负-，未到底部为正+
		CGFloat offsetY = scrollView.contentSize.height - scrollView.frame.size.height - scrollView.contentOffset.y;
		/// 如果达到界限值再往上偏移
		if (offsetY < 0 && -offsetY > kMaxMoveOffSet) {
			[self gotoDetailAnimation];//进入图文详情页面
		}
	}
	/// 如果滚动的是webView,页面的滚动
	else if ([scrollView isEqual:self.detailsWebView.scrollView]) {
		/// webView往下偏移超过
		CGFloat offsetY = scrollView.contentOffset.y;
		if (offsetY < 0 && -offsetY > kMaxMoveOffSet) {
			[self gotoInfoPageAnimation];// 返回基本详情界面的动画
		}
	}
}

```
