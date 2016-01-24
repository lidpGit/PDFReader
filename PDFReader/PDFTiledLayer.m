//
//  PDFTiledLayer.m
//  PDFReader
//
//  Created by lidp on 16/1/24.
//  Copyright © 2016年 lidp. All rights reserved.
//

#import "PDFTiledLayer.h"

@implementation PDFTiledLayer

//重新设置绘制时间
+ (CFTimeInterval)fadeDuration{
    return 0.0;
}

- (instancetype)init{
    if (self = [super init]) {
        //防止放大模糊
        self.levelsOfDetail = 1;
        self.levelsOfDetailBias = 1;
        self.tileSize = CGSizeMake(1024, 1024);
    }
    return self;
}

@end
