//
//  SBVCHelper.m
//  TestFavorites
//
//  Created by Sergey on 8/24/16.
//  Copyright © 2016 Sergey Bulyno. All rights reserved.
//

#import "SBVCHelper.h"

@implementation SBVCHelper

+ (CGFloat)statusBarOffset {
	CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
	return MIN(statusBarSize.width, statusBarSize.height);
}

+ (CGFloat)tabbarOffset {
	UITabBarController *tabBarController = [UITabBarController new];
	return tabBarController.tabBar.frame.size.height;
}


@end
