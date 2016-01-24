//
//  PDFContentView.h
//  PDFReader
//
//  Created by lidp on 16/1/24.
//  Copyright © 2016年 lidp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDFContentView : UIScrollView<UIScrollViewDelegate>

/**
 *  初始化
 *
 *  @param frame   frame
 *  @param fileUrl 文件路径
 *  @param page    加载第几页PDF
 *
 *  @return 
 */
- (instancetype)initWithFrame:(CGRect)frame fileUrl:(NSString *)fileUrl page:(NSInteger)page;

/**
 *  缩放到最小比例
 */
- (void)zoomToMinimumScale;

@end
