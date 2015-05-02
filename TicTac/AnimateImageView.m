//
//  animateImageView.m
//  TicTac
//
//  Created by Yecheng Li on 02/05/15.
//  Copyright (c) 2015 Yecheng Li. All rights reserved.
//

#import "animateImageView.h"

@implementation animateImageView

/*
    When it is a players turn, their symbol should grow by a factor of 2 and then return to normal size. 
    This indicates that it is one's turn
*/

- (void) toBeDragged {
    [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveLinear
                     animations:^{
        self.transform = CGAffineTransformScale(self.transform, 2.0, 2.0);
    }completion:^(BOOL completed) {
        [UIView animateWithDuration:0.5 delay:0.1 options:UIViewAnimationOptionCurveLinear
                         animations:^{self.transform = CGAffineTransformScale(self.transform, 0.5, 0.5);}
                         completion:^(BOOL finished) {
                             NSLog(@"Animation Finished");
                         }];
    }];
    self.userInteractionEnabled = YES;
    NSLog(@"Symbol ready for dragging.");
}

/*
    Also, disable the user interaction of another symbol
    This indicates that it is NOT one's turn
*/
- (void) notToBeDragged {
    self.userInteractionEnabled = NO;
}

- (void) beRemoved {
    [UIView animateWithDuration:0.2 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformScale(self.transform, 2.0, 2.0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveLinear animations:^{
            self.transform = CGAffineTransformScale(self.transform, 0.5, 0.5);
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            NSLog(@"Symbol removed");
        }];
    }];
}

/*
 Move two symbols to their original positions
 */
- (void) backToX {
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         //self.center = CGPointMake(85, 425);
                         self.center = CGPointMake(90, 550);
                     } completion:^(BOOL finished) {
                         NSLog(@"X back");
                     }];

}

- (void) backToO {
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         //self.center = CGPointMake(235, 425);
                         self.center = CGPointMake(285, 550);
                     } completion:^(BOOL finished) {
                         NSLog(@"O back");
                     }];
}

@end
