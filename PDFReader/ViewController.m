//
//  ViewController.m
//  PDFReader
//
//  Created by lidp on 16/1/24.
//  Copyright © 2016年 lidp. All rights reserved.
//

#import "ViewController.h"
#import "PDFReaderViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    UIButton *showBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showBtn.frame = CGRectMake(0, 0, 100, 50);
    showBtn.center = self.view.center;
    [showBtn setTitle:@"show" forState:UIControlStateNormal];
    [showBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [showBtn addTarget:self action:@selector(onClickShow) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showBtn];
}

- (void)onClickShow{
    [self.navigationController pushViewController:[[PDFReaderViewController alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
