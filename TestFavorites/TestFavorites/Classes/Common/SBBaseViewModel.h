//
//  SBBaseViewModel.h
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/23/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "RVMViewModel.h"

typedef NS_ENUM(NSInteger, SBViewModelState) {
	SBViewModelStateLoading,
	SBViewModelStateNormal,
	SBViewModelStateError,
	SBViewModelStateCustom,
};


@interface SBBaseViewModel : RVMViewModel  {
@protected
	RACCommand *_fetchDataCommand;
	RACSignal *_updatedContentSignal;
}

- (instancetype)initWithState:(SBViewModelState)state;

@property (strong, nonatomic, readonly) RACSignal *stateChangedSignal;
@property (strong, nonatomic, readonly) RACSignal *updatedContentSignal;

@property (copy, nonatomic) NSString *errorItem;

- (RACSignal *)fetchDataSignal;
- (RACCommand *)fetchDataCommand;


@end
