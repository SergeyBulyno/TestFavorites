//
//  WGFavoritesStorage.h
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/29/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WGFavoritesStorage : NSObject

+ (instancetype)sharedStorage;

- (NSDictionary *)favorites;
- (BOOL)containsID:(id)ID;
- (void)addItem:(id)item forID:(id)ID;
//- (void)addItems:(NSArray *)items forIDs:(NSArray *)IDs;
- (void)removeItemForID:(id)ID;
- (void)removeAllItems;

@end
