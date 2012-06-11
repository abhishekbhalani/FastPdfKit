//
//  MagAppDelegate.h
//  MagTestApp
//
//  Created by Nicolò Tosi on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MagViewController;

@interface MagAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController * navigationController;
@property (strong, nonatomic) MagViewController * mainViewController;

@end
