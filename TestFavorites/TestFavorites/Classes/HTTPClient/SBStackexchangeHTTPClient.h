//
//  SBStackexchangeHTTPClient.h
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/26/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

typedef NS_ENUM(NSInteger, SBRequestSortingOrder) {
	SBRequestSortingOrderUnknown = 0,
	SBRequestSortingOrderAsc,
	SBRequestSortingOrderDesc,
};

typedef NS_ENUM(NSInteger, SBRequestSorting) {
	SBRequestSortingUnknown = 0,
	SBRequestSortingActivity,
	SBRequestSortingVotes,
	SBRequestSortingCreation,
	SBRequestSortingHot,
	SBRequestSortingWeak,
	SBRequestSortingMonth
};

@interface SBStackexchangeHTTPClient : NSObject


+ (instancetype)sharedClient;

- (RACSignal *)fetchQuestionsForSite:(NSString *)site;
- (RACSignal *)fetchQuestionsForSite:(NSString *)site
							fromDate:(NSDate *)fromDate
							  toDate:(NSDate *)toDate
							   order:(SBRequestSortingOrder)order
								sort:(SBRequestSorting)sort;

@end
