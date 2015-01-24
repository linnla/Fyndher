//
//  ReportViewController.h
//  Fyndher
//
//  Created by Harigharan on 19/04/13.
//  Copyright (c) 2013 Mobile Analytics   All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebAPI.h"
#import "GlobalConstants.h"


@interface ReportViewController : UIViewController<UITextViewDelegate>
{
    IBOutlet UITextView *report_text;
    WebAPI *webServices;
    CGFloat animatedDistance;
    CGFloat original_Xaxis_value, original_Yaxis_value;
}


@end
