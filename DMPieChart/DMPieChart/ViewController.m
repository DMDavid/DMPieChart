//
//  ViewController.m
//  DMPieChart
//
//  Created by David on 16/5/22.
//  Copyright © 2016年 OrangeCat. All rights reserved.
//

#import "ViewController.h"
#import "DMPieChartView.h"

@interface ViewController () <DMPieChartViewDelegate>

@end

@implementation ViewController {
    DMPieChartView *view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    CGRect rect = CGRectMake(100, 100, 250, 250);
    DMPieChartModel *model1 = [[DMPieChartModel alloc] initWithName:@"" value:@(20) color:[UIColor redColor] totalValue:@(100)];
    DMPieChartModel *model2 = [[DMPieChartModel alloc] initWithName:@"" value:@(20) color:[UIColor blueColor] totalValue:@(100)];
    DMPieChartModel *model3 = [[DMPieChartModel alloc] initWithName:@"" value:@(20) color:[UIColor blackColor] totalValue:@(100)];
    DMPieChartModel *model4 = [[DMPieChartModel alloc] initWithName:@"" value:@(20) color:[UIColor orangeColor] totalValue:@(100)];
    DMPieChartModel *model5 = [[DMPieChartModel alloc] initWithName:@"" value:@(20) color:[UIColor brownColor] totalValue:@(100)];
    view = [[DMPieChartView alloc] initWithFrame:rect pieChartModels:@[model1, model2, model3, model4, model5]];
    
    view.delegate = self;
    [view setCenterTipLabelWithValue:3200.0];
    [self.view addSubview:view];
}

#pragma delegate 
- (void)pieView:(DMPieChartView *)pieView didSelectSectionAtIndex:(NSInteger)index {
    NSLog(@"index ----- %ld", index);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [view reloadData];
}

@end
