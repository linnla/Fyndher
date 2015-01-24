//
//  ForgetPasswordViewController.h
//  Fyndher
//
//  Created by Harigharan on 22/04/13.
//  Copyright (c) 2013 Mobile Analytics   All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebAPI.h"
#import "GlobalConstants.h"

@interface ForgetPasswordViewController : UIViewController<UITextFieldDelegate,ProcessDataDelegate> {
    
    IBOutlet UITextField *reset_email;
    WebAPI *webServices;
    int intStatusCode, original_Xaxis_value, original_Yaxis_value;
    UIAlertView* loader;
    CGFloat animatedDistance;
    int isRequestSended;
    
}


@end
