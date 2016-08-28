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


@interface SBQuestionListViewController () <UITableViewDelegate,  UITableViewDataSource>

@property (strong, nonatomic) SBQuestionListViewModel *viewModel;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSArray *otherRightNavBarItems;

@end

@implementation SBQuestionListViewController

@dynamic viewModel;
#pragma mark - Controller Lifecycle

- (instancetype)initWithViewModel:(id)viewModel {
	self = [super initWithViewModel:viewModel];
	if (self) {
		[self setupTabbarItem];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self setupSubviews];
	[self setupConstraints];
	[self setupObservers];
	if ([self.viewModel refreshAvailable]) {
		[self setupEditButtonsObserver];
	}
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
}

- (void)setupEditButtonsObserver {
	@weakify(self);
	[[self rac_signalForSelector:@selector(viewWillAppear:)] subscribeNext:^(id _) {
		@strongify(self);
		UIBarButtonItem *button = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
								   target:self
								   action:@selector(refresh:)];

		self.otherRightNavBarItems = self.tabBarController.navigationItem.rightBarButtonItems;
		self.tabBarController.navigationItem.rightBarButtonItems = [@[button]arrayByAddingObjectsFromArray:self.otherRightNavBarItems];
	}];

	[[self rac_signalForSelector:@selector(viewWillDisappear:)] subscribeNext:^(id _) {
		@strongify(self);
		self.tabBarController.navigationItem.rightBarButtonItems = self.otherRightNavBarItems;
	}];
}

- (void)refresh:(UIButton *)refreshButton {
	[self.viewModel updateData];
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

- (void)setupObservers {
	@weakify(self);
	[self.viewModel.updatedContentSignal subscribeNext:^(id x) {
		@strongify(self);
		[self.tableView reloadData];
	}];
}

- (UIEdgeInsets)tableViewContentInset {
	return UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height,
							0.0,
							[SBVCHelper tabbarOffset],
							0.0);
}

#pragma mark - <UITableViewDelegate>

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell <SBViewWithItem> *cell =
	[tableView dequeueReusableCellWithIdentifier:NSStringFromClass(SBQuestionCell.class)
									forIndexPath:indexPath];

	[cell setItem:[self.viewModel itemAtIndexPath:indexPath]];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50.0;
}

#pragma marl - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.viewModel numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.viewModel numberOfItemsInSection:section];
}



@end
