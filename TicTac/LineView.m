//
//  LineView.m
//  TicTac
//
//  Created by Yecheng Li on 02/08/15.
//  Copyright (c) 2015 Yecheng Li. All rights reserved.
//

#import "LineView.h"

@implementation LineView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    
    CGContextSetLineWidth(context, 5.0f);
    CGContextMoveToPoint(context, self.startPoint.center.x, self.startPoint.center.y);
    CGContextAddLineToPoint(context, self.endPoint.center.x, self.endPoint.center.y);
    
    CGContextStrokePath(context);
}

@end
