//
//  DMPieChartView.m
//  DMPieChart
//
//  Created by David on 16/5/22.
//  Copyright © 2016年 OrangeCat. All rights reserved.
//

#import "DMPieChartView.h"

#define PIE_CHART_LAYER_RADIUS self.bounds.size.width/2     //圆环半径
#define CENTER_BLANK_LAYER_RADIUS PIE_CHART_LAYER_RADIUS/3      //空白圆环半径
#define CIRCLE_TOTAL_ANGLE M_PI*2   //圆环总角度
//#define PIE_CHART_LAYER_MARGIN 0.01*CIRCLE_TOTAL_ANGLE  //圆环间距

@implementation DMPieChartView {
    CGFloat _temEndAnglePercentage;   //上一个结束角度
    CAShapeLayer *_animationLayer;    //用来显示动画的layer
    NSArray *_pieChartModels;         //数组
    NSMutableArray *_subLayerArray;   //图层数组
    
    UILabel *_centerLabel;            //中心Label
    NSMutableArray *_subLabels;        //各图层label
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame pieChartModels:nil];
}

- (instancetype)initWithFrame:(CGRect)frame pieChartModels:(NSArray *)pieChartModels {
    self = [super initWithFrame:frame];
    if (self) {
        if ([self checkPieChartModels:pieChartModels]) {
            
            _pieChartModels = pieChartModels;
            [self commonInit];
        }
    }
    return self;
}

- (void)commonInit {
    [self configPieChartWithModels];
    [self cofigAnimationOperation];
    [self configGestureRecognizer];
}

- (void)showBackgroundLayerWithColor:(UIColor *)backgroundColor {
    [self backgroundLayer:backgroundColor];
}


#pragma mark - Datas

- (void)configPieChartWithModels {
    [self cofigPieChartsWithModels];
    [self setCenterBlankLayer];
}

//根据数据配置图层
- (void)cofigPieChartsWithModels {
    
    _subLayerArray = [[NSMutableArray alloc] init];
    _subLabels = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < _pieChartModels.count; i++) {
        DMPieChartModel *model = _pieChartModels[i];
        if (![self isPieChartModel:model]) {
            NSAssert(NO, @"model must be DMPieChartModel!");
        }
        if (i == 0) {
            model.startAngle = -M_PI_2;
            model.endAngle = model.startAngle + model.percentage * CIRCLE_TOTAL_ANGLE;
        } else {
            model.startAngle = _temEndAnglePercentage;
            model.endAngle = _temEndAnglePercentage + model.percentage * CIRCLE_TOTAL_ANGLE;
        }
        _temEndAnglePercentage = model.endAngle;
        
        //生成图层
        CAShapeLayer *layer = [self setPieChartLayerWithPieChartModel:model];
        [self.layer addSublayer:layer];
        [_subLayerArray addObject:layer];
        
        //生成Label
        [self createDescriptionLabel:model];
    }
}

//中心白色Layer
- (void)setCenterBlankLayer {
    CAShapeLayer *pieLayer = [CAShapeLayer new];
    [self.layer addSublayer:pieLayer];
    pieLayer.frame = self.bounds;
    pieLayer.fillColor = [UIColor whiteColor].CGColor;
    pieLayer.path = [self setPieChartWithRadius:CENTER_BLANK_LAYER_RADIUS startAngle:-M_PI_2 endAngle:3*M_PI_2].CGPath;
}

//圆环layer
- (CAShapeLayer *)setPieChartLayerWithPieChartModel:(DMPieChartModel *)pieChartModel {
    CAShapeLayer *pieLayer = [CAShapeLayer new];
    pieLayer.frame = self.bounds;
    pieLayer.fillColor = pieChartModel.color.CGColor;
    pieLayer.path = [self setPieChartWithRadius:PIE_CHART_LAYER_RADIUS startAngle:pieChartModel.startAngle endAngle:pieChartModel.endAngle model:pieChartModel].CGPath;
    return pieLayer;
}

//Creat BezierPath
- (UIBezierPath *)setPieChartWithRadius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path addArcWithCenter:[self getSelfCenterPoint] radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [path addLineToPoint:[self getSelfCenterPoint]];
    return path;
} 

- (UIBezierPath *)setPieChartWithRadius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle model:(DMPieChartModel *)model {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path addArcWithCenter:[self getSelfCenterPointWithModel:model] radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    [path addLineToPoint:[self getSelfCenterPointWithModel:model]];
    return path;
}


#pragma mark - animation Methods

//Animation
- (void)cofigAnimationOperation {
    [self createAnimationLayer];
    [self startAnimation];
}

- (void)createAnimationLayer {
    CAShapeLayer *animationLayer = [CAShapeLayer layer];
    animationLayer.frame = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:[self getSelfCenterPoint] radius:PIE_CHART_LAYER_RADIUS/2 startAngle:-0.5 *M_PI endAngle:1.5 * M_PI clockwise:YES];
    animationLayer.path = path.CGPath;
    animationLayer.lineWidth = PIE_CHART_LAYER_RADIUS;
    animationLayer.strokeColor = [UIColor greenColor].CGColor;
    animationLayer.fillColor = [UIColor clearColor].CGColor;
    animationLayer.strokeEnd = 0;
    self.layer.mask = animationLayer;
    _animationLayer = animationLayer;
}

- (void)startAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @(0);
    animation.toValue = @(1);
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.duration = 1;
    [_animationLayer addAnimation:animation forKey:@"kClockAnimation"];
}

- (CABasicAnimation *)offsetAnimationForSelectionAtIndex:(NSInteger)index {
    if (index < 0 || index > _subLayerArray.count - 1) {
        return nil;
    }
    
    DMPieChartModel *model = _pieChartModels[index];
    CGFloat centerAngle = (model.startAngle+ model.endAngle) / 2;//某个扇形的中心的角度
    CGFloat offsetX = 10 * cos(centerAngle);//10是圆心偏移的距离
    CGFloat offsetY = 10 * sin(centerAngle);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(offsetX, offsetY, 0)];
    animation.duration = 0.4;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}


#pragma mark - GestureRecognizer
- (void)configGestureRecognizer {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:sender.view];
    NSLog(@"location is %@", NSStringFromCGPoint(location));
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    NSInteger index = -1;
    
    for (int i = 0; i < _subLayerArray.count; i ++) {
        CAShapeLayer *shapeLayer = _subLayerArray[i];
        if (CGPathContainsPoint(shapeLayer.path, &transform, location, 0)) {
            index = i;
            break;
        }
    }
    if ([self.delegate respondsToSelector:@selector(pieView:didSelectSectionAtIndex:)]
        && index >= 0) {
        
        for (CALayer *subLayer in _subLayerArray) {
            [subLayer removeAnimationForKey:@"kOffsetAnimation"];
        }
        
        CAShapeLayer *selectedLayer = _subLayerArray[index];
        [selectedLayer addAnimation:[self offsetAnimationForSelectionAtIndex:index] forKey:@"kOffsetAnimation"];
        [self.delegate pieView:self didSelectSectionAtIndex:index];
    } 
}


#pragma mark - Label

- (void)isShowCenterTipLabel:(BOOL)isShow {
    if (isShow) {
        _centerLabel.hidden = NO;
    } else {
        _centerLabel.hidden = YES;
    }
}

- (void)isShowSubTipLabel:(BOOL)isShow {
    for (int i = 0; i < _subLabels.count; i++) {
        UILabel *label = _subLabels[i]; 
        if (isShow) {
            label.hidden = NO;
        } else {
            label.hidden = YES;
        }
    }
}

///----------------------------------
/// @name  center label
///----------------------------------

- (void)setCenterTipLabelWithValue:(CGFloat)value {
    _centerLabel = [self creatCenterTipLabelWithValue:value];
    [self addSubview:_centerLabel];
}

- (UILabel *)creatCenterTipLabelWithValue:(CGFloat)value {
    NSString *text = [NSString stringWithFormat:@"%.2f", value];
    return [self cofigLabelWithText:text center:[self getSelfCenterPoint]];
}

- (void)setCenterTipLabelForFont:(UIFont *)font textColor:(UIColor *)textColor {
    if (!_centerLabel) {
        return;
    }
    [_centerLabel setFont:font];
    [_centerLabel setTextColor:textColor];
}

///----------------------------------
/// @name  sub Label
///----------------------------------

- (void)setSubLabelForFont:(UIFont *)font textColor:(UIColor *)textColor {
    for (int i = 0; i < _subLabels.count; i++) {
        UILabel *label = _subLabels[i];
        [label setTextColor:textColor];
        [label setFont:font];
    }
}

- (void)createDescriptionLabel:(DMPieChartModel *)model {
    UILabel *label = [self creatTipLabelWithModel:model];
    [self addSubview:label];
    [_subLabels addObject:label];
}

- (UILabel *)creatTipLabelWithModel:(DMPieChartModel *)model {
    CGFloat centerAngle = (model.startAngle+ model.endAngle) / 2;//某个扇形的中心的角度
    CGFloat centerX = PIE_CHART_LAYER_RADIUS + cos(centerAngle) * PIE_CHART_LAYER_RADIUS / 2;
    CGFloat centerY = PIE_CHART_LAYER_RADIUS + sin(centerAngle) * PIE_CHART_LAYER_RADIUS / 2;
    
    NSString *text = [NSString stringWithFormat:@"%.2f%%", model.percentage * 100];
    return [self cofigLabelWithText:text center:CGPointMake(centerX, centerY)];
}

- (UILabel *)cofigLabelWithText:(NSString *)text center:(CGPoint)center {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    label.text = text;
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    label.center = center;
    return label;
}


#pragma mark - Private Methods

//图层中心
- (CGPoint)getSelfCenterPoint {
    return CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2);
}

- (CGPoint)getSelfCenterPointWithModel:(DMPieChartModel *)model {
    CGFloat centerAngle = (model.startAngle+ model.endAngle) / 2;//某个扇形的中心的角度
    CGFloat offsetX = 2 * cos(centerAngle);//10是圆心偏移的距离
    CGFloat offsetY = 2 * sin(centerAngle);
    CGPoint center = [self getSelfCenterPoint];
    return CGPointMake(center.x + offsetX, center.y + offsetY);
}

- (BOOL)checkPieChartModels:(NSArray *)pieChartModels {
    if (pieChartModels && pieChartModels.count != 0) {
        return YES;
    }
    return NO;
}

- (BOOL)isPieChartModels:(NSArray *)pieChartModels {
    BOOL isPieChartModels = NO;
    for (int i = 0; i < pieChartModels.count; i++) {
        if ([pieChartModels[i] isKindOfClass:[DMPieChartModel class]]) {
            isPieChartModels = YES;
        }
    }
    return isPieChartModels;
}

- (BOOL)isPieChartModel:(DMPieChartModel *)model {
    if (model && [model isKindOfClass:[DMPieChartModel class]]) {
        return YES;
    }
    return NO;
}

- (void)reloadData {
    for (CALayer *layer in self.layer.sublayers) {
        [layer removeAllAnimations];
    }
    _subLayerArray = nil;
    
    [self commonInit];
}

//背景Default Layer
- (void)backgroundLayer:(UIColor *)backgoundLayerColor {
    CAShapeLayer *pieLayer = [CAShapeLayer new];
    [self.layer addSublayer:pieLayer];
    pieLayer.frame = self.bounds;
    if (backgoundLayerColor) {
        pieLayer.fillColor = backgoundLayerColor.CGColor;
    } else {
        pieLayer.fillColor = [UIColor greenColor].CGColor;
    }
    pieLayer.path = [self setPieChartWithRadius:PIE_CHART_LAYER_RADIUS startAngle:-M_PI_2 endAngle:3*M_PI_2].CGPath;
}

@end
