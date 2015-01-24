//
//  ReportViewController.m
//  Fyndher
//
//  Created by Harigharan on 19/04/13.
//  Copyright (c) 2013 Mobile Analytics   All rights reserved.
//

#import "ReportViewController.h"
#import "RegistrationViewController.h"

@interface ReportViewController ()

@end

@implementation ReportViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [report_text setDelegate:self];
    webServices = [WebAPI sharedInstance];
    [webServices setDelegate:self];
    
    report_text.textColor = [UIColor lightGrayColor];
    report_text.text = @"Enter Report Reason....";
    original_Xaxis_value = 0.00;
    original_Yaxis_value = 0.00;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logout:(id)sender {
    
    [webServices callAPI:APILOGOUT dictionary:NULL];
    [webServices stopUpdateLocationThread];
    [webServices writeSessionId:@"null"];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    webServices.isLoginViewControllerCalled = YES;
    //RegistrationViewController *profileVC = [RegistrationViewController new];
    //[self presentViewController:profileVC animated:YES completion:NULL];
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)back:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (IBAction)sendReport:(id)sender {
    NSString* reportText;
    
    NSMutableDictionary *dictParam = [NSMutableDictionary new];
    if (report_text.textColor == [UIColor lightGrayColor])
        reportText = @"";
    else
        reportText = [report_text.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if ([reportText length]  > 0) {
        
        [dictParam setObject:report_text.text forKey:@"reportReasonNote"];
        [dictParam setValue:[webServices.dictSelectedUser valueForKey:@"userId"] forKey:@"reporteeId"];
        [webServices callAPI:APIREPORTUSER dictionary:dictParam];
        report_text.textColor = [UIColor lightGrayColor];
        report_text.text = @"Enter Report Reason....";
        
        [report_text resignFirstResponder];
        [self changeFrameSize];
        
    }else {
        report_text.textColor = [UIColor lightGrayColor];
        report_text.text = @"Enter Report Reason....";
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@" "
                                                            message:@"Input reason for reporting"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
}
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    
    if (report_text.textColor == [UIColor lightGrayColor]) {
        report_text.text = @"";
        report_text.textColor = [UIColor blackColor];
    }
    static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.5;
    static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
    static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
    static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
    static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
    
    CGRect textFieldRect =
    [self.view convertRect:textView.bounds fromView:textView];
    
    CGRect viewRect =
    [self.view convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    original_Xaxis_value = self.view.frame.origin.x;
    original_Yaxis_value = self.view.frame.origin.y;
    
    CGRect viewFrame = self.view.frame;
    
    
    
    if( orientation == UIDeviceOrientationLandscapeRight) {
        viewFrame.origin.x -= animatedDistance;
        
    }else if ( orientation == UIDeviceOrientationLandscapeLeft) {
        viewFrame.origin.x += animatedDistance;
        
    }else {
        viewFrame.origin.y -= animatedDistance;
        
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(report_text.text.length == 0){
        report_text.textColor = [UIColor lightGrayColor];
        report_text.text = @"Enter Report Reason....";
        [report_text resignFirstResponder];
        [self changeFrameSize];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if (report_text.textColor == [UIColor lightGrayColor]) {
        report_text.text = @"";
        report_text.textColor = [UIColor blackColor];
    }
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if(report_text.text.length == 0){
            report_text.textColor = [UIColor lightGrayColor];
            report_text.text = @"Enter Report Reason....";
            [report_text resignFirstResponder];
        }
        [self changeFrameSize];
        
        return NO;
        
    }
    
    return YES;
}

- (void)processSuccessful:(NSArray *)paraResponse
{
    if ([[paraResponse objectAtIndex:0] intValue] == 200 ) {
        
    }
}
- (void)processFail:(NSString *)paraResponse
{
    NSLog(@"Report Process faill");
}

-(void)changeFrameSize
{
    
    int isChangeFrameSize = NO, Xvalue = self.view.frame.origin.x, Yvalue = self.view.frame.origin.y;
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if ( orientation == UIDeviceOrientationLandscapeRight && (Xvalue+animatedDistance) == original_Xaxis_value ) {
        isChangeFrameSize = YES;
    }else if (orientation == UIDeviceOrientationLandscapeLeft && (Xvalue-animatedDistance) == original_Xaxis_value )
    {
        isChangeFrameSize = YES;
    }else if( Yvalue+animatedDistance == original_Yaxis_value)
        isChangeFrameSize = YES;
    
    
    if( isChangeFrameSize == YES ) {
        static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
        CGRect viewFrame = self.view.frame;
        
        if( orientation == UIDeviceOrientationLandscapeRight) {
            viewFrame.origin.x += animatedDistance;
            
        }else if ( orientation == UIDeviceOrientationLandscapeLeft) {
            viewFrame.origin.x -= animatedDistance;
            
        }else {
            viewFrame.origin.y += animatedDistance;
            
        }
        
        // animatedDistance = 0;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        [self.view setFrame:viewFrame];
        [UIView commitAnimations];
    }
}
@end
