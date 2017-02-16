//
//  NewsViewController.m
//  07-网易新闻界面搭建(父子控制器)
//
//  Created by 连俊杨 on 17/2/7.
//  Copyright © 2017年 yang_ljun. All rights reserved.
//

#import "NewsViewController.h"

#import "TopLineViewController.h"
#import "HotViewController.h"
#import "SocietyViewController.h"
#import "VideoViewController.h"
#import "ReaderViewController.h"
#import "ScienceViewController.h"

static CGFloat const labelW = 100;
static CGFloat const radio = 1.3;
#define LJScreenW [UIScreen mainScreen].bounds.size.width


@interface NewsViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *titleScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;

@property (nonatomic, weak) UILabel *isSelLabel;

// 标题数组
@property (nonatomic, strong) NSMutableArray *titleLabels;

@end

@implementation NewsViewController

-(NSMutableArray *)titleLabels {
    if (_titleLabels == nil) {
        _titleLabels = [NSMutableArray array];
    }
    return _titleLabels;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupChildViewControllers];
    
    [self setupTitleLabel];
    
    [self setupScrollerView];
}

- (void)setupScrollerView {
    
    // iOS7 之后，系统默认会给导航控制器下的scrollview添加顶部滚动区域 高度64
    // 取消
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.titleScrollView.contentSize = CGSizeMake(self.childViewControllers.count * labelW, 0);
    
    self.titleScrollView.showsHorizontalScrollIndicator = NO;
    self.titleScrollView.showsVerticalScrollIndicator = NO;
    
    
    // 内容scrollview
    self.contentScrollView.contentSize = CGSizeMake(self.childViewControllers.count * LJScreenW, 0);
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentScrollView.pagingEnabled = YES;
    self.contentScrollView.bounces = NO;
    
    // 设置代理
    self.contentScrollView.delegate = self;
}


/**
    设置标题
 */
- (void)setupTitleLabel {
    
    NSUInteger count = self.childViewControllers.count;
    
    CGFloat labelX = 0;
    CGFloat labelY = 0;
    CGFloat labelH = 44;
    
    for (int i = 0; i < count; i++) {
        
        UIViewController *vc = self.childViewControllers[i];
        
        labelX = labelW * i;
        
        UILabel *label = [[UILabel alloc] init];
        label.textAlignment = NSTextAlignmentCenter;
        label.frame = CGRectMake(labelX, labelY, labelW, labelH);
        
        label.text = vc.title;
        
        // 设置label的选中字体颜色
        label.highlightedTextColor = [UIColor redColor];
        
        label.tag = i;
        
        // 添加点按手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showVc:)];
        label.userInteractionEnabled = YES;
        [label addGestureRecognizer:tap];
        
        // 默认选中第0个label
        if (i == 0) {
            [self showVc:tap];
        }
        
        // 添加到数组
        [self.titleLabels addObject:label];
        
        [self.titleScrollView addSubview:label];
    }
    
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    // CGFloat小数点，当前的页数
    CGFloat curPage = scrollView.contentOffset.x / scrollView.bounds.size.width;
    
    // 左边label的下标(整数)
    NSInteger leftIndex = curPage;
    
    // 右边label的下标
    NSInteger rightIndex = leftIndex + 1;
    
    // 左右label
    UILabel *leftLabel = self.titleLabels[leftIndex];
    
    // 注意数组越界
    UILabel *rightLabel;
    if (rightIndex < self.titleLabels.count) {
        rightLabel = self.titleLabels[rightIndex];
    }
    
    // 形变
    CGFloat rightScale = curPage - leftIndex;//比原先放大
    CGFloat leftScale = 1 - rightScale; // 比原先缩小
    
    NSLog(@"%f - %f",leftScale,rightScale);
    // 从原始大小开始形变，所以加1
    leftLabel.transform = CGAffineTransformMakeScale(leftScale*0.3 + 1, leftScale*0.3 + 1);
    rightLabel.transform = CGAffineTransformMakeScale(rightScale*0.3 + 1, rightScale*0.3 + 1);
    
    // title颜色渐变
    //      R G B
    // 黑色 0 0 0
    // 红色 1 0 0
    leftLabel.textColor = [UIColor colorWithRed:leftScale
                                          green:0
                                           blue:0
                                          alpha:1];
    rightLabel.textColor = [UIColor colorWithRed:rightScale
                                          green:0
                                           blue:0
                                          alpha:1];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 滑动结束调用
    
    NSInteger index = scrollView.contentOffset.x / scrollView.bounds.size.width;
    
    // 1 添加控制器
    [self showDetailView:index];
    
    // 2 变换字体状态
    UILabel *selLabel = self.titleLabels[index];
    [self isSelectedLabel:selLabel];
    
    // 3 标题居中
    [self setTitleLabelCenter:selLabel];
}



/**
    展现控制器
 */
- (void)showVc:(UITapGestureRecognizer *)ges {
    
    // 1.字体颜色变为红色
    UILabel *selLabel = (UILabel *)ges.view;
    
    [self isSelectedLabel:selLabel];
    
    NSInteger index = selLabel.tag;
    // 2.滚动到对应的位置
    CGFloat offsetX = index * LJScreenW;
    self.contentScrollView.contentOffset = CGPointMake(offsetX, 0);
    
    // 3.给对应的位置添加控制器
    [self showDetailView:index];
    
    // 4.标题居中
    [self setTitleLabelCenter:selLabel];
    
}


/**
    给scrollview添加控制器

    index: 下标
 */
- (void)showDetailView:(NSInteger)index {
    CGFloat offsetX = index * LJScreenW;
    // 给对应的位置添加控制器
    UIViewController *vc = self.childViewControllers[index];
    
    // 避免重复添加view
    // isViewLoaded：控制器的view有没有被添加
    if (vc.isViewLoaded) {
        return;
    }
    
    vc.view.frame = CGRectMake(offsetX,
                               0,
                               self.contentScrollView.bounds.size.width,
                               self.contentScrollView.bounds.size.height);
    
    [self.contentScrollView addSubview:vc.view];
}



// 让标题居中
- (void)setTitleLabelCenter:(UILabel *)centerLabel {
    
    // 计算偏移量
    CGFloat offsetX = centerLabel.center.x - LJScreenW * 0.5;
    
    CGFloat maxOffsetX = self.titleScrollView.contentSize.width - LJScreenW;
    if (offsetX < 0) {
        offsetX = 0;
    } else if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    
    [self.titleScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

// 改变标题的字体颜色
- (void)isSelectedLabel:(UILabel *)label {
    // 记录状态（三部曲）
    _isSelLabel.highlighted = NO;
    _isSelLabel.transform = CGAffineTransformIdentity;
    _isSelLabel.textColor = [UIColor blackColor];
    
    label.highlighted = YES;
    label.transform = CGAffineTransformMakeScale(radio, radio);
    
    _isSelLabel = label;
}


/**
    设置子控制器
 */
- (void)setupChildViewControllers {
    
    TopLineViewController *topLine = [[TopLineViewController alloc] init];
    topLine.title = @"头条";
    [self addChildViewController:topLine];
    
    HotViewController *hot = [[HotViewController alloc] init];
    hot.title = @"热点";
    [self addChildViewController:hot];
   
    SocietyViewController *society = [[SocietyViewController alloc] init];
    society.title = @"社会";
    [self addChildViewController:society];
    
    VideoViewController *video = [[VideoViewController alloc] init];
    video.title = @"视频";
    [self addChildViewController:video];
    
    ReaderViewController *reader = [[ReaderViewController alloc] init];
    reader.title = @"阅读";
    [self addChildViewController:reader];
    
    ScienceViewController *science = [[ScienceViewController alloc] init];
    science.title = @"科技";
    [self addChildViewController:science];

}


@end
