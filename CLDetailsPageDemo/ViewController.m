//
//  ViewController.m
//  CLDetailsPageDemo
//
//  Created by CL on 2019/5/29.
//  Copyright © 2019 CL. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h> // 苹果推荐使用WKWebView代替UIWebView

#define ScreenWidth 		[UIScreen mainScreen].bounds.size.width
#define ScreenHeight 		[UIScreen mainScreen].bounds.size.height

#define IS_IPHONE_X         [ViewController isiPhoneXSeries]

#define SAVE_ARE_TOP        (IS_IPHONE_X ? 24.0f : 0.0f)
#define SAVE_ARE_BOTTOM     (IS_IPHONE_X ? 34.0f : 0.0f)

#define kMaxMoveOffSet 		50.0f
#define kHeightOfTips		40.0f


@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

/**
 这样命名是为了更好了解属性的作用，不然我就直接用tableView\webView
 */

/** 信息使用TableView展示，可以展示轮播图，标题、描述，价格属性列表等 */
@property (nonatomic, strong) UITableView *infoTableView;

/** 更多详情使用WebView展示，使用H5效果会比较省操作，也可以用UIScrollView的子类，一定要可以滚动的 */
@property (nonatomic, strong) WKWebView *detailsWebView;

/** 拖动提示，可以自定义UIView，上拉…… */
@property (nonatomic, strong) UILabel *tipsUpLabel;

/** 拖动提示，可以自定义UIView，下拉…… */
@property (nonatomic, strong) UILabel *tipsDownLabel;

/** TableView和WebView的高度 */
@property (nonatomic, assign) CGFloat contentHeight;

@end

@implementation ViewController

#pragma mark - Lazy
#pragma mark 信息展示
- (UITableView *)infoTableView {
	if (!_infoTableView) {
		_infoTableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
		_infoTableView.delegate = self;
		_infoTableView.dataSource = self;
		_infoTableView.rowHeight = 44.0;
		
		// 内边距，底部放拖动提示UI
		_infoTableView.contentInset = UIEdgeInsetsMake(0, 0, kHeightOfTips, 0);
		
		// iOS11，内边距调整
		if (@available(iOS 11.0, *)) {
			_infoTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
		} else {
		}
		
		/// 这个是不必要的，举个例子如轮播图在这里
		UIView *tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
		tableHeaderView.backgroundColor = UIColor.redColor;
		_infoTableView.tableHeaderView = tableHeaderView;
		_infoTableView.tableFooterView = [UIView new];
	}
	return _infoTableView;
}

#pragma mark 更多详情内容展示
- (WKWebView *)detailsWebView {
	if (!_detailsWebView) {
		_detailsWebView = [[WKWebView alloc] init];
		_detailsWebView.backgroundColor = UIColor.groupTableViewBackgroundColor;
		_detailsWebView.opaque = NO;
		_detailsWebView.scrollView.delegate = self;
		
		/// 这个是不必要的，举个例子如商品详情（百度首页https）在这里
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com/"]];
		[_detailsWebView loadRequest:request];
	}
	return _detailsWebView;
}

#pragma mark 上拉拖动提示
- (UILabel *)tipsUpLabel {
	if (!_tipsUpLabel) {
		_tipsUpLabel = [[UILabel alloc] init];
		_tipsUpLabel.textAlignment = NSTextAlignmentCenter;
		_tipsUpLabel.font = [UIFont systemFontOfSize:15];
		_tipsUpLabel.textColor = [UIColor blueColor];
	}
	return _tipsUpLabel;
}

#pragma mark 下拉拖动提示
- (UILabel *)tipsDownLabel {
	if (!_tipsDownLabel) {
		_tipsDownLabel = [[UILabel alloc] init];
		_tipsDownLabel.textAlignment = NSTextAlignmentCenter;
		_tipsDownLabel.font = [UIFont systemFontOfSize:15];
		_tipsDownLabel.textColor = [UIColor grayColor];
	}
	return _tipsDownLabel;
}

#pragma mark - Class
- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.title = @"详情";
	// 去掉导航栏、底部控件栏、上下安全区域
	self.contentHeight = ScreenHeight-49-64-SAVE_ARE_TOP-SAVE_ARE_BOTTOM;
	NSLog(@"%f %f", ScreenHeight, self.view.frame.size.height);
	
	/// 加载UI
	self.infoTableView.frame = CGRectMake(0, 0, ScreenWidth, self.contentHeight);
	self.detailsWebView.frame = CGRectMake(0, self.contentHeight, ScreenWidth, self.contentHeight);
	[self.view addSubview:self.infoTableView];
	[self.view sendSubviewToBack:self.infoTableView];
	[self.view addSubview:self.detailsWebView];
	[self.view sendSubviewToBack:self.detailsWebView];
	
	
	/// 附加提示UI
	self.tipsUpLabel.frame = CGRectMake(-ScreenWidth, 0, ScreenWidth, kHeightOfTips);
	[_infoTableView addSubview:self.tipsUpLabel];
	/// 附加提示UI
	self.tipsDownLabel.frame = CGRectMake(0, -kHeightOfTips, ScreenWidth, kHeightOfTips);
	[self.detailsWebView.scrollView addSubview:self.tipsDownLabel];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// 导航栏不透明
	self.navigationController.navigationBar.hidden = NO;
	self.navigationController.navigationBar.translucent = NO;
	self.navigationController.navigationBar.shadowImage = nil;
}


#pragma mark - UITableView
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	NSLog(@"点击了：%zd", indexPath.row);
}

#pragma mark UITableViewDataSource
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
	NSString *identifier= @"UITableViewCell";
	UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
	cell.textLabel.text = [NSString stringWithFormat:@"中文，第几行：%zd", indexPath.row];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 18;
}


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
			// 进入详情页面
			[self gotoDetailsPageAnimation];
		}
	}
	/// 如果滚动的是webView,页面的滚动
	else if ([scrollView isEqual:self.detailsWebView.scrollView]) {
		/// webView往下偏移超过
		CGFloat offsetY = scrollView.contentOffset.y;
		if (offsetY < 0 && -offsetY > kMaxMoveOffSet) {
			// 返回列表界面
			[self gotoInfoPageAnimation];
		}
	}
}

#pragma mark - 跳转动画
#pragma mark 进入详情页面
- (void)gotoDetailsPageAnimation {
	[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
		self.detailsWebView.frame = CGRectMake(0, 0, ScreenWidth, self.contentHeight);
		self.infoTableView.frame = CGRectMake(0, -self.contentHeight, ScreenWidth, self.contentHeight);
	} completion:^(BOOL finished) {
		
	}];
}

#pragma mark 返回列表界面
- (void)gotoInfoPageAnimation {
	[UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionLayoutSubviews animations:^{
		self.infoTableView.frame = CGRectMake(0, 0, ScreenWidth, self.contentHeight);
		self.detailsWebView.frame = CGRectMake(0, self.contentHeight, ScreenWidth, self.contentHeight);
	} completion:^(BOOL finished) {
		
	}];
}

#pragma mark - getter
+ (BOOL)isiPhoneXSeries {
	if (@available(iOS 11.0, *)) {
		UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
		if (window.safeAreaInsets.bottom > 0.0) {
			return YES;
		}
	}
	return NO;
}

@end
