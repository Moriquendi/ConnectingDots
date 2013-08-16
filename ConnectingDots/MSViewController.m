//
//  MSViewController.m
//  ConnectingDots
//
//  Created by Michal Smialko on 8/13/13.
//  Copyright (c) 2013 Michal Smialko. All rights reserved.
//

#import "MSViewController.h"
#import "MSDotsPickerViewController.h"
#import "MSEvent.h"
#import "MSIPhoneEventViewController.h"
#import "MSTransistorViewController.h"
#import "MSEventsConnectorViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface MSViewController ()
<MSDotsPickerDataSource,
MSDotsPickerDelegate>
@property (nonatomic, strong) MSDotsPickerViewController *dotsVC;
@property (nonatomic, strong) NSMutableArray *events;

@property (nonatomic, strong) UIViewController *eventVC;

@property (nonatomic, strong) AVAudioPlayer *explodePlayer;

@end

@implementation MSViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.events = [[NSMutableArray alloc] init];
    
    //
    // That's a temporary code
    //
    for (NSInteger i=0; i<5; i++) {
        [self.events addObject:[MSEvent new]];
    }
    
    MSEvent *event = self.events[0];
    event.title = @"Transistor";
    
    event = self.events[4];
    event.title = @"iPhone";
    
    event = self.events[2];
    event.title = @"Software";
    
    //
    //
    //
    
    
    
    // Load Dots Picker VC
    self.dotsVC = [[MSDotsPickerViewController alloc] init];
    self.dotsVC.dataSource = self;
    self.dotsVC.delegate = self;
    self.dotsVC.view.frame = self.view.bounds;
    [self.view addSubview:self.dotsVC.view];
    
    
    
    NSString *fileName = @"bgaudio";
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: path];
    self.explodePlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:NULL];
    self.explodePlayer.volume = 0.9;
    [self.explodePlayer prepareToPlay];
    [self.explodePlayer setNumberOfLoops:NSIntegerMax];
    [self.explodePlayer play];
}

#pragma mark - <MSDotsPickerDataSource>

- (NSUInteger)dotsPickerItemsCount:(MSDotsPickerViewController *)dotsPicker
{
    return [self.events count];
}

- (UIView *)dotsPicker:(MSDotsPickerViewController *)dotsPicker viewForItemAtIndex:(NSUInteger)index
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    view.backgroundColor = [UIColor colorWithRed:34.f/255.f
                                           green:25.f/255.f
                                            blue:31.f/255.f
                                           alpha:1.0];
    
    MSEvent *event = self.events[index];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectInset(view.bounds, 20, 20)];
    label.font = [UIFont fontWithName:@"Palatino-Bold" size:26.0];
    label.textColor = [UIColor colorWithRed:220.f/255.f
                                      green:214.f/255.f
                                       blue:219.f/255.f
                                      alpha:1.0];
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.4;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = event.title;
    [view addSubview:label];
    
    return view;
}

- (UIViewController *)viewControllerForDotAtIndex:(NSUInteger)index
{
    switch (index) {
        case 0:
            self.eventVC = [[MSTransistorViewController alloc] initWithNibName:@"MSTransistorView"
                                                                        bundle:nil];
            break;
        case 2:
            self.eventVC = [[MSEventsConnectorViewController alloc] init];
            break;
        case 4:
            self.eventVC = [[MSIPhoneEventViewController alloc]
                            initWithNibName:@"MSIPhoneEventViewController" bundle:nil];
            break;
        default:
            self.eventVC = nil;
            break;
    }

    return self.eventVC;
}

#pragma mark - <MSDotsPickerDelegate>

- (void)dotsPicker:(MSDotsPickerViewController *)dotsPicker didEndViewControllerTransition:(UIViewController *)vc
{

}

@end
