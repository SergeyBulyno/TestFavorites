//
//  SBHTTPClient.m
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/25/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import "SBHTTPClient.h"

#import "AFNetworking.h"

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

//Externs
NSString *const HTTPMethodGet = @"GET";
NSString *const HTTPMethodPost = @"POST";

//COnstants
static NSString *const SBClientErrorDomain = @"ClientErrorDomain";

static NSString *const kCachePath = @"SBClientCache";
static const NSInteger kInMemoryCacheSize = 4 * 1024 * 1024;
static const NSInteger kOnDiskCacheSize = 100 * 1024 * 1024;
static const NSTimeInterval kCacheInterval = 2 * 60;

static const NSInteger SBClientErrorJSONParsingFailed = 900;
static const NSInteger SBClientErrorInvalidRequest = 901;


@interface SBHTTPClient ()

@property (strong, nonatomic) AFURLSessionManager *manager;

@end

@implementation SBHTTPClient

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
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
		configuration.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
		_manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
		[_manager.operationQueue setMaxConcurrentOperationCount:10];
		[self setupUrlCache];

	}
	return self;
}

- (void)setupUrlCache {
	NSURLCache *urlCache = [[NSURLCache alloc] initWithMemoryCapacity:kInMemoryCacheSize
														 diskCapacity:kOnDiskCacheSize
															 diskPath:kCachePath];
	[NSURLCache setSharedURLCache:urlCache];

}

#pragma mark - Perform Requests


- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
								 URLString:(NSString *)URLString
								parameters:(NSDictionary *)parameters {
	NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:method
																				 URLString:URLString
																				parameters:parameters
																					 error:nil];
	return request;
}

- (NSMutableURLRequest *)requestWithBaseUrlString:(NSString *)baseURLString
										   method:(NSString *)method
									   path:(NSString *)path
									   parameters:(NSDictionary *)parameters {
	if (![path hasSuffix:@"/"]) {
		path = [path stringByAppendingString:@"/"];
	}
	NSString *urlString = [baseURLString stringByAppendingString:path];
	return [self requestWithMethod:method
						 URLString:urlString
						parameters:parameters];
}

- (RACSignal *)performRequestWithBaseURLString:(NSString *)urlString
								  method:(NSString *)method
										  path:(NSString *)path
							  parameters:(NSDictionary *)parameters {
	return [self performRequestWithBaseURLString:urlString
										  method:method
											path:path
									  parameters:parameters
									   cacheTime:kCacheInterval];
}

- (RACSignal *)performRequestWithBaseURLString:(NSString *)urlString
								  method:(NSString *)method
										  path:(NSString *)path
							  parameters:(NSDictionary *)parameters
							   cacheTime:(NSTimeInterval)expirationTime {
	NSMutableURLRequest *request = [self requestWithBaseUrlString:urlString
														   method:method
													   path:path
													   parameters:parameters];

	return [self performRequest:[request copy]
					  cacheTime:expirationTime];
}

- (RACSignal *)performRequestWithBaseURLString:(NSString *)urlString
										method:(NSString *)method
										  path:(NSString *)path
									parameters:(NSDictionary *)parameters
							  resultCollection:(Class)collectionClass
								   resultClass:(Class)resultClass {
	return [self performRequestWithBaseURLString:urlString
										  method:method
											path:path
									  parameters:parameters
								resultCollection:collectionClass
									 resultClass:resultClass
									   cacheTime:kCacheInterval];
}

- (RACSignal *)performRequestWithBaseURLString:(NSString *)urlString
										method:(NSString *)method
										  path:(NSString *)path
									parameters:(NSDictionary *)parameters
							  resultCollection:(Class)collectionClass
								   resultClass:(Class)resultClass
							   cacheTime:(NSTimeInterval)expirationTime {

	return [[[[self performRequestWithBaseURLString:urlString
											 method:method
											   path:path
										 parameters:parameters
										  cacheTime:expirationTime]
			  deliverOn:[RACScheduler scheduler]] flattenMap:^RACStream *(id response) {
		if (resultClass != nil && [response isKindOfClass:NSDictionary.class]) {
			return [self parsedResponseOfCollectionClass:collectionClass
											 resultClass:resultClass
												fromJSON:((NSDictionary *)response)[@"items"]];
		}
		return [RACSignal return:response];
	}] deliverOn:RACScheduler.mainThreadScheduler];
}

- (RACSignal *)performRequest:(NSURLRequest *)request
					cacheTime:(NSTimeInterval)expirationTime {
	if (!request) {
		return [RACSignal error:[NSError errorWithDomain:SBClientErrorDomain
													code:SBClientErrorInvalidRequest
												userInfo:nil]];
	}

	RACSignal *fetchRequestSignal = [RACSignal createSignal:^(id<RACSubscriber> subscriber) {
		NSURLSessionDataTask *dataTask =
		[self.manager dataTaskWithRequest:request
						completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
							NSDictionary *errorDictionary = responseObject[@"error_id"];
							if (error || errorDictionary) {
								if (errorDictionary){
									NSString *errorDescription = [NSString stringWithFormat:@"%@: %@",
																  errorDictionary[@"error_name"],
																  errorDictionary[@"error_message"]];
									error = [NSError errorWithDomain:SBClientErrorDomain
																code:[errorDictionary[@"error_id"] integerValue]
															userInfo:@{NSLocalizedDescriptionKey:errorDescription}];
								}
								if (error.domain != NSURLErrorDomain && error.code == NSURLErrorCancelled) {
									[subscriber sendError:error];
								} else {
									[subscriber sendCompleted];
								}
							} else {
								[subscriber sendNext:responseObject];
								[subscriber sendCompleted];
							}

						}];
		[dataTask resume];
		return [RACDisposable disposableWithBlock:^{
			[dataTask cancel];
		}];
	}];
	return [[fetchRequestSignal publish] autoconnect] ;
}

#pragma mark - Parsing

- (RACSignal *)parsedResponseOfCollectionClass:(Class)collectionClass
								   resultClass:(Class)resultClass
									  fromJSON:(id)JSON {
	if (resultClass) {
		BOOL isResultSubclussOfMTL = [resultClass isSubclassOfClass:MTLModel.class];
		NSParameterAssert(isResultSubclussOfMTL);
		if (!isResultSubclussOfMTL) {
			return [RACSignal return:JSON];
		}
	}

	return [RACSignal createSignal:^ id (id<RACSubscriber> subscriber) {
		id (^parseJSONDictionary)(NSDictionary *) = ^ id (NSDictionary *JSONDictionary) {
			if ([JSONDictionary isKindOfClass:[NSNull class]]  || !JSONDictionary.count) {
				return nil;
			}
			NSError *error = nil;
			MTLModel *parsedObject = [MTLJSONAdapter modelOfClass:resultClass
											   fromJSONDictionary:JSONDictionary
															error:&error];
			if (parsedObject == nil && error) {
				[subscriber sendError:error];
			}

			NSAssert([parsedObject isKindOfClass:MTLModel.class], @"Parsed model object is not an MTLModel: %@", parsedObject);
			return parsedObject ?: nil;
		};

		id (^iterateArray)(NSArray *) = ^ id (NSArray *JSONArray) {
			NSMutableArray *array = [NSMutableArray array];

			for (NSDictionary *JSONDictionary in JSONArray) {
				if (![JSONDictionary isKindOfClass:NSDictionary.class]) {
					NSString *failureReason = [NSString stringWithFormat:@"Invalid JSON array element: %@", JSONDictionary];
					[subscriber sendError:[self parsingErrorWithFailureReason:failureReason]];
				}
				id parsedObject = parseJSONDictionary(JSONDictionary);
				if (parsedObject) [array addObject:parsedObject];
			}
			return array.copy;
		};

		if (collectionClass == NSArray.class) {
			if ([JSON isKindOfClass:NSArray.class]) {
				[subscriber sendNext:iterateArray(JSON)];
				[subscriber sendCompleted];
			} else {
				NSString *failureReason = [NSString stringWithFormat:@"Expected array element, received: %@", JSON];
				[subscriber sendError:[self parsingErrorWithFailureReason:failureReason]];
			}
		}
		return nil;
	}];
}

- (NSError *)parsingErrorWithFailureReason:(NSString *)failurereason {
	NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
	userInfo[NSLocalizedDescriptionKey] = @"Could not parse the service response.";

	if (failurereason != nil) {
		userInfo[NSLocalizedFailureReasonErrorKey] = failurereason;
	}

	return [NSError errorWithDomain:SBClientErrorDomain
							   code:SBClientErrorJSONParsingFailed
						   userInfo:userInfo];
}


@end
