//
//  PDFDocumentHandler.m
//  PDFReader
//
//  Created by lidp on 16/1/24.
//  Copyright © 2016年 lidp. All rights reserved.
//

#import "PDFDocumentHandler.h"

#pragma mark - --------------------- 创建PDF
CGPDFDocumentRef CGPDFDocumentCreateWithPath(NSString *filePath) {
    CGPDFDocumentRef pdfDocumentRef = NULL;
    NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
    CFURLRef pdfURL = (__bridge CFURLRef)(fileUrl);
    if (pdfURL != NULL) {
        pdfDocumentRef = CGPDFDocumentCreateWithURL(pdfURL);
    }
    return pdfDocumentRef;
}

#pragma mark - --------------------- 获取PDF总页数
NSInteger CGPDFDocumentGetPageCount(CGPDFDocumentRef pdfDocumentRef) {
    NSInteger pageCount = 0;
    if (pdfDocumentRef != NULL) {
        pageCount = CGPDFDocumentGetNumberOfPages(pdfDocumentRef);
    }
    return pageCount;
}

#pragma mark - --------------------- 获取某页PDF页面尺寸
CGSize CGPDFPageRefGetPageSize(CGPDFPageRef pdfPageRef) {
    CGSize pageSize = CGSizeZero;
    if (pdfPageRef != NULL) {
        //获取PDF有效rect
        CGRect cropBoxRect = CGPDFPageGetBoxRect(pdfPageRef, kCGPDFCropBox);
        CGRect mediaBoxRect = CGPDFPageGetBoxRect(pdfPageRef, kCGPDFMediaBox);
        CGRect effectiveRect = CGRectIntersection(cropBoxRect, mediaBoxRect);
        
        //获取某页PDF旋转角度，判断旋转角度获取显示的宽高
        int angle = CGPDFPageGetRotationAngle(pdfPageRef);
        
        NSInteger pageWidth = 0;
        NSInteger pageHeight = 0;
        switch (angle){
            case 0:
            case 180:
            {
                pageWidth = effectiveRect.size.width;
                pageHeight = effectiveRect.size.height;
                break;
            }
                
            case 90:
            case 270:
            {
                pageWidth = effectiveRect.size.height;
                pageHeight = effectiveRect.size.width;
                break;
            }
                
            default:
                break;
        }
        
        //宽和高不为偶数，减1
        if (pageWidth % 2) {
            pageWidth --;
        }
        if (pageHeight % 2) {
            pageHeight --;
        }
        pageSize = CGSizeMake(pageWidth, pageHeight);
    }
    return pageSize;
}

@implementation PDFDocumentHandler

#pragma mark - --------------------- 生成某页PDF图片
+ (void)createPDFPageImage:(NSString *)filePath page:(NSInteger)page callback:(void (^)(UIImage *))block{
    //异步绘制图片，否则会阻塞UI
    dispatch_queue_t createImageQueue = dispatch_queue_create("create_PDFPage_image", NULL);
    dispatch_async(createImageQueue, ^{
        CGPDFDocumentRef PDFDocRef = CGPDFDocumentCreateWithPath(filePath);
        CGImageRef imageRef = NULL;
        if (PDFDocRef != NULL) {
            CGPDFPageRef PDFPageRef = CGPDFDocumentGetPage(PDFDocRef, page);
            
            //获取PDF页面尺寸
            CGSize pageSize = CGPDFPageRefGetPageSize(PDFPageRef);
            
            //开始绘制图片
            CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
            CGBitmapInfo bmi = (kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);
            CGContextRef context = CGBitmapContextCreate(NULL, pageSize.width, pageSize.height, 8, 0, rgb, bmi);
            if (context != NULL) {
                CGRect thumbRect = CGRectMake(0.0f, 0.0f, pageSize.width, pageSize.height);
                
                CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
                CGContextFillRect(context, thumbRect);
                CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(PDFPageRef, kCGPDFCropBox, thumbRect, 0, true));
                CGContextDrawPDFPage(context, PDFPageRef);
                imageRef = CGBitmapContextCreateImage(context);
                CGContextRelease(context);
            }
            CGColorSpaceRelease(rgb);
            if (PDFDocRef != NULL) {
                CGPDFDocumentRelease(PDFDocRef);
            }
            
            if (imageRef != NULL) {
                UIImage *image = [UIImage imageWithCGImage:imageRef];
                if (block) {
                    block(image);
                }
                CGImageRelease(imageRef);
            }
        }
    });
}

@end


