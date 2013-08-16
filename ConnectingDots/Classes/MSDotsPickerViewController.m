//
//  MSDotsPickerViewController.m
//  ConnectDots
//
//  Created by Apple on 8/12/13.
//  Copyright (c) 2013 Michal Smialko. All rights reserved.
//

#import "MSDotsPickerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface MSDotsPickerViewController ()
@property (nonatomic, strong) NSMutableArray *dotViews;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *dragAttachment;

@property (nonatomic, strong) UIViewController *openedVC;

@property (nonatomic, strong) AVAudioPlayer *explodePlayer;
@property (nonatomic, strong) AVAudioPlayer *snapPlayer;

@end

@implementation MSDotsPickerViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]];
    
    
    NSString *fileName = @"explode";
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: path];
    self.explodePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:NULL];
    self.explodePlayer.volume = 1.0;
    [self.explodePlayer prepareToPlay];
    
    fileName = @"spring";
    path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"];
    fileURL = [[NSURL alloc] initFileURLWithPath: path];
    self.snapPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:NULL];
    self.snapPlayer.volume = 1.0;
    [self.snapPlayer prepareToPlay];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Background dots
    for (NSInteger i=0; i<30; i++) {
        CGFloat xPos = rand() % (NSInteger)self.view.frame.size.width;
        CGFloat yPos = rand() % (NSInteger)(self.view.frame.size.width);
        
        CGFloat size = 30 + (rand() % 70);
        CGFloat alpha = 1.f / (rand() % 10 + 1);
        
        UIView *bgDot = [[UIView alloc] initWithFrame:CGRectMake(xPos, yPos, size, size)];
        bgDot.backgroundColor = [UIColor lightGrayColor];
        bgDot.alpha = alpha;
        bgDot.layer.cornerRadius = size/2.f;

        [self.view addSubview:bgDot];
        
        [self _animateBgDotToNextPoint:bgDot];
    }

    // Create main dots
    self.dotViews = [[NSMutableArray alloc] initWithCapacity:[self.dataSource dotsPickerItemsCount:self]];
    
    for (NSInteger i=0; i<[self.dataSource dotsPickerItemsCount:self]; i++) {
        UIView *dotView = [[UIView alloc] init];
        
        UIView *itemView = [self.dataSource dotsPicker:self viewForItemAtIndex:i];
        itemView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        CGRect itemFrame = itemView.frame;
        itemFrame.origin = CGPointZero;
        [dotView addSubview:itemView];
        
        dotView.frame = CGRectMake(0,
                                   0,
                                   itemFrame.size.width,
                                   itemFrame.size.height);
        dotView.center = [self _itemPositionAtIndex:i];
        dotView.layer.cornerRadius = dotView.frame.size.width/2.f;
        dotView.clipsToBounds = YES;
        
        dotView.backgroundColor = [UIColor redColor];
        
        UIButton *btn = [[UIButton alloc] init];
        btn.frame = dotView.bounds;
        btn.tag = i;
        [btn addTarget:self
                action:@selector(_dotViewTapped:)
      forControlEvents:UIControlEventTouchUpInside];
        [dotView addSubview:btn];
        
        [self.view addSubview:dotView];
        [self.dotViews addObject:dotView];
    }
    
    
    // Top label
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont fontWithName:@"HoeflerText-Italic" size:36.0];
    titleLabel.text = NSLocalizedString(@"Dots of History", nil);
    titleLabel.textColor = [UIColor darkGrayColor];
    [titleLabel sizeToFit];
    titleLabel.center = CGPointMake(self.view.frame.size.width/2.f,
                                    titleLabel.frame.size.height*2);
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:titleLabel];
    
    // Add gesture recognizer
    for (UIView *dot in self.dotViews) {
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(_dotDragged:)];
        [dot addGestureRecognizer:panGesture];
    }
    
    [self _applyAttachmentsToDots];
    
    // Push the first dot
    UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[self.dotViews[0]] mode:UIPushBehaviorModeInstantaneous];
    push.pushDirection = CGVectorMake(2, 2);
    [self.animator addBehavior:push];
}

#pragma mark - MSDotsPickerViewController ()

- (void)_applyAttachmentsToDots
{
    [self.animator removeAllBehaviors];

    // Add attachments between the dots
    NSUInteger count = [self.dotViews count];
    for (NSUInteger i=0; i<count; i++) {
        if (i != count - 1) {
            UIAttachmentBehavior *attachment = [[UIAttachmentBehavior alloc] initWithItem:self.dotViews[i]
                                                                           attachedToItem:self.dotViews[i+1]];
            
            CGPoint c1 = [self _itemPositionAtIndex:i];
            CGPoint c2 = [self _itemPositionAtIndex:i+1];
            
            attachment.length = sqrt(pow((c1.x - c2.x),2) + pow((c1.y - c2.y),2));
            
            [self _applySpringPreferenceToBehavior:attachment];
            [self.animator addBehavior:attachment];
        }
        
        CGPoint dotCenter = [self _itemPositionAtIndex:i];
        UIAttachmentBehavior *snap = [[UIAttachmentBehavior alloc] initWithItem:self.dotViews[i]
                                                               attachedToAnchor:dotCenter];
        snap.length = 0.f;
        [self _applySpringPreferenceToBehavior:snap];
        [self.animator addBehavior:snap];
    }
}

- (void)_applySpringPreferenceToBehavior:(UIAttachmentBehavior *)attachment
{
    [attachment setFrequency:1.0];
    [attachment setDamping:1.0];
}

- (void)_dotDragged:(UIPanGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:gesture.view.superview];

    if (!self.dragAttachment) {
        self.dragAttachment = [[UIAttachmentBehavior alloc] initWithItem:gesture.view
                                                        attachedToAnchor:location];

        [self.dragAttachment setFrequency:4.0];
        [self.dragAttachment setDamping:0.5];
        
        [self.animator addBehavior:self.dragAttachment];
    }

    self.dragAttachment.anchorPoint = location;
    
    switch(gesture.state) {
        case UIGestureRecognizerStateEnded:
            [self.animator removeBehavior:self.dragAttachment];
            self.dragAttachment = nil;
        default:
            break;
    }

//    NSUInteger index = [self.dotViews indexOfObject:gesture.view];
//    UIAttachmentBehavior *attachment = self.dotsAttachmentAnimator.behaviors[index];
//    attachment.anchorPoint = location;
}

- (CGPoint)_itemPositionAtIndex:(NSUInteger)index
{
    NSUInteger dotsCount = [self.dataSource dotsPickerItemsCount:self];
    CGSize contentSize = self.view.bounds.size;
    
    const CGFloat leftMargin = 130;
    const CGFloat upperMargin = 300;
    
    CGFloat yDeviation = rand() % 150;
    
    CGFloat xPos = leftMargin + (contentSize.width/dotsCount)*index;
    CGFloat yPos = upperMargin + yDeviation;
    
    return CGPointMake(xPos, yPos);
}

- (void)_dotViewTapped:(UIButton *)btn
{
    UIView *tappedView = self.dotViews[btn.tag];

    // Remove all atachments
    [self.animator removeAllBehaviors];    

    // Snap tapped view
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:tappedView
                                                    snapToPoint:CGPointMake(self.view.frame.size.width/2.f,
                                                                            self.view.frame.size.height/2.f)];
    [self.animator addBehavior:snap];
    
    [self.snapPlayer play];
    
    // Animate not tapped dots
    [UIView animateWithDuration:0.3 animations:^{
        for (UIView *dot in self.dotViews) {
            if (dot != tappedView) {
                dot.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
            }
        }
    } completion:^(BOOL finished) {
        
        for (UIView *dot in self.dotViews) {
            if (dot != tappedView) {
                [UIView animateWithDuration:0.4 animations:^{
                    dot.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1./100., 1./100.);
                } completion:^(BOOL finished) {
                    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[]];
                    
                    // sound
                    [self.explodePlayer play];
                    
                    for (UIView *dot in self.dotViews) {
                        if (dot != tappedView) {
                            // Explode
                            for (NSUInteger i=0; i<2; i++) {
                                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
                                view.backgroundColor = [UIColor blackColor];
                                view.layer.cornerRadius = view.frame.size.width/2.f;
                                view.center = dot.center;
                                [self.view addSubview:view];
                                [gravity addItem:view];
                                
                                // Apply random force
                                UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[view]
                                                                                        mode:UIPushBehaviorModeInstantaneous];
                                
                                CGFloat xDir = rand() % 5;
                                xDir = rand() % 2 == 0 ? xDir : -xDir;
                                xDir /= 50;
                                CGFloat yDir = rand() % 6;
                                yDir /= 30;
                                push.pushDirection = CGVectorMake(xDir, -yDir);
                                [self.animator addBehavior:push];
                                
                                CGFloat duration = rand() % 20;
                                duration /= 10;
                                
                                [UIView animateWithDuration:duration animations:^{
                                    view.alpha = 0.0;
                                } completion:^(BOOL finished) {
                                    [view removeFromSuperview];
                                }];
                            }
                            
                        }
                    }
                    
                    [self.animator addBehavior:gravity];
            
        }];
                
            }
        }
    }];
    
    [self performSelector:@selector(_startTransitionAnimationWithTappedDotAtIndex:)
               withObject:@(btn.tag)
               afterDelay:1.0];
}

- (void)_startTransitionAnimationWithTappedDotAtIndex:(NSNumber *)index
{
    UIViewController *vc = [self.dataSource viewControllerForDotAtIndex:[index integerValue]];
    if (!vc) {
        [self _closeButtonTapped];
    }
    vc.view.frame = self.view.bounds;
    vc.view.alpha = 0.0;
    [self.view addSubview:vc.view];
    vc.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1./100., 1./100.);
    
    // Add Close button
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"closeBtn"]
         forState:UIControlStateNormal];
    [btn sizeToFit];
    btn.frame = CGRectOffset(btn.frame, 30, 30);
    [btn addTarget:self
            action:@selector(_closeButtonTapped)
  forControlEvents:UIControlEventTouchUpInside];
    [vc.view addSubview:btn];
    
    // Transition animation
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         vc.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.3, 1.3);
                         vc.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             vc.view.transform = CGAffineTransformIdentity;
                         } completion:^(BOOL finished){
                             [self.delegate dotsPicker:self didEndViewControllerTransition:vc];
                         }];
    }];
    
    self.openedVC = vc;
}

- (void)_animateBgDotToNextPoint:(UIView *)bgDot
{    
    CGFloat randomTime = rand() % 6 + 3;
    
    [UIView animateWithDuration:randomTime animations:^{
        CGFloat xDiv = rand() % 40;
        CGFloat yDiv = rand() % 40;
        xDiv = rand() % 2 == 0 ? xDiv : -xDiv;
        yDiv = rand() % 2 == 0 ? yDiv : -yDiv;
        
        CGPoint nextCenter = CGPointMake(bgDot.center.x + xDiv,
                                         bgDot.center.y + yDiv);
        bgDot.center = nextCenter;
        
    } completion:^(BOOL finished) {
        [self _animateBgDotToNextPoint:bgDot];
    }];
}

- (void)_closeButtonTapped
{
    [UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.openedVC.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1./100., 1./100.);
    } completion:^(BOOL finished) {
        [self.openedVC.view removeFromSuperview];
        self.openedVC = nil;
    } ];
    
    [UIView animateWithDuration:0.6
                          delay:0.3
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         for (UIView *dot in self.dotViews) {
                             dot.transform = CGAffineTransformIdentity;
                         }
                     }
                     completion:^(BOOL finished) {
                         [self _applyAttachmentsToDots];
                     }];
    
}

@end
