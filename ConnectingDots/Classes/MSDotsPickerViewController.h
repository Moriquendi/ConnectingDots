//
//  MSDotsPickerViewController.h
//  ConnectDots
//
//  Created by Apple on 8/12/13.
//  Copyright (c) 2013 Michal Smialko. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MSDotsPickerViewController;

@protocol MSDotsPickerDataSource <NSObject>

- (NSUInteger)dotsPickerItemsCount:(MSDotsPickerViewController *)dotsPicker;
- (UIView *)dotsPicker:(MSDotsPickerViewController *)dotsPicker
    viewForItemAtIndex:(NSUInteger)index;
- (UIViewController *)viewControllerForDotAtIndex:(NSUInteger)index;

@end

@protocol MSDotsPickerDelegate <NSObject>
@optional
- (void)dotsPicker:(MSDotsPickerViewController *)dotsPicker didEndViewControllerTransition:(UIViewController *)vc;
@end

@interface MSDotsPickerViewController : UIViewController

@property (nonatomic, weak) id <MSDotsPickerDataSource> dataSource;
@property (nonatomic, weak) id <MSDotsPickerDelegate> delegate;

@end
