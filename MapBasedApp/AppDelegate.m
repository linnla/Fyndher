//
//  AppDelegate.m
//  Fyndher
//
//  Created by Laure Linn on 25/07/12.
//  Copyright (c) 2012 Mobile Analytics   All rights reserved.
//

#import "AppDelegate.h"
#import "RegistrationViewController.h"
#import "BannerViewController.h"

@implementation AppDelegate
{
    BannerViewController *_bannerViewController;
}

@synthesize window = _window;
@synthesize registrationVC = _registrationVC;
@synthesize webApi;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSLog(@">>>>didFinishLaunchingWithOptions method>>>");
    
    [TestFlight takeOff:@"c1a4eac1-9916-42b0-9601-4400196ea613"];
    
    self.registrationVC = [[RegistrationViewController new] initWithNibName:@"RegistrationViewController" bundle:nil];
    self.window.rootViewController = self.registrationVC;
    
    
    //_bannerViewController = [[BannerViewController alloc] initWithContentViewController:self.registrationVC];
    //self.window.rootViewController = _bannerViewController;
    
    [self.window makeKeyAndVisible];
    return YES;
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if( webApi == nil)
        webApi = [WebAPI sharedInstance];
    
    [webApi stopUpdateLocationThread];
    
    if( [self readSessionId] != nil && ![[self readSessionId] isEqual: @"null"]) {
        
        if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
            //Check if our iOS version supports multitasking I.E iOS 4
            // NSLog(@">>Device is support the multitask<<");
            if ([[UIDevice currentDevice] isMultitaskingSupported]) { //Check if device supports mulitasking
                
                UIApplication *application = [UIApplication sharedApplication]; //Get the shared application instance
                __block UIBackgroundTaskIdentifier background_task; //Create a task object
                
                background_task = [application beginBackgroundTaskWithExpirationHandler: ^ {
                    [application endBackgroundTask: background_task];
                    
                }];
                
                bgLocationTimer = [NSTimer scheduledTimerWithTimeInterval:240 target:self selector:@selector(updateLocation) userInfo:nil repeats:YES];
                //NSLog(@"timer is created:timer value:%@",bgLocationTimer);
            }
            
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //NSLog(@">>applicationDidBecomeActive method<<");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if( webApi == nil)
        webApi = [WebAPI sharedInstance];
    
    [webApi stopBackgroundLocationUpdate];
    if( [bgLocationTimer isValid]) {
        [bgLocationTimer invalidate];
        bgLocationTimer = nil;
        // NSLog(@"timer is invalidated");
    }
    if( [self readSessionId] != nil && ![[self readSessionId] isEqual: @"null"]) {
        [webApi startUpdateLocationThread];
        // NSLog(@">>Timer Location update is started<<");
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(NSString*)readSessionId
{
    
    NSError* error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:@"imageFolder"];
    path = [path stringByAppendingPathComponent:@"sessionId"];
    
    NSString* sessionId1 = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    
    return sessionId1;
        
}
-(void)updateLocation {
   // NSLog(@">>Update Location method<<");
    if( webApi == nil)
        webApi = [WebAPI sharedInstance];
    
    [webApi startBackgroundLocationUpdate];
}

@end
