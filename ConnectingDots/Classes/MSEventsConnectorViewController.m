//
//  MSEventsConnectorViewController.m
//  ConnectingDots
//
//  Created by Michal Smialko on 8/15/13.
//  Copyright (c) 2013 Michal Smialko. All rights reserved.
//

#import "MSEventsConnectorViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import <AVFoundation/AVFoundation.h>

@interface MSEventsConnectorViewController ()

@property (nonatomic, strong) NSMutableArray *dots;
@property (nonatomic, strong) UIDynamicAnimator *animator;

@property (nonatomic, strong) UIAttachmentBehavior *dotAttachment;
@property (nonatomic, strong) AVAudioPlayer *snapPlayer;

@end

@implementation MSEventsConnectorViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *fileName = @"spring";
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: path];
    self.snapPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:NULL];
    self.snapPlayer.volume = 1.0;
    [self.snapPlayer prepareToPlay];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor darkGrayColor];
    titleLabel.font = [UIFont fontWithName:@"HoeflerText-Italic" size:36.0];
    titleLabel.text = @"Who made what?";
    [titleLabel sizeToFit];
    titleLabel.center = CGPointMake(self.view.frame.size.width/2.f, titleLabel.frame.size.height*2);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:titleLabel];
    
    self.animator = [[UIDynamicAnimator alloc] init];
    self.dots = [[NSMutableArray alloc] init];
    
    // Make dots views
    NSArray *names = @[@"DOS", @"Microsoft", @"MacOS", @"Apple", @"UNIX", @"AT&T"];
    for (NSInteger i=0; i<6; i++) {
        UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 140)];
        dot.backgroundColor =  [UIColor blackColor];
        dot.layer.cornerRadius = dot.frame.size.width/2.f;
        dot.clipsToBounds = YES;
        
        UILabel *name = [[UILabel alloc] init];
        name.text = names[i];
        name.frame = CGRectInset(dot.bounds, 15, 15);
        name.textColor = [UIColor whiteColor];
        name.textAlignment = NSTextAlignmentCenter;
        name.font = [UIFont fontWithName:@"Helvetica-Bold" size:24.];
        [dot addSubview:name];
        
        dot.center = [self _dotPositionAtIndex:i];

        UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:dot snapToPoint:dot.center];
        [snap setDamping:0.4];
        
        [self.animator addBehavior:snap];
        
        UIPanGestureRecognizer *dragGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_dotDragged:)];
        [dot addGestureRecognizer:dragGesture];

        [self performSelector:@selector(_pushDots) withObject:nil afterDelay:1.0];
        
        [self.view addSubview:dot];
        [self.dots addObject:dot];
    }
    
}

#pragma mark - MSEventsConnectorViewController ()

- (void)_pushDots
{
    for (UIView *dot in self.dots) {
        UIPushBehavior *smallPush = [[UIPushBehavior alloc] initWithItems:@[dot] mode:UIPushBehaviorModeInstantaneous];
        smallPush.pushDirection = CGVectorMake(rand()%20,
                                               rand()%20);
        smallPush.pushDirection = CGVectorMake(rand() % 2 ? smallPush.pushDirection.dx : -smallPush.pushDirection.dx,
                                               rand() % 2 ? smallPush.pushDirection.dy : -smallPush.pushDirection.dy);
        
        [self.animator addBehavior:smallPush];
    }
}

- (void)_dotDragged:(UIPanGestureRecognizer *)pan
{
    CGPoint location = [pan locationInView:self.view];

    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {
            if (!self.dotAttachment) {
                self.dotAttachment = [[UIAttachmentBehavior alloc] initWithItem:pan.view
                                                               attachedToAnchor:location];
                [self.dotAttachment setFrequency:8.0];
                [self.dotAttachment setDamping:0.5];
                [self.animator addBehavior:self.dotAttachment];
            }
        }
            break;
        case UIGestureRecognizerStateEnded: {
            [self.animator removeBehavior:self.dotAttachment];
            [self.snapPlayer play];
            self.dotAttachment = nil;
        }
            break;
        case UIGestureRecognizerStateChanged:
            self.dotAttachment.anchorPoint = location;
            self.dotAttachment.length = 0.0;
            break;
        default:
            break;
    }
    
    BOOL allDotsDisabled = YES;
    for (UIView *dot in self.dots) {
        
        if (dot.userInteractionEnabled) {
            allDotsDisabled = NO;
        }
        
        NSInteger dotIndex1 = [self.dots indexOfObject:pan.view];
        NSInteger dotIndex2 = [self.dots indexOfObject:dot];
        
        if (dotIndex2 < dotIndex1) {
            NSInteger tmp = dotIndex1;
            dotIndex1 = dotIndex2;
            dotIndex2 = tmp;
        }
        
        if (dot != pan.view &&
            dot.userInteractionEnabled &&
            dotIndex2 - dotIndex1 == 1 && dotIndex2 % 2 == 1 &&
            CGRectIntersectsRect(CGRectInset(pan.view.frame, 30, 30),
                                 CGRectInset(dot.frame, 30, 30))) {
                
                CGPoint c1 = [self _dotPositionAtIndex:dotIndex1];
                CGPoint c2 = [self _dotPositionAtIndex:dotIndex2];
                
                CGFloat width = sqrt(pow((c1.x - c2.x), 2) + pow((c1.y - c2.y), 2));
                UIView *connection = [[UIView alloc] initWithFrame:CGRectMake(c2.x, c2.y, width, 2)];
                connection.center = CGPointMake((c2.x - c1.x)/2. + c1.x,
                                                (c2.y - c1.y)/2. + c1.y);
                
                double radians = atan((c1.y - c2.y) / (c1.x - c2.x));
                connection.transform = CGAffineTransformRotate(CGAffineTransformIdentity, radians);
                connection.center = CGPointMake((c2.x - c1.x)/2. + c1.x,
                                                (c2.y - c1.y)/2. + c1.y);
                
                connection.backgroundColor = [UIColor blackColor];
                [self.view insertSubview:connection atIndex:0];
                connection.transform = CGAffineTransformScale(connection.transform, 1./100., 1./100.);
                connection.alpha = 0.0;
                [UIView animateWithDuration:0.8 animations:^{
                    connection.transform = CGAffineTransformScale(connection.transform, 100, 100);
                    connection.alpha = 1.0;
                }];

                [self.animator removeBehavior:self.dotAttachment];
                self.dotAttachment = nil;
                
                [dot setUserInteractionEnabled:NO];
                [pan.view setUserInteractionEnabled:NO];
                [pan setEnabled:NO];
                

                [self.snapPlayer play];
                
            break;
        }
    }
    
    if (allDotsDisabled) {
        UILabel *congratsLabel = [[UILabel alloc] init];
        congratsLabel.font = [UIFont fontWithName:@"HoeflerText-Italic" size:70.0];
        congratsLabel.text = @"Correct!";
        congratsLabel.textColor = [UIColor darkGrayColor];
        [congratsLabel sizeToFit];
        congratsLabel.center = [self.view convertPoint:self.view.center fromView:self.view.superview];
        [self.view addSubview:congratsLabel];
        congratsLabel.alpha = 0.0;
        congratsLabel.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1./100, 1./100);
        
        [self _pushDots];
        
        [UIView animateWithDuration:0.6 animations:^{
            congratsLabel.alpha = 1.0;
            congratsLabel.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self _pushDots];
        }];
        
    }
    
}

- (CGPoint)_dotPositionAtIndex:(NSUInteger)index
{
//    CGFloat randomX = rand() % (NSInteger)(self.view.frame.size.width-300) + 100;
//    CGFloat randomY = rand() % (NSInteger)(self.view.frame.size.height-300) + 100;
//    return CGPointMake(randomX, randomY);
    CGFloat x, y;
    switch (index) {
        case 0:
            x = 150;
            y = 190;
            break;
        case 1:
            x = 460;
            y = 280;
            break;
        case 2:
            x = 700;
            y = 600;
            break;
        case 3:
            x = 900;
            y = 270;
            break;
        case 4:
            x = 190;
            y = 600;
            break;
        case 5:
            x = 540;
            y = 500;
            break;
    }
    return CGPointMake(x, y);
}

@end
