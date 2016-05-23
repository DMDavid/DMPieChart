//
//  DMPieChartModel.m
//  DMPieChart
//
//  Created by David on 16/5/22.
//  Copyright © 2016年 OrangeCat. All rights reserved.
//

#import "DMPieChartModel.h"

@implementation DMPieChartModel

- (instancetype)initWithName:(NSString *)name value:(NSNumber *)value color:(UIColor *)color totalValue:(NSNumber *)totalValue {
    self = [super init];
    if (self) {
        self.name = name;
        self.value = value;
        self.color = color;
        self.totalValue = totalValue;
        [self calculateForPercentage];
    }
    return self;
}

//计算值
- (void)calculateForPercentage {
    if (_value && _totalValue) {
        _percentage = _value.floatValue/_totalValue.floatValue; 
    }
}

@end
