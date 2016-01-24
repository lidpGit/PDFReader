//
//  PDFPageView.h
//  PDFReader
//
//  Created by lidp on 16/1/24.
//  Copyright © 2016年 lidp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDFPageView : UIView

/**
 *  初始化
 *
 *  @param fileUrl PDF文件路径
 *  @param page    加载第几页PDF
 *
 *  @return
 */
- (instancetype)initWithFileUrl:(NSString *)fileUrl page:(NSInteger)page;

@end
