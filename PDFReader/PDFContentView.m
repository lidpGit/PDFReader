//
//  PDFContentView.m
//  PDFReader
//
//  Created by lidp on 16/1/24.
//  Copyright © 2016年 lidp. All rights reserved.
//

#import "PDFContentView.h"
#import "PDFPageView.h"
#import "PDFDocumentHandler.h"

@implementation PDFContentView{
    UIView          *_contentView;
}

- (instancetype)initWithFrame:(CGRect)frame fileUrl:(NSString *)fileUrl page:(NSInteger)page{
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.backgroundColor = [UIColor clearColor];
        
        //添加双击手势
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapScrollView:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapGesture];
        
        PDFPageView *pageView = [[PDFPageView alloc] initWithFileUrl:fileUrl page:page];
        
        _contentView = [[UIView alloc] initWithFrame:pageView.bounds];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.userInteractionEnabled = NO;
        [self addSubview:_contentView];
        
        //获取当前PDF页面截图，放在pageView之前，避免出现渲染PDF时一块一块显示
        UIImageView *placeholderImageView = [[UIImageView alloc] initWithFrame:pageView.bounds];
        placeholderImageView.contentMode = UIViewContentModeScaleAspectFit;
        [PDFDocumentHandler createPDFPageImage:fileUrl page:page callback:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                placeholderImageView.image = image;
            });
        }];
        [_contentView addSubview:placeholderImageView];
        [_contentView addSubview:pageView];
        
        self.contentSize = pageView.bounds.size;
        [self setPageViewCenter];
        [self setMinAndMaxZoom];
        
        //默认为最小缩放比例
        self.zoomScale = self.minimumZoomScale;
    }
    return self;
}

- (void)setPageViewCenter{
    CGFloat iw = 0.0f;
    CGFloat ih = 0.0f;
    
    CGSize boundsSize = self.bounds.size;
    CGSize contentSize = self.contentSize;
    
    //PDF宽和高小于self的宽和高时，缩小两倍
    if (contentSize.width < boundsSize.width) {
        iw = (boundsSize.width - contentSize.width) * 0.5f;
    }
    if (contentSize.height < boundsSize.height) {
        ih = (boundsSize.height - contentSize.height) * 0.5f;
    }
    
    //设置偏移量
    UIEdgeInsets insets = UIEdgeInsetsMake(ih, iw, ih, iw);
    if (UIEdgeInsetsEqualToEdgeInsets(self.contentInset, insets) == NO) {
        self.contentInset = insets;
    }
}

- (void)setMinAndMaxZoom{
    //计算PDF页面大小和self的比例
    CGFloat w_scale = self.bounds.size.width / _contentView.bounds.size.width;
    CGFloat h_scale = self.bounds.size.height / _contentView.bounds.size.height;
    
    //如果宽的比例小于高的比例，获取宽的比例（宽和高取最较小的值）
    CGFloat minZoom = w_scale < h_scale ? w_scale : h_scale;
    
    //设置最大缩放比例和最小缩放比例
    self.minimumZoomScale = minZoom;
    self.maximumZoomScale = minZoom * 4;
}

- (void)zoomToMinimumScale{
    if (self.zoomScale > self.minimumZoomScale) {
        self.zoomScale = self.minimumZoomScale;
    }
}

#pragma mark - ---------------------- Gesture
- (void)doubleTapScrollView:(UITapGestureRecognizer *)sender{
    if (self.zoomScale != self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        //放大倍数
        CGFloat newZoomScale = (self.maximumZoomScale + self.minimumZoomScale) / 2.0f;
        CGFloat xsize = self.bounds.size.width / newZoomScale;
        CGFloat ysize = self.bounds.size.height / newZoomScale;
        
        //获取到双击的点
        CGFloat touchX = [sender locationInView:sender.view].x;
        CGFloat touchY = [sender locationInView:sender.view].y;
        
        //计算偏移量
        touchX *= 1 / self.zoomScale + self.contentOffset.x;
        touchY *= 1 / self.zoomScale + self.contentOffset.y;
        
        CGRect frame = CGRectMake(touchX - xsize/2, touchY - ysize/2, xsize, ysize);
        [self zoomToRect:frame animated:YES];
    }
}

#pragma mark - ---------------------- UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _contentView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (self.zoomScale > self.maximumZoomScale){
        [self setZoomScale:self.maximumZoomScale animated:YES];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    //设置pageView居中
    [self setPageViewCenter];
}

@end
