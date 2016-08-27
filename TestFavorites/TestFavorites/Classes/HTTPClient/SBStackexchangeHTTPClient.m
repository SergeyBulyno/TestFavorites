//
//  SBStackexchangeHTTPClient.m
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/26/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import "SBStackexchangeHTTPClient.h"

#import "SBHTTPClient.h"


@interface SBStackexchangeHTTPClient ()

@property (strong, nonatomic) SBHTTPClient *httpClient;

@property (strong, nonatomic) NSString *baseUrlString;
@property (strong, nonatomic) NSString *baseVersion;
@property (strong, nonatomic) NSString *baseUrlStringWithVersion;

@end

static NSString *const SBSEClientErrorDomain = @"SEClientErrorDomain";

@implementation SBStackexchangeHTTPClient

//TO DO: move to submodule or pods

+ (instancetype)sharedClient {
	static id sharedInstance = nil;
	static dispatch_once_t onceToken = 0;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		_httpClient = [SBHTTPClient new];
		_baseUrlString = @"https://api.stackexchange.com/";
		_baseVersion = @"2.2";
		_baseUrlStringWithVersion = [self urlWithVersionFromUrlString:_baseUrlString
															  version:_baseVersion];
	}
	return self;
}

- (NSString *)urlWithVersionFromUrlString:(NSString *)urlString
								  version:(NSString *)version {
	NSString *resultString = urlString;
	if (version.length > 0) {
		resultString = [NSString stringWithFormat:@"%@%@/", urlString , version];
	}
	return resultString;
}

- (NSError *)validateRequireNonilParameter:(id)parameter {
	if (!parameter) {
		return  [NSError errorWithDomain:SBSEClientErrorDomain
									code:998
								userInfo:nil];
	}
	return nil;
}

- (RACSignal *)fetchQuestionsForSite:(NSString *)site {
	return [self fetchQuestionsForSite:site
							  fromDate:nil
								toDate:nil
								 order:SBRequestSortingOrderUnknown
								  sort:SBRequestSortingUnknown];
}

- (RACSignal *)fetchQuestionsForSite:(NSString *)site
							fromDate:(NSDate *)fromDate
							  toDate:(NSDate *)toDate
							   order:(SBRequestSortingOrder)order
								sort:(SBRequestSorting)sort {
	NSParameterAssert(site);
	NSError *error = [self validateRequireNonilParameter:site];
	if (error) {
		return [RACSignal error:error];
	}
	NSMutableDictionary *parameters = [@{@"site": site} mutableCopy];
	if (fromDate) {
		parameters[@"fromdate"] = @((NSInteger)[fromDate timeIntervalSince1970]);
	}
	if (toDate) {
		parameters[@"todate"] = @((NSInteger)[toDate timeIntervalSince1970]);
	}
	if (order != SBRequestSortingOrderUnknown) {
		parameters[@"order"] = [self orderStringFromOrder:order];
	}
	if (sort != SBRequestSortingUnknown) {
		parameters[@"sort"] = [self sortStringFromSort:sort];
	}
	return [self.httpClient performRequestWithBaseURLString:self.baseUrlStringWithVersion
													 method:HTTPMethodGet
													   path:@"questions"
												 parameters:[parameters copy]
										   resultCollection:NSArray.class
												resultClass:SBQuestionModel.class
												  cacheTime:0];
}

- (NSString *)orderStringFromOrder:(SBRequestSortingOrder)order {
	NSString *orderString = @"";
	if (order == SBRequestSortingOrderAsc) {
		orderString = @"asc";
	} else if (order == SBRequestSortingOrderAsc) {
		orderString = @"desc";
	}
	return orderString;
}

- (NSString *)sortStringFromSort:(SBRequestSorting)sort {
	NSString *sortString;
	switch (sort) {
  case SBRequestSortingActivity:
			sortString = @"activity";
			break;
		case SBRequestSortingVotes:
			sortString = @"votes";
			break;
		case SBRequestSortingCreation:
			sortString = @"creation";
			break;
		case SBRequestSortingHot:
			sortString = @"hot";
			break;
		case SBRequestSortingWeak:
			sortString = @"weak";
			break;
		case SBRequestSortingMonth:
			sortString = @"month";
			break;
  default:
			sortString = @"";
			break;
	};
	return sortString;
}


@end
