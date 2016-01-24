//
//  PDFReaderViewController.m
//  PDFReader
//
//  Created by lidp on 16/1/24.
//  Copyright © 2016年 lidp. All rights reserved.
//

#import "PDFReaderViewController.h"
#import "PDFContentView.h"
#import "PDFDocumentHandler.h"

@interface PDFReaderViewController () <UIScrollViewDelegate>

@end

@implementation PDFReaderViewController{
    NSString            *_filePath;     /**< PDF文件路径 */
    NSMutableDictionary *_contentViews; /**< 保存PDFContentView，key为对应的页码数 */
    UIScrollView        *_scrollView;
    NSInteger           _pageCount;     /**< PDF总页数 */
    NSInteger           _currentPage;   /**< 当前显示的PDF页码 */
    CGFloat             _outset;        /**< PDF每页之间的间距 */
}

#pragma mark - ---------------------- 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _filePath = [[NSBundle mainBundle] pathForResource:@"Swift开发指南（修订版）.pdf" ofType:nil];
    _pageCount = [self pdfPageCount];
    
    _outset = 4.0f;
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, [UIScreen mainScreen].bounds.size.height - 64);
    CGRect scrollViewRect = CGRectInset(frame, - _outset, 0.0f);
    
    _scrollView = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    [self.view addSubview:_scrollView];
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width * _pageCount, 0)];
    
    _contentViews = [NSMutableDictionary dictionary];
    if (_pageCount > 0) {
        _currentPage = 1;
        self.navigationItem.title = [NSString stringWithFormat:@"%li/%li", _currentPage, _pageCount];
        [_scrollView addSubview:[self contentViewAtPage:_currentPage]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - ---------------------- Getter
//获取PDF总页数
- (NSInteger)pdfPageCount{
    NSInteger pageCount = 0;
    CGPDFDocumentRef thePDFDocRef = CGPDFDocumentCreateWithPath(_filePath);
    if (thePDFDocRef != NULL) {
        pageCount = CGPDFDocumentGetPageCount(thePDFDocRef);
        CGPDFDocumentRelease(thePDFDocRef);
    }
    return pageCount;
}

//获取contentView的frame
- (CGRect)frameAtPage:(NSInteger)page{
    CGRect viewRect = CGRectZero;
    viewRect.size = _scrollView.bounds.size;
    viewRect.origin.x = (viewRect.size.width * (page - 1));
    viewRect = CGRectInset(viewRect, _outset, 0.0f);
    return viewRect;
}

//获取contentView
- (PDFContentView *)contentViewAtPage:(NSInteger)page{
    CGRect frame = [self frameAtPage:page];
    PDFContentView *contentView = [[PDFContentView alloc] initWithFrame:frame fileUrl:_filePath page:page];
    [_contentViews setObject:contentView forKey:[NSNumber numberWithInteger:page]];
    return contentView;
}

#pragma mark - ---------------------- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self layoutScrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat viewWidth = scrollView.bounds.size.width;
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    
    //获取当前显示的第几页PDF
    NSInteger page = (contentOffsetX / viewWidth);
    page++;
    _currentPage = page;
    
    //如果contentView对应的page不是当前页码，全部缩放到最小比例
    [_contentViews enumerateKeysAndObjectsUsingBlock:
     ^(NSNumber *key, PDFContentView *contentView, BOOL *stop) {
         if ([key integerValue] != page) {
             [contentView zoomToMinimumScale];
         }
     }];
    
    self.navigationItem.title = [NSString stringWithFormat:@"%li/%li", _currentPage, _pageCount];
}

#pragma mark - ---------------------- PrivateMethods
- (void)layoutScrollView{
    CGFloat viewWidth = _scrollView.bounds.size.width;
    CGFloat contentOffsetX = _scrollView.contentOffset.x;
    
    //获取当前页的页码
    NSInteger fromPage = (contentOffsetX / viewWidth);
    
    //获取当前页+2的页码
    NSInteger toPgae = ((contentOffsetX + viewWidth - 1.0f) / viewWidth);
    toPgae += 2;
    
    //设置加载PDF页数范围
    if (fromPage < 1) {
        fromPage = 1;
    }
    if (toPgae > _pageCount) {
        toPgae = _pageCount;
    }
    
    NSRange pageRange = NSMakeRange(fromPage, (toPgae - fromPage + 1));
    NSMutableIndexSet *pageSet = [NSMutableIndexSet indexSetWithIndexesInRange:pageRange];
    
    for (NSNumber *key in [_contentViews allKeys]) {
        NSInteger page = [key integerValue];
        if ([pageSet containsIndex:page] == NO) {
            //当pageSet不包含字典里存的contentView对应的page时，移除conentView，管理内存
            PDFContentView *contentView = [_contentViews objectForKey:key];
            if (contentView) {
                [contentView removeFromSuperview];
                [_contentViews removeObjectForKey:key];
            }
        } else {
            //如果包含，pageSet移除对应的page，否则会重新创建一个conentView
            [pageSet removeIndex:page];
        }
    }
    
    if (pageSet.count > 0) {
        [pageSet enumerateIndexesWithOptions:NSEnumerationReverse usingBlock:
         ^(NSUInteger page, BOOL *stop) {
             [_scrollView addSubview:[self contentViewAtPage:page]];
         }];
    }
}

@end
