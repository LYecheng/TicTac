//
//  ViewController.h
//  TicTac
//
//  Created by Yecheng Li on 02/04/15.
//  Copyright (c) 2015 Yecheng Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "animateImageView.h"

@interface ViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *cells;
@property (strong, nonatomic) NSMutableArray *cellRecord;

@property (assign, nonatomic) NSInteger count;

@property (assign, nonatomic) animateImageView *gameView;

@property (nonatomic) AVAudioPlayer* audioPlayer;

- (IBAction)infoTapped:(id)sender;

@end

