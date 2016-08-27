//
//  SBStackexchangeHTTPClient+SOExtention.m
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/26/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import "SBStackexchangeHTTPClient+SOExtention.h"

static const NSTimeInterval kDayInterval = 24 * 60 * 60;

@implementation SBStackexchangeHTTPClient (SOExtention)

- (RACSignal *)fetchSOQuestions {
	return [self fetchSOQuestionsLastDays:1];
}

- (RACSignal *)fetchSOQuestionsLastDays:(NSInteger)days {
	return [self fetchSOQuestionsLastDays:days
									order:SBRequestSortingOrderUnknown
									 sort:SBRequestSortingUnknown];
}

- (RACSignal *)fetchSOQuestionsLastDays:(NSInteger)days
								  order:(SBRequestSortingOrder)order
								   sort:(SBRequestSorting)sort {
	NSDate *fromDate;
	NSDate *toDate;
	if (days > 0) {
		toDate = [NSDate date];
		fromDate = [toDate dateByAddingTimeInterval:- kDayInterval * days];
	}

	return [self fetchQuestionsForSite:@"stackoverflow"
							  fromDate:fromDate
								toDate:toDate
								 order:order
								  sort:sort];
}


@end
