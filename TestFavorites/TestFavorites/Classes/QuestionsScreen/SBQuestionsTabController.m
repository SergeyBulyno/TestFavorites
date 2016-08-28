//
//  SBQuestionsTabController.m
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/23/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import "SBQuestionsTabController.h"

#import "SBQuestionListViewController.h"
#import "SBQuestionListViewModel.h"

@interface SBQuestionsTabController ()

@end

@implementation SBQuestionsTabController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationItem.title = NSLocalizedString(@"Questions", nil);
	if (self.viewControllers.count == 0) {
		SBQuestionListViewModel *questionsVM = [[SBQuestionListViewModel alloc] initWithType:SBQuestionTypeFetched];
		SBQuestionListViewController *questionsVC = [[SBQuestionListViewController alloc] initWithViewModel:questionsVM];
		SBQuestionListViewModel *fquestionsVM = [[SBQuestionListViewModel alloc] initWithType:SBQuestionTypeFavorite];
		SBQuestionListViewController *fquestionsVC = [[SBQuestionListViewController alloc] initWithViewModel:fquestionsVM];
		self.viewControllers = @[questionsVC, fquestionsVC];
	}
}

@end
