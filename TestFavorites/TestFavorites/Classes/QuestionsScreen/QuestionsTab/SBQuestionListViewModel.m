//
//  SBQuestionListViewModel.m
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/23/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import "SBQuestionListViewModel.h"

//Models
#import "SBQuestionCellItem.h"

//Helpers
#import "ObjectiveSugar.h"

#import "WGFavoritesStorage.h"

//Extentions
#import "SBStackexchangeHTTPClient+SOExtention.h"

@interface SBQuestionListViewModel ()

@property (assign, nonatomic) SBQuestionType vmType;

@property (strong, nonatomic) NSArray <NSArray <SBQuestionCellItem *> *> *items;
@property (strong, nonatomic) NSDictionary <NSNumber *, SBQuestionModel *> *questions;

@property (strong, nonatomic) NSNumberFormatter *countFormatter;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) WGFavoritesStorage *favoritesStorage;
@end

@implementation SBQuestionListViewModel

- (instancetype)initWithType:(SBQuestionType)type {
	self = [super init];
	if (self) {
		_vmType = type;
		[self setupDefault];
	}
	return self;
}

- (void)updateData {
	self.items = nil;
}

#pragma mark - Default Setup

- (void)setupDefault {
	self.favoritesStorage = [WGFavoritesStorage sharedStorage];
	[self setupFormatters];
	[self setupObservers];
}

- (void)setupObservers {
	@weakify(self);
	RACSignal *launchExecutingSignal = [RACSignal merge:@[self.didBecomeActiveSignal, [self rac_signalForSelector:@selector(updateData)]]];

	[launchExecutingSignal subscribeNext:^(id _) {
		@strongify(self);
		[self.fetchDataCommand execute:nil];
	}];

	_updatedContentSignal = [RACObserve(self, items) skip:1];
}

- (void)setupFormatters {
	_countFormatter = [[NSNumberFormatter alloc] init];
	[_countFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

	_dateFormatter = [[NSDateFormatter alloc] init];
	[_dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[_dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
}

#pragma mark - Controller Customizing

- (NSString *)tabbarTitle {
	NSString *returnTitle;
	if (self.vmType == SBQuestionTypeFetched) {
		returnTitle = NSLocalizedString(@"Questions", nil);
	} else {
		returnTitle = NSLocalizedString(@"Favorites", nil);
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

- (BOOL)refreshAvailable {
	return self.vmType == SBQuestionTypeFetched;
}

#pragma mark - Subclassing

- (RACSignal *)fetchDataSignal {
	RACSignal *fetchQuestionItems;
	if (self.vmType == SBQuestionTypeFetched) {
		fetchQuestionItems = [[[SBStackexchangeHTTPClient sharedClient] fetchSOQuestionsLastDays:1
																						   order:SBRequestSortingOrderDesc
																							sort:SBRequestSortingActivity] doError:^(NSError *error) {
			NSLog(@"Error : %@", error);
		}];
	} else {
		fetchQuestionItems = [RACSignal return:[self.favoritesStorage.favorites allValues]];
	}

	@weakify(self);
	RACSignal *fetchAndGenerateItems = [[[fetchQuestionItems deliverOn:[RACScheduler scheduler]] map:^id(NSArray <SBQuestionModel *> *questions) {
		return [self itemsFromQuestions:questions];
	}] deliverOn:[RACScheduler mainThreadScheduler]];

	return [fetchAndGenerateItems doNext:^(RACTuple *data) {
		@strongify(self);
		self.items = data.second;
		self.questions = data.first;
	}];

}

#pragma mark - Prepare Data

- (RACTuple *)itemsFromQuestions:(NSArray <SBQuestionModel *> *)questions {
	NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:questions.count];
	NSMutableDictionary *questionsDictionary = [NSMutableDictionary dictionaryWithCapacity:questions.count];
	for (SBQuestionModel *question in questions) {
		if ([self shouldDisplayQuestion:question]) {
			SBQuestionCellItem *cellItem = [self cellItemFromQuestion:question];
			if (cellItem) {
				[resultArray addObject:cellItem];
			}
			questionsDictionary[question.questionID] = question;
		}
	}
	return RACTuplePack([questionsDictionary copy], @[[resultArray copy]]);
}

- (BOOL)shouldDisplayQuestion:(SBQuestionModel *)model {
	if (self.vmType == SBQuestionTypeFetched) {
		return ![self.favoritesStorage containsID:model.questionID];
	} else if(self.vmType == SBQuestionTypeFavorite) {
		return [self.favoritesStorage containsID:model.questionID];
	}
	return NO;
}


- (SBQuestionCellItem *)cellItemFromQuestion:(SBQuestionModel *)question {
	SBQuestionCellItem *item = [SBQuestionCellItem new];
	item.ownerName = [NSString stringWithFormat:NSLocalizedString(@"owner : %@", nil), question.ownerDisplayName];
	item.viewCount = [NSString stringWithFormat:NSLocalizedString(@"Count: %@", nil), [self.countFormatter stringFromNumber:question.viewCount]];
	item.score = [NSString stringWithFormat:NSLocalizedString(@"Score: %@", nil), [self.countFormatter stringFromNumber:question.score]];
	item.lastDate = [self.dateFormatter stringFromDate:question.lastActivityDate];
	item.questionID = question.questionID;
	item.inFavorites = [self.favoritesStorage containsID:question.questionID];
	[[RACObserve(item, inFavorites) skip:1] subscribeNext:^(id x) {
		[self changeFavoritesStateForItem:item];
	}];
	return item;
}

#pragma mark - Change Favorites

- (void)changeFavoritesStateForItem:(SBQuestionCellItem *)questionItem {
	SBQuestionModel *questionModel = self.questions[questionItem.questionID];
	if (questionModel) {
		if ([self shouldDisplayQuestion:questionModel]) {
			[self excludeItem:questionItem];
		}
		if (questionItem.inFavorites) {
			[self.favoritesStorage addItem:questionModel
									 forID:questionModel.questionID];
		} else {
			[self.favoritesStorage removeItemForID:questionModel.questionID];
		}
	}
}

//можно сделать анимированное удаление
- (void)excludeItem:(SBQuestionCellItem *)questionItem {
	@weakify(self);
	[[[[[RACSignal return:[self.items copy]] deliverOn:[RACScheduler scheduler]] map:^id( NSArray <NSArray <SBQuestionCellItem *> *> *sectionItems) {
		NSMutableArray *filtredSectionItems = [NSMutableArray array];
		for (NSArray <SBQuestionCellItem *> *items in sectionItems) {
			NSMutableArray *resultItems = [items mutableCopy];
			[resultItems removeObject:questionItem];
			if (resultItems.count > 0) {
				[filtredSectionItems addObject:[resultItems copy]];
			}
		}
		return filtredSectionItems;
	}]
	  deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray <NSArray <SBQuestionCellItem *> *> *items) {
		@strongify(self);
		self.items = items;
	}];
}

#pragma mark - <SBTableViewDataSource>

- (NSInteger)numberOfSections {
	return self.items.count;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
	if (section < self.items.count) {
		return [self.items[section] count];
	}
	return 0;
}

- (SBQuestionCellItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section < self.items.count) {
		NSArray *items = self.items[indexPath.section];
		if (indexPath.row < items.count) {
			return items[indexPath.row];
		}
	}
	return nil;
}

@end
