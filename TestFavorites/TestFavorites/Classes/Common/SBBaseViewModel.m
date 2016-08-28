//
//  SBBaseViewModel.m
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/23/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import "SBBaseViewModel.h"

@interface SBBaseViewModel ()

@property (assign, nonatomic, readwrite) SBViewModelState state;

@property (strong, nonatomic, readwrite) RACSignal *errorSignal;
@property (strong, nonatomic, readwrite) RACSignal *completedSignal;
@property (strong, nonatomic, readwrite) RACSignal *loadingSignal;

@end

@implementation SBBaseViewModel

- (instancetype)initWithState:(SBViewModelState)state {
	if (self = [super init]) {
		_state = state;
		RAC(self, state) = [RACSignal merge:@[self.loadingSignal, self.completedSignal, self.errorSignal]];
		_stateChangedSignal = [RACObserve(self, state) distinctUntilChanged];
	}
	return self;
}

- (instancetype)init {
	return [self initWithState:SBViewModelStateLoading];
}

// В нормальном проекте нужна реализация SBViewModelStateCustom

- (RACSignal *)loadingSignal {
	if (!_loadingSignal) {
		_loadingSignal = [self.fetchDataCommand.executionSignals map:^id(RACSignal *subscribeSignal) {
			return  @(SBViewModelStateLoading);
		}];
	}
	return _loadingSignal;
}

- (RACSignal *)completedSignal {
	if (!_completedSignal) {
		_completedSignal = [self.fetchDataCommand.executionSignals flattenMap:^RACStream *(RACSignal *subscribeSignal) {
			return [[[subscribeSignal materialize] filter:^BOOL(RACEvent *event) {
				return event.eventType == RACEventTypeNext;
			}] map:^id(id _) {
				return @(SBViewModelStateNormal);
			}];
		}];
	}
	return _completedSignal;
}

- (RACSignal *)errorSignal {
	if (!_errorSignal) {
		_errorSignal = [self.fetchDataCommand.errors map:^id(NSError *error) {
			return @(SBViewModelStateError);
		}];
	}
	return _errorSignal;
}

- (RACCommand *)fetchDataCommand {
	if (!_fetchDataCommand) {
		@weakify(self);
		_fetchDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id _) {
			@strongify(self);
			return self.fetchDataSignal;
		}];
	}
	return _fetchDataCommand;
}

#pragma mark - Abstract

- (RACSignal *)fetchDataSignal {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}


@end
