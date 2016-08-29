//
//  WGFavoritesStorage.m
//  TestFavorites
//
//  Created by Sergey Bulyno on 8/29/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import "WGFavoritesStorage.h"

@interface WGFavoritesStorage ()
@property (copy, nonatomic, readwrite) NSMutableDictionary <NSString *, id> *favoriteItems;
@property (copy, nonatomic) NSString *filePathName;

@end

@implementation WGFavoritesStorage

//Нужно заменить реализацию на Core data

+ (instancetype)sharedStorage {
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
		_filePathName = [self favoritesPath];
		if (!(_favoriteItems = [NSKeyedUnarchiver unarchiveObjectWithFile:self.filePathName])) {
			_favoriteItems = [NSMutableDictionary dictionary];
		}
	}
	return self;
}

- (NSString *)favoritesPath {
	NSString *fileName = @"favorite_questions";
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	path = [path stringByAppendingPathComponent:fileName];
	return path;
}

#pragma mark - Public Methods

- (BOOL)containsID:(id)ID {
	return [self.favoriteItems.allKeys containsObject:ID];
}

- (void)addItem:(id)item forID:(id)ID {
	self.favoriteItems[ID] =  item;
	[self archiveFavorites];
}

- (void)removeItemForID:(id)ID {
	[self.favoriteItems removeObjectForKey:ID];
	[self archiveFavorites];
}

- (void)removeAllItems {
	[self.favoriteItems removeAllObjects];
	[self archiveFavorites];
}

- (void)archiveFavorites {
	[NSKeyedArchiver archiveRootObject:self.favoriteItems
								toFile:self.filePathName];
}

- (NSDictionary *)favorites {
	return [self.favoriteItems copy];
}
@end
