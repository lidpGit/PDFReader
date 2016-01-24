//
//  PDFPageView.m
//  PDFReader
//
//  Created by lidp on 16/1/24.
//  Copyright © 2016年 lidp. All rights reserved.
//

#import "PDFPageView.h"
#import "PDFTiledLayer.h"
#import "PDFDocumentHandler.h"

@implementation PDFPageView{
    CGPDFDocumentRef        _PDFDocRef;
    CGPDFPageRef            _PDFPageRef;
}

+ (Class)layerClass{
    return [PDFTiledLayer class];
}

- (instancetype)initWithFileUrl:(NSString *)fileUrl page:(NSInteger)page{
    _PDFDocRef = CGPDFDocumentCreateWithPath(fileUrl);
    CGSize viewSize = CGSizeZero;
    if (_PDFDocRef != NULL) {
        //获取某页PDF
        _PDFPageRef = CGPDFDocumentGetPage(_PDFDocRef, page);
        if (_PDFPageRef) {
            //retain，避免释放时崩溃
            CGPDFPageRetain(_PDFPageRef);
            viewSize = CGPDFPageRefGetPageSize(_PDFPageRef);
        }
    }
    
    PDFPageView *pageView = [self initWithFrame:CGRectMake(0, 0, viewSize.width, viewSize.height)];
    return pageView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc{
    if (_PDFPageRef != NULL) {
        CGPDFPageRelease(_PDFPageRef);
        _PDFPageRef = NULL;
    }
    
    if (_PDFDocRef != NULL) {
        CGPDFDocumentRelease(_PDFDocRef);
        _PDFDocRef = NULL;
    }
}

- (void)drawLayer:(CATiledLayer *)layer inContext:(CGContextRef)context{
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextFillRect(context, CGContextGetClipBoundingBox(context));
    CGContextTranslateCTM(context, 0.0f, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextConcatCTM(context, CGPDFPageGetDrawingTransform(_PDFPageRef, kCGPDFCropBox, self.bounds, 0, true));
    CGContextDrawPDFPage(context, _PDFPageRef);
}

@end
