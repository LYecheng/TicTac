//
//  ViewController.m
//  TicTac
//
//  Created by Yecheng Li on 02/04/15.
//  Copyright (c) 2015 Yecheng Li. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#import "ViewController.h"
#import "animateImageView.h"
#import "LineView.h"

@interface ViewController ()

@property UIView *startCell;
@property UIView *endCell;
@property LineView *line;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setLaunchBoard];
    [self setSymbols];
    [self playSound:@"%@/begin.wav"];
}

// Create initial launchboard and cells
- (void)setLaunchBoard {
    self.count = 0;
 
    UIImageView *launchBoard = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"LaunchBoard"]];
    [launchBoard setFrame:CGRectMake(25,75,300,300)];
    [launchBoard setTag:100];
    [self.view addSubview:launchBoard];
    
    self.cells = [[NSMutableArray alloc] initWithCapacity:9];
    self.cellRecord = [[NSMutableArray alloc] initWithCapacity:9];
    
    for(int i = 0; i < 9; i++){
        UIView * cell = [[UIView alloc] init];
        [cell setOpaque:NO];
        cell.frame = CGRectMake(25 + i % 3 * 100, 75 + i / 3 * 100, 100, 100);
        [self.cells setObject:cell atIndexedSubscript:i];
        
        //Add grid to boardView
        [launchBoard addSubview:cell];
        
        [self.cellRecord setObject:[NSNumber numberWithInt:i] atIndexedSubscript:i];
    }
    NSLog(@"Board initialized");
}

// Set symbol X and O to their initial state
- (void)setSymbols {
    animateImageView *x = [self initiateX];
    animateImageView *o = [self initiateO];
    
    [x toBeDragged];
    [o notToBeDragged];
    self.gameView = o;
    NSLog(@"Symbol O & X set");
}

// Set X's position
- (animateImageView *)initiateX {
    animateImageView *x = [[animateImageView alloc]initWithImage:[UIImage imageNamed:@"LetterX"]];
    [x setFrame:CGRectMake(40, 500, 90, 90)];
    [x setTag:101];
    [self.view addSubview:x];
    [self addGestureResponder:x];
    NSLog(@"X set");
    
    return x;
}

// Set O's position
- (animateImageView *)initiateO {
    animateImageView *o = [[animateImageView alloc]initWithImage:[UIImage imageNamed:@"LetterO"]];
    [o setFrame:CGRectMake(235, 500, 90, 90)];
    [o setTag:102];
    [self.view addSubview:o];
    [self addGestureResponder:o];
    NSLog(@"O set");
    
    return o;
}

// Drag symbol
- (void)addGestureResponder:(UIView *)symbol{
    UIPanGestureRecognizer *userGesture = [[UIPanGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(dragToBoard:)];
    [userGesture setMaximumNumberOfTouches:3];
    [symbol addGestureRecognizer:userGesture];

}

// Locate symbol into the launchboard after dragging
- (void) dragToBoard:(UIPanGestureRecognizer *)gestureRecognizer {
    UIView *symbol = [gestureRecognizer view];
    [[symbol superview] bringSubviewToFront:symbol];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gestureRecognizer translationInView:[symbol superview]];
        [symbol setCenter:CGPointMake([symbol center].x + translation.x, [symbol center].y + translation.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[symbol superview]];
    }
    [self checkCell:gestureRecognizer];
}

// Check if we can place a symbol into a cell, and keep record
- (void) checkCell: (UIPanGestureRecognizer *)gestureRecognizer {
    UIView *symbol = [gestureRecognizer view];
    CGFloat x = [symbol center].x;
    CGFloat y = [symbol center].y;
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateEnded) {
        int cellNo = ((int)(x-25))/90 + ((int)(y-75))/90 *3;
        
        if (cellNo > 8 || cellNo < 0) {
            if (symbol.tag == 101) {
                [(animateImageView*)symbol backToX];
            }
            else
                [(animateImageView*)symbol backToO];
        }
        else {
            UIView *cell = [self.cells objectAtIndex:cellNo];
            bool occupied = ![[self.cellRecord objectAtIndex:cellNo] isEqualToNumber:[NSNumber numberWithInt:cellNo]];
            bool matched = CGRectIntersectsRect(cell.frame, symbol.frame);
            
            if (matched && !occupied) {
                symbol.center = [cell center];
                NSLog(@"Symbol added to cell");
                
                [self.view addSubview:symbol];
                [self playSound:@"%@/placed.mp3"];
                
                [self.cellRecord setObject:[NSNumber numberWithInt:(int)symbol.tag] atIndexedSubscript:cellNo];
                self.count++;
                int tagOfCurrentSymbol = (int)symbol.tag;
                symbol.tag = cellNo + 1;
                [self checkWinner:tagOfCurrentSymbol];
            }
            else if ((matched && occupied) || !matched) {
                [self playSound:@"%@/rejected.mp3"];
                NSLog(@"Symbol failed to add to cell");
                
                if (symbol.tag == 101) {
                    [(animateImageView*)symbol backToX];
                }
                else {
                    [(animateImageView*)symbol backToO];
                }
            }
        }
    }
}

// Check if there's a win or draw
- (void) checkWinner:(int)tagOfCurrentSymbol {
    bool win = NO;
    bool stale = NO;
    
    // Check vertical
    for (int i = 0; i <= 2; i++) {
        NSNumber *num1 = [self.cellRecord objectAtIndex:i];
        NSNumber *num2 = [self.cellRecord objectAtIndex:i+3];
        NSNumber *num3 = [self.cellRecord objectAtIndex:i+6];
        if ([num1 isEqualToNumber:num2]&&[num1 isEqualToNumber:num3]) {
            win=YES;
            self.startCell = [self.cells objectAtIndex:i];
            self.endCell = [self.cells objectAtIndex:i+6];
        }
    }
    
    //Check horizontal
    for (int i = 0; i <= 6; i = i + 3) {
        NSNumber *num1 = [self.cellRecord objectAtIndex:i];
        NSNumber *num2 = [self.cellRecord objectAtIndex:i+1];
        NSNumber *num3 = [self.cellRecord objectAtIndex:i+2];
        if ([num1 isEqualToNumber:num2]&&[num1 isEqualToNumber:num3]) {
            win=YES;
            self.startCell = [self.cells objectAtIndex:i];
            self.endCell = [self.cells objectAtIndex:i+2];
        }
    }
    
    // Check diagonal
    NSNumber *num0 = [self.cellRecord objectAtIndex:0];
    NSNumber *num4 = [self.cellRecord objectAtIndex:4];
    NSNumber *num8 = [self.cellRecord objectAtIndex:8];
    if ([num0 isEqualToNumber:num4]&&[num0 isEqualToNumber:num8]) {
        win=YES;
        self.startCell = [self.cells objectAtIndex:0];
        self.endCell = [self.cells objectAtIndex:8];
    }
    NSNumber *num2 = [self.cellRecord objectAtIndex:2];
    NSNumber *num6 = [self.cellRecord objectAtIndex:6];
    if ([num2 isEqualToNumber:num4]&&[num2 isEqualToNumber:num6]) {
        win=YES;
        self.startCell = [self.cells objectAtIndex:2];
        self.endCell = [self.cells objectAtIndex:6];
    }
    
    if (win == YES) {
        [self displayWin];
    }

    if(win == NO && self.count == 9){
        stale = YES;
        [self displayDraw];
    }
    
    if (win == NO && stale == NO) {
        [self restart:tagOfCurrentSymbol];
    }
}

// Display winner alert and play celebration sound
- (void) displayWin {
    [self playSound:@"%@/celebration.mp3"];

    self.line = [[LineView alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
    self.line.backgroundColor = [UIColor clearColor];
    
    [self.line setStartPoint:self.startCell];
    [self.line setEndPoint:self.endCell];
    [self.view addSubview:self.line];
    [self.line setNeedsDisplay];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"YOU WIN" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertActionStyleDefault;
    alertView.delegate = self;
    [alertView show];
}

// Display draw alert
- (void) displayDraw {
    [self playSound:@"%@/draw.wav"];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"DRAW" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertActionStyleDefault;
    alertView.delegate = self;
    [alertView show];
}

// Reset parameters and restart game
- (void) restart:(int) tagOfCurrentSymbol {
    for (UIView *subview in [self.view subviews]) {
        if (subview.tag == 20) {
            [subview removeFromSuperview];
        }
    }
    
    if (tagOfCurrentSymbol == 101) {
        animateImageView *x = [self initiateX];
        [x notToBeDragged];
        animateImageView *o = self.gameView;
        self.gameView = x;
        [o toBeDragged];
    }
    else if (tagOfCurrentSymbol == 102) {
        animateImageView *o = [self initiateO];
        [o notToBeDragged];
        animateImageView *x = self.gameView;
        self.gameView = o;
        [x toBeDragged];
    }
}

- (void) alertView: (UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *button = [alertView buttonTitleAtIndex:buttonIndex];
    if ([button isEqualToString:@"OK"]) {
        [self clearBoard];
    }
}

- (void) clearBoard {
    self.count = 0;
    self.line.hidden = YES;
    
    UIView *currentSymbol = self.gameView;
    [currentSymbol removeFromSuperview];
    
    for (int i = 0; i < 9; i++) {
        if (![[self.cellRecord objectAtIndex:i] isEqualToNumber:[NSNumber numberWithInt:i]]) {
            animateImageView *symbol = (animateImageView *)[self.view viewWithTag:i+1];
            [symbol beRemoved];
        }
    }
    [self performSelector:@selector(setLaunchBoard) withObject:self afterDelay:2.0];
    [self performSelector:@selector(setSymbols) withObject:self afterDelay:2.0];
    [self playSound:@"%@/begin.wav"];
}

- (IBAction)infoTapped:(id)sender {
    UIActionSheet *gameRules = [[UIActionSheet alloc] initWithTitle:@"X always goes first.\n\nPlayers alternate placing Xs and Os on the board. \n\nIf a player is able to draw three Xs or three Os in a row, that player wins. \n\nIf all nine squares are filled and neither player has three in a row, the game is a draw." delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"OK", nil];
    
    [gameRules showInView:self.view];
}

- (void)playSound:(NSString*)soundName
{
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:soundName, [[NSBundle mainBundle] resourcePath]]];
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    //[self.audioPlayer setNumberOfLoops: 0];
    [self.audioPlayer play];
    NSLog(@"Play sound named: %@", soundName);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
