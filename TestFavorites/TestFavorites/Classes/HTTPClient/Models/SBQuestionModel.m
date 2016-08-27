//
//  SBQuestionModel.m
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/27/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import "SBQuestionModel.h"

@implementation SBQuestionModel
#pragma mark - MTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{@"ownerDisplayName": @"owner.display_name",
			 @"viewCount": @"view_count",
			 @"score": @"score",
			 @"lastActivityDate": @"last_activity_date"
			 };
}

+ (NSValueTransformer *)lastActivityDateJSONTransformer {
	return [MTLValueTransformer transformerUsingForwardBlock:^id(NSNumber *UTCTimeStampValue, BOOL *success, NSError *__autoreleasing *error) {
		return [UTCTimeStampValue integerValue] != 0 ? [NSDate dateWithTimeIntervalSince1970:[UTCTimeStampValue integerValue]] : nil;
	}];
}

@end
