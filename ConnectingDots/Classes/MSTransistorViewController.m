//
//  MSTransistorViewController.m
//  ConnectingDots
//
//  Created by Michal Smialko on 8/15/13.
//  Copyright (c) 2013 Michal Smialko. All rights reserved.
//

#import "MSTransistorViewController.h"

@interface MSTransistorViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *inventorsImageView;
@property (weak, nonatomic) IBOutlet UIImageView *firstTransImageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation MSTransistorViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect investorsRect = [self.inventorsImageView.superview convertRect:[self.inventorsImageView frame] toView:self.textView];
    CGRect transistorRect = [self.inventorsImageView.superview convertRect:[self.firstTransImageView frame] toView:self.textView];
    
    UIBezierPath *inventorsPath = [UIBezierPath bezierPathWithRect:investorsRect];
    UIBezierPath *transistorPath = [UIBezierPath bezierPathWithRect:transistorRect];
    
    self.textView.textContainer.exclusionPaths = @[inventorsPath, transistorPath];
    
    
}

@end
