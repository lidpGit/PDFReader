//
//  PDFDocumentHandler.h
//  PDFReader
//
//  Created by lidp on 16/1/24.
//  Copyright © 2016年 lidp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

/**
 *  创建CGPDFDocumentRef
 *
 *  @param filePath PDF文件路径
 *
 *  @return
 */
CGPDFDocumentRef CGPDFDocumentCreateWithPath(NSString *filePath);

/**
 *  获取PDF总页数
 *
 *  @param pdfDocumentRef
 *
 *  @return 
 */
NSInteger CGPDFDocumentGetPageCount(CGPDFDocumentRef pdfDocumentRef);

/**
 *  获取某页PDF尺寸
 *
 *  @param pdfPageRef
 *
 *  @return
 */
CGSize CGPDFPageRefGetPageSize(CGPDFPageRef pdfPageRef);

@interface PDFDocumentHandler : NSObject

#pragma mark - --------------------- 生成某页PDF图片
+ (void)createPDFPageImage:(NSString *)filePath page:(NSInteger)page callback:(void (^)(UIImage *image))block;

@end


