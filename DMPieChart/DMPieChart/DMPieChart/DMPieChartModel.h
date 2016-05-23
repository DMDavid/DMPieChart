//
//  DMPieChartModel.h
//  DMPieChart
//
//  Created by David on 16/5/22.
//  Copyright © 2016年 OrangeCat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DMPieChartModel : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, strong) NSNumber *value;
@property(nonatomic, strong) UIColor *color;
@property(nonatomic, strong) NSNumber *totalValue;

#pragma mark - 计算后值
@property(nonatomic, assign) CGFloat percentage;    //百分比
@property(nonatomic, assign) CGFloat startAngle;    //开始角度
@property(nonatomic, assign) CGFloat endAngle;

- (instancetype)initWithName:(NSString *)name value:(NSNumber *)value color:(UIColor *)color totalValue:(NSNumber *)totalValue;

@end
