//
//  SBQuestionModel.h
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/27/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import <ReactiveCocoa/RACEXTKeyPathCoding.h>

@interface SBQuestionModel : MTLModel <MTLJSONSerializing>

//В реальном проекте стоило бы создать отдельный объект для owner;
//и парсить полный объект.
@property (strong, nonatomic) NSNumber *questionID;
@property (copy, nonatomic) NSString *ownerDisplayName;
@property (strong, nonatomic) NSNumber *viewCount;
@property (strong, nonatomic) NSNumber *score;
@property (strong, nonatomic) NSDate *lastActivityDate;

@end
