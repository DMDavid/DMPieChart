//
//  DMPieChartView.h
//  DMPieChart
//
//  Created by David on 16/5/22.
//  Copyright © 2016年 OrangeCat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMPieChartModel.h"

@class DMPieChartView;

@protocol DMPieChartViewDelegate <NSObject>
- (void)pieView:(DMPieChartView *)pieView didSelectSectionAtIndex:(NSInteger)index;

@end

@interface DMPieChartView : UIView

@property (nonatomic, weak) id<DMPieChartViewDelegate> delegate;


#pragma mark - publice methods

/**
 *  init
 *
 *  @param frame          frame
 *  @param pieChartModels 数组，类型: @[DMPieChartModel]
 *
 *  @return 实体
 */
- (instancetype)initWithFrame:(CGRect)frame pieChartModels:(NSArray *)pieChartModels;

/**
 *  重置
 */
- (void)reloadData;


#pragma mark - Layer

/**
 *  设置背景图层颜色(default is green)
 *
 *  @param backgroundColor 颜色
 */
- (void)showBackgroundLayerWithColor:(UIColor *)backgroundColor;


#pragma mark - Label

- (void)isShowCenterTipLabel:(BOOL)isShow;
- (void)isShowSubTipLabel:(BOOL)isShow;

//Center Label
- (void)setCenterTipLabelWithValue:(CGFloat)value;
- (void)setCenterTipLabelForFont:(UIFont *)font textColor:(UIColor *)textColor;

//Sub Label
- (void)setSubLabelForFont:(UIFont *)font textColor:(UIColor *)textColor;

@end
