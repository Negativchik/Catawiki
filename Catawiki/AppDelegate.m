//
//  AppDelegate.m
//  Catawiki
//
//  Created by Michael Smirnov on 25.06.16.
//  Copyright © 2016 Smirnov. All rights reserved.
//

#import "AppDelegate.h"
#import "Constants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	if (![[NSUserDefaults standardUserDefaults] objectForKey:kSearchStringKey]) {
		[[NSUserDefaults standardUserDefaults] setObject:@"catawiki" forKey:kSearchStringKey];
	}

	return YES;
}

@end
