//
//  SBQuestionCellItem.h
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/24/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBQuestionCellItem : NSObject

@property (copy, nonatomic) NSString *ownerName;
@property (copy, nonatomic) NSString *viewCount;
@property (copy, nonatomic) NSString *score;
@property (copy, nonatomic) NSString *lastDate;

@end
