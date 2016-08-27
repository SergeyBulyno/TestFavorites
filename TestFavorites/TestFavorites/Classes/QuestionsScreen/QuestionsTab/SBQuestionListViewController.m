//
//  SBQuestionListViewController.m
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/23/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import "SBQuestionListViewController.h"
#import "SBQuestionListViewModel.h"

//Helpers
#import "SBVCHelper.h"
#import "Masonry.h"

//Views
#import "SBQuestionCell.h"

//Models
#import "SBQuestionCellItem.h"

//Protocols
#import "SBViewWithItem.h"

#import "SBStackexchangeHTTPClient+SOExtention.h"

@interface SBQuestionListViewController () <UITableViewDelegate,  UITableViewDataSource>

@property (strong, nonatomic) SBQuestionListViewModel *viewModel;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSNumberFormatter *countFormatter;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) NSArray *items;
@end

@implementation SBQuestionListViewController

#pragma mark - Controller Lifecycle

- (instancetype)initWithViewModel:(id)viewModel {
	self = [super init];
	if (self) {
		_viewModel = viewModel;
		[self setupTabbarItem];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setupSubviews];
	[self setupConstraints];
	[self setupFormatters];
	self.items = [self generateItems];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

#pragma mark -  Init Private Methods

- (void)setupTabbarItem {
	self.tabBarItem.image = self.viewModel.tabbarImage;
	self.tabBarItem.title = self.viewModel.tabbarTitle;
}

- (void)setupSubviews {
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_pattern"]];
	[self setupTableView];
	[self loadStackOwf];
}

- (void)setupTableView {
	_tableView = [[UITableView alloc] initWithFrame:self.view.bounds
													style:UITableViewStylePlain];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self registerTableViewCells];

	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self.view addSubview:self.tableView];

	self.tableView.allowsSelection = NO;
	self.tableView.backgroundColor = [UIColor clearColor];
	self.tableView.contentInset = [self tableViewContentInset];
}

- (void)loadStackOwf {
	[[[[SBStackexchangeHTTPClient sharedClient] fetchSOQuestionsLastDays:1
																  order:SBRequestSortingOrderDesc
																   sort:SBRequestSortingActivity] doError:^(NSError *error) {
		NSLog(@"%@", error);
	}]
	 subscribeNext:^(id x) {
		NSLog(@"Fetched:%@", x);
	}];
}

- (void)registerTableViewCells {
	Class celClass = SBQuestionCell.class;
	[self.tableView registerClass:celClass
		   forCellReuseIdentifier:NSStringFromClass(celClass)];
}

- (void)setupConstraints {
	[self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.bottom.right.equalTo(self.view);
		make.top.equalTo(self.view).with.offset([SBVCHelper statusBarOffset]);
	}];
}

- (void)setupFormatters {
	_countFormatter = [[NSNumberFormatter alloc] init];
	[_countFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

	_dateFormatter = [[NSDateFormatter alloc] init];
	[_dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[_dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[_dateFormatter setTimeStyle:NSDateFormatterShortStyle];
}

- (UIEdgeInsets)tableViewContentInset {
	return UIEdgeInsetsMake(0.0, 0.0, [SBVCHelper tabbarOffset], 0.0);
}

- (NSArray <SBQuestionCellItem *> *)generateItems {
	NSMutableArray *returnArray = [NSMutableArray array];
	for (NSInteger index = 0; index < 10; index++) {
		SBQuestionCellItem *item = [SBQuestionCellItem new];
		item.ownerName = [NSString stringWithFormat:@"owner : %@", @(index)];
		//		item.ownerName = [NSString stringWithFormat:@"owner dsadfdsfasdfasdfasldfhgalskjdhgflajksdhgflkasjhdflkjahslkdfjhalksdjfhlkasjhfdlkaj : %@", @(index)];
		item.viewCount = [NSString stringWithFormat:@"Count: %@", [self.countFormatter stringFromNumber:@(5 + index)]];
		item.score = [NSString stringWithFormat:@"Score: %@", [self.countFormatter stringFromNumber:@(25 + index)] ];
		item.lastDate = [self.dateFormatter stringFromDate:[NSDate date]];
		[returnArray addObject:item];
	}
	return [returnArray copy];
}

#pragma mark - <UITableViewDelegate>

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell <SBViewWithItem> *cell =
	[tableView dequeueReusableCellWithIdentifier:NSStringFromClass(SBQuestionCell.class)
									forIndexPath:indexPath];
	[cell setItem:self.items[indexPath.row]];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50.0;
}

#pragma marl - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.items.count;
}



@end
