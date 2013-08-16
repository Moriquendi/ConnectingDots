//
//  MSIPhoneEventViewController.m
//  ConnectingDots
//
//  Created by Michal Smialko on 8/14/13.
//  Copyright (c) 2013 Michal Smialko. All rights reserved.
//

#import "MSIPhoneEventViewController.h"
#import "UIImage+ImageEffects.h"

@interface MSIPhoneEventViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *blurryBg;

//@property (nonatomic, strong) IBOutlet UIView *page2View;
@property (weak, nonatomic) IBOutlet UITextView *page2TextView;
@property (nonatomic, strong) UIImageView *page2ImageView;
@property (nonatomic, strong) UIDynamicAnimator *page2Animator;
@property (nonatomic, strong) UIAttachmentBehavior *page2ImageAttachment;

@property (nonatomic, strong) UIImageView *arrowView;


@end

@implementation MSIPhoneEventViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.frame.size.width*2,
                                                    self.contentScrollView.frame.size.height);
    self.contentScrollView.delegate = self;
    
    self.bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ip1"]];
    self.bgImageView.frame = self.contentScrollView.bounds;
    [self.contentScrollView addSubview:self.bgImageView];
    
    self.blurryBg = [[UIImageView alloc] init];
    [self.contentScrollView addSubview:self.blurryBg];
    
    // Arrow
    self.arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rightArrow"]];
    self.arrowView.center = CGPointMake(self.contentScrollView.frame.size.width - 70,
                                   self.contentScrollView.frame.size.height/2.f);
    [self.contentScrollView addSubview:self.arrowView];
    
    // Page 2
//    self.page2View = [[UIView alloc] init];
//    self.page2View.frame = CGRectOffset(self.contentScrollView.bounds,
//                                        self.contentScrollView.bounds.size.width,
//                                        0);
//    [self.contentScrollView addSubview:self.page2View];
    
    
    UITextView *quoteView = [[UITextView alloc] init];
    quoteView.text = @"\"The phone is not just a communication tool but a way of life.\"";
    quoteView.frame = CGRectMake(0, 0, 500, 300);
    quoteView.font = [UIFont fontWithName:@"HoeflerText-Italic" size:50.0];
    quoteView.backgroundColor = [UIColor clearColor];
    quoteView.userInteractionEnabled = NO;
    quoteView.textColor = [UIColor darkGrayColor];
    quoteView.textAlignment = NSTextAlignmentCenter;
    quoteView.center = CGPointMake(self.contentScrollView.frame.size.width + self.contentScrollView.frame.size.width/2.f,
                                   self.contentScrollView.frame.size.height/2. - 100);
    self.page2TextView = quoteView;
    [self.contentScrollView addSubview:quoteView];

    
    
    self.page2ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iphoneImage"]];
    self.page2ImageView.center = CGPointMake(self.contentScrollView.frame.size.width + self.contentScrollView.frame.size.width/2.f,
                                             self.view.frame.size.height/2.f + 100);
    [self.contentScrollView addSubview:self.page2ImageView];
    
    
    self.page2Animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.contentScrollView];
    UISnapBehavior *imageSnap = [[UISnapBehavior alloc] initWithItem:self.page2ImageView
                                                         snapToPoint:self.page2ImageView.center];
    [self.page2Animator addBehavior:imageSnap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(imageDragged:)];
    [self.page2ImageView addGestureRecognizer:pan];
    self.page2ImageView.userInteractionEnabled = YES;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Arrow animation
    self.arrowView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1./100., 1./100.);
    [UIView animateWithDuration:0.7
                          delay:0.7
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.arrowView.transform = CGAffineTransformIdentity;
                     }
                     completion:nil];
    
    // Generate blurry background view
    UIGraphicsBeginImageContextWithOptions(self.bgImageView.frame.size, YES, 0);
    [self.bgImageView drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:NO];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    dispatch_async(dispatch_queue_create("CreateBlur", nil), ^{
        UIImage *blurImage = [newImage applyLightEffect];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.blurryBg.image = blurImage;
            self.blurryBg.frame = self.view.bounds;
            self.blurryBg.alpha = 0.0;
        });
        
    });
}

#pragma mark - MSIPhoneEventViewController

- (void)imageDragged:(UIPanGestureRecognizer *)panGesture
{
    CGPoint location = [panGesture locationInView:self.page2ImageView.superview];
    if (!self.page2ImageAttachment) {
        self.page2ImageAttachment = [[UIAttachmentBehavior alloc] initWithItem:self.page2ImageView
                                                              attachedToAnchor:location];
        [self.page2ImageAttachment setDamping:0.8];
        [self.page2ImageAttachment setFrequency:10.8];
        [self.page2Animator addBehavior:self.page2ImageAttachment];
    }
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateChanged: {
            self.page2ImageAttachment.anchorPoint = location;
            
            CGRect imageRect = self.page2ImageView.frame;
            imageRect = [self.page2ImageView.superview convertRect:imageRect toView:self.page2TextView];
            UIBezierPath *path = [UIBezierPath bezierPathWithRect:imageRect];
            self.page2TextView.textContainer.exclusionPaths = @[path];
        }
            
            break;
        case UIGestureRecognizerStateEnded:
            self.page2TextView.textContainer.exclusionPaths = @[];
            [self.page2Animator removeBehavior:self.page2ImageAttachment];
            self.page2ImageAttachment = nil;
            break;
        default:
            break;
    }
}

#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.blurryBg.alpha = MIN(1.0, scrollView.contentOffset.x / (scrollView.frame.size.width*0.75));
    self.bgImageView.frame = CGRectOffset(self.bgImageView.bounds,
                                          scrollView.contentOffset.x,
                                          0);
    self.blurryBg.frame = self.bgImageView.frame;
    
    // Arrow
    self.arrowView.alpha = 1.0 - self.blurryBg.alpha;
}

@end
