//
//  SBQuestionListViewModel.m
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/23/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import "SBQuestionListViewModel.h"

@interface SBQuestionListViewModel ()

@property (assign, nonatomic) SBQuestionType vmType;

@end

@implementation SBQuestionListViewModel
- (instancetype)initWithType:(SBQuestionType)type {
	self = [super init];
	if (self) {
		_vmType = type;
	}
	return self;
}

- (NSString *)tabbarTitle {
	NSString *returnTitle;
	if (self.vmType == SBQuestionTypeFetched) {
		returnTitle = @"Questions";
	} else {
		returnTitle = @"Favorites";
	}

	return returnTitle;
}

- (UIImage *)tabbarImage {
	NSString *returnImageName;
	if (self.vmType == SBQuestionTypeFetched) {
		returnImageName = @"list";
	} else {
		returnImageName = @"star";
	}
	return [UIImage imageNamed:returnImageName];
}

@end
