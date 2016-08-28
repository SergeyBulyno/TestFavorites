//
//  SBQuestionListViewModel.h
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/23/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBBaseViewModel.h"
#import "SBTableViewDataSource.h"

typedef NS_ENUM(NSInteger, SBQuestionType) {
	SBQuestionTypeFetched,
	SBQuestionTypeFavorite,
};

@interface SBQuestionListViewModel: SBBaseViewModel <SBTableViewDataSource>

- (id)init __attribute__((unavailable("Use initWithType: initializers instead.")));

- (instancetype)initWithType:(SBQuestionType)type;
- (void)updateData;

- (NSString *)tabbarTitle;
- (UIImage *)tabbarImage;
- (BOOL)refreshAvailable;

@end
