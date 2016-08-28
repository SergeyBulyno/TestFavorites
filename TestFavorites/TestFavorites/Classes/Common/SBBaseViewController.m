//
//  SBBaseViewController.m
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/23/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import "SBBaseViewController.h"

//View Models
#import "SBBaseViewModel.h"

//Helpers
#import "Masonry.h"


@interface SBBaseViewController ()

@property (strong, nonatomic, readwrite) UIActivityIndicatorView *activityIndicator;

@end

@implementation SBBaseViewController

- (instancetype)initWithViewModel:(SBBaseViewModel *)viewModel {
	return [self initWithViewModel:viewModel nibName:nil bundle:nil];
}

- (instancetype)initWithViewModel:(SBBaseViewModel *)viewModel
						  nibName:(NSString *)nibName
						   bundle:(NSBundle *)bundle {
	if (self = [super initWithNibName:nibName bundle:bundle]) {
		_viewModel = viewModel;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.viewModel.active = YES;
	RAC(self, viewModel.active) = [self activeSignal];
	[self setupBaseSubviews];
	[self setupBaseObservers];
}

#pragma mark - Initialization Private Methods

- (RACSignal *)activeSignal {
	RACSignal *presented = [RACSignal merge:@[[[self rac_signalForSelector:@selector(viewWillAppear:)] mapReplace:@YES],
											   [[self rac_signalForSelector:@selector(viewWillDisappear:)] mapReplace:@NO]]];
	return presented;
}

- (void)setupBaseObservers {
	NSParameterAssert(self.viewModel);
	@weakify(self);
	[[self rac_signalForSelector:@selector(viewWillAppear:)] subscribeNext:^(id _) {
		@strongify(self);
		if (!self.activityIndicator.hidden) {
			[self.activityIndicator startAnimating];
		}
	}];
	[[self rac_signalForSelector:@selector(viewWillDisappear:)] subscribeNext:^(id _) {
		@strongify(self);
		[self.activityIndicator stopAnimating];
	}];

	[self.viewModel.stateChangedSignal subscribeNext:^(NSNumber *modelState) {
		@strongify(self);
		NSUInteger state = [modelState integerValue];
		switch (state) {
			case SBViewModelStateLoading:
				self.errorView.hidden = YES;
				[self subviewsHidden:YES];
				self.activityIndicator.hidden = NO;
				[self.activityIndicator startAnimating];
				break;
			case SBViewModelStateNormal:
				self.errorView.hidden = YES;
				[self subviewsHidden:NO];
				self.activityIndicator.hidden = YES;
				[self.activityIndicator stopAnimating];
				break;
			case SBViewModelStateError:
				self.errorView.hidden = NO;
				[self subviewsHidden:YES];
				self.activityIndicator.hidden = YES;
				[self.activityIndicator stopAnimating];
				break;
		}
	}];
}

- (void)setupBaseSubviews {
	[self setupErrorView];
	self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	self.activityIndicator.center = self.view.center;
	[self.view addSubview:self.activityIndicator];
	[self.activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];
	self.activityIndicator.hidden = YES;
}

- (void)setupErrorView {
	UILabel *errorViewLabel = [UILabel new];
	errorViewLabel.font = [UIFont boldSystemFontOfSize:16];
	errorViewLabel.textColor = [UIColor blackColor];

	_errorView = errorViewLabel;
	self.errorView.hidden = YES;
	[self.view addSubview:self.errorView];
#warning make correct edges don't overlay navbar and tabbar
	[self.errorView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(self.view);
	}];
}

#pragma mark - Override Methods

- (void)subviewsHidden:(BOOL)hidden {
	// do nothing by default
}

@end
