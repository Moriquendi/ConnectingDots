//
//  MSDotsPickerViewController.h
//  ConnectDots
//
//  Created by Apple on 8/12/13.
//  Copyright (c) 2013 Michal Smialko. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MSDotsPicketDataSource <NSObject>

- (NSUInteger)itemsCount;
- (UIView *)viewForItemAtIndex:(NSUInteger)index;

@end

@interface MSDotsPickerViewController : UIViewController

@property (nonatomic, weak) id <MSDotsPicketDataSource> dataSource;

@end
