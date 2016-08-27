//
//  SBHTTPClient.h
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/25/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>

extern NSString *const HTTPMethodGet;
extern NSString *const HTTPMethodPost;

@interface SBHTTPClient : NSObject

+ (instancetype)sharedClient;
- (RACSignal *)performRequestWithBaseURLString:(NSString *)urlString
										method:(NSString *)method
										  path:(NSString *)path
									parameters:(NSDictionary *)parameters
							  resultCollection:(Class)collection
								   resultClass:(Class)resultClass;

- (RACSignal *)performRequestWithBaseURLString:(NSString *)urlString
										method:(NSString *)method
										  path:(NSString *)path
									parameters:(NSDictionary *)parameters
							  resultCollection:(Class)collection
								   resultClass:(Class)resultClass
									 cacheTime:(NSTimeInterval)expirationTime;


@end
