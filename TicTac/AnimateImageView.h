//
//  animateImageView.h
//  TicTac
//
//  Created by Yecheng Li on 02/05/15.
//  Copyright (c) 2015 Yecheng Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface animateImageView : UIImageView <UIGestureRecognizerDelegate>

- (void) toBeDragged;
- (void) notToBeDragged;
- (void) beRemoved;

- (void) backToX;
- (void) backToO;

@end
