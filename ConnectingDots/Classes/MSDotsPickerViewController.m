//
//  MSDotsPickerViewController.m
//  ConnectDots
//
//  Created by Apple on 8/12/13.
//  Copyright (c) 2013 Michal Smialko. All rights reserved.
//

#import "MSDotsPickerViewController.h"

@interface MSDotsPickerViewController ()
@property (nonatomic, strong) NSMutableArray *dotViews;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@end

@implementation MSDotsPickerViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.dotViews = [[NSMutableArray alloc] initWithCapacity:[self.dataSource itemsCount]];
    
    for (NSInteger i=0; i<[self.dataSource itemsCount]; i++) {
        UIView *itemView = [self.dataSource viewForItemAtIndex:i];
        
        UIView *dotView = [[UIView alloc] init];
        [dotView addSubview:itemView];
        CGSize dotSize = [self _itemSizeAtIndex:i];
        dotView.frame = CGRectMake(0, 0, dotSize.width, dotSize.height);
        dotView.center = [self _itemPositionAtIndex:i];
        dotView.layer.cornerRadius = dotView.frame.size.width/2.f;
        
        UIButton *btn = [[UIButton alloc] init];
        btn.frame = dotView.bounds;
        btn.tag = i;
        [btn addTarget:self
                action:@selector(_dotViewTapped:)
      forControlEvents:UIControlEventTouchUpInside];
        [dotView addSubview:btn];
        
        [self.view addSubview:itemView];
        
        [self.dotViews addObject:dotView];
    }
}

#pragma mark - MSDotsPickerViewController ()

- (CGPoint)_itemPositionAtIndex:(NSUInteger)index
{
    return CGPointMake(300, 300);
}

- (CGSize)_itemSizeAtIndex:(NSUInteger)index
{
    return CGSizeMake(180, 180);
}

- (void)_dotViewTapped:(UIButton *)btn
{
    UIView *tappedView = self.dotViews[btn.tag];

    // Snap tapped view
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:tappedView
                                                    snapToPoint:CGPointMake(self.view.frame.size.width/2.f,
                                                                            self.view.frame.size.height/2.f)];
    snap.action = ^{
        [[self class] cancelPreviousPerformRequestsWithTarget:self
                                                     selector:@selector(_startTransitionAnimationWithTappedView:)
                                                       object:tappedView];
        
        
        [self performSelector:@selector(_startTransitionAnimationWithTappedView:)
                   withObject:tappedView
                   afterDelay:0.5];
    };
    
    [self.animator addBehavior:snap];
    
    //
    for (UIView *dotView in self.dotViews) {
        
    }
}

- (void)_startTransitionAnimationWithTappedView:(UIView *)tappedView
{
    NSLog(@"Start transition");

    
}

@end
