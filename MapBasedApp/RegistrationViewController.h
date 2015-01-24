//
//  RegistrationViewController.h
//  Fyndher
//
//  Created by Laure Linn on 24/09/12.
//  Copyright (c) 2012 Mobile Analytics   All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebAPI.h"
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"

@interface RegistrationViewController : UIViewController <NSURLConnectionDelegate, UITextFieldDelegate, ProcessDataDelegate,CLLocationManagerDelegate>
{
    IBOutlet UITextField *txtUsername;
    IBOutlet UITextField *txtPassword;
    
    IBOutlet UILabel *lbConfirmPassword;
    IBOutlet UITextField *txtFConfirmPassword;
    IBOutlet UIButton *btLogin;
    IBOutlet UIButton *btNewUser;
    CLLocationManager* locationManager;
    NSMutableData *dataResponse;
    UIAlertView* loader;
    // UITabBarController *tabBarController;
    NSTimer* updateLocationTimer;
    BOOL isSignUp;
    int intStatusCode, isAnimationFinished;
    int isRequestSended, isRegistrationRequestSend, isLocationUpdateRequsetSended;
    CGFloat animatedDistance;
    IBOutlet UIActivityIndicatorView *indicator;
    
    IBOutlet UIScrollView *scrollView;
    WebAPI *webServices;
    IBOutlet UIImageView *pg_image;
    int original_Xaxis_value, original_Yaxis_value;
    Reachability *isInternetReachable;
}

@property(assign) NSMutableData *dataResponse;
- (IBAction)SignUp:(id)sender;
- (IBAction)clickNewUser:(id)sender;

@end
