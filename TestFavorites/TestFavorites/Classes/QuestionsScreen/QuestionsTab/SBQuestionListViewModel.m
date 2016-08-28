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

//Extentions
#import "SBStackexchangeHTTPClient+SOExtention.h"

@interface SBQuestionListViewModel ()

@property (assign, nonatomic) SBQuestionType vmType;

@property (strong, nonatomic) NSArray <NSArray <SBQuestionCellItem *> *> *items;

@property (strong, nonatomic) NSNumberFormatter *countFormatter;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

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
	[self setupFormatters];


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
	@weakify(self);
	RACSignal *fetchAndGenerateItems = [[[[[[SBStackexchangeHTTPClient sharedClient] fetchSOQuestionsLastDays:1
																 order:SBRequestSortingOrderDesc
																  sort:SBRequestSortingActivity] doError:^(NSError *error) {
		NSLog(@"Error : %@", error);
	}] deliverOn:[RACScheduler scheduler]] map:^id(NSArray <SBQuestionModel *> *questions) {
		NSLog(@"Count %@", @(questions.count));
		return [self itemsFromQuestions:questions];
	}] deliverOn:[RACScheduler mainThreadScheduler]];

	return [fetchAndGenerateItems doNext:^(NSArray *items) {
		@strongify(self);
		self.items = items;
	}];
}

#pragma mark - Prepare Data

- (NSArray <SBQuestionCellItem *> *)itemsFromQuestions:(NSArray <SBQuestionModel *> *)questions {
	NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:questions.count];
	for (SBQuestionModel *question in questions) {
		SBQuestionCellItem *cellItem = [self cellItemFromQuestion:question];
		if (cellItem) {
			[resultArray addObject:cellItem];
		}
	}
	return @[[resultArray copy]];
}

- (SBQuestionCellItem *)cellItemFromQuestion:(SBQuestionModel *)question {
	SBQuestionCellItem *item = [SBQuestionCellItem new];
	item.ownerName = [NSString stringWithFormat:NSLocalizedString(@"owner : %@", nil), question.ownerDisplayName];
	item.viewCount = [NSString stringWithFormat:NSLocalizedString(@"Count: %@", nil), [self.countFormatter stringFromNumber:question.viewCount]];
	item.score = [NSString stringWithFormat:NSLocalizedString(@"Score: %@", nil), [self.countFormatter stringFromNumber:question.score]];
	item.lastDate = [self.dateFormatter stringFromDate:question.lastActivityDate];
	return item;
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
