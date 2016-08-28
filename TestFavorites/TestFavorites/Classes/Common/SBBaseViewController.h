//
//  SBBaseViewController.h
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/23/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBBaseViewModel;

@interface SBBaseViewController : UIViewController

@property (strong, nonatomic, readonly) UILabel *errorView;
@property (strong, nonatomic, readonly) SBBaseViewModel *viewModel;

- (instancetype)initWithViewModel:(SBBaseViewModel *)viewModel;
- (instancetype)initWithViewModel:(SBBaseViewModel *)viewModel
						  nibName:(NSString *)nibName
						   bundle:(NSBundle *)bundle;

@end
