//
//  SBTableViewDataSource.h
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/28/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

@protocol SBTableViewDataSource <NSObject>

- (NSInteger)numberOfItemsInSection:(NSInteger)section;
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@optional

- (NSInteger)numberOfSections;

@end

