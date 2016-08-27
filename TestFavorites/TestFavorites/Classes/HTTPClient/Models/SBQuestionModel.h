//
//  SBQuestionModel.h
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/27/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import "RACEXTKeyPathCoding.h"

@interface SBQuestionModel : MTLModel <MTLJSONSerializing>

//В реальном проекте стоило бы создать отдельный объект для owner;
//и парсить полный объект.
@property (copy, nonatomic) NSString *ownerDisplayName;
@property (copy, nonatomic) NSNumber *viewCount;
@property (assign, nonatomic) NSNumber *score;
@property (assign, nonatomic) NSDate *lastActivityDate;

@end
