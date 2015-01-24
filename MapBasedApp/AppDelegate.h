//
//  AppDelegate.h
//  Fyndher
//
//  Created by Laure Linn on 25/07/12.
//  Copyright (c) 2012 Mobile Analytics   All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebAPI.h"
@class RegistrationViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    NSTimer* bgLocationTimer;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RegistrationViewController *registrationVC;
@property (strong, nonatomic) WebAPI *webApi;

@end
