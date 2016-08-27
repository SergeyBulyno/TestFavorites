//
//  SBStackexchangeHTTPClient+SOExtention.h
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/26/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import "SBStackexchangeHTTPClient.h"

@interface SBStackexchangeHTTPClient (SOExtention)

- (RACSignal *)fetchSOQuestions;
- (RACSignal *)fetchSOQuestionsLastDays:(NSInteger)days;
- (RACSignal *)fetchSOQuestionsLastDays:(NSInteger)days
								  order:(SBRequestSortingOrder)order
								   sort:(SBRequestSorting)sort;
@end
