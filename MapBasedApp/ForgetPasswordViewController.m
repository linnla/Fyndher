//
//  ForgetPasswordViewController.m
//  Fyndher
//
//  Created by Harigharan on 22/04/13.
//  Copyright (c) 2013 Mobile Analytics   All rights reserved.
//

#import "ForgetPasswordViewController.h"
#import "RegistrationViewController.h"

@interface ForgetPasswordViewController ()

@end

@implementation ForgetPasswordViewController

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
    webServices = [WebAPI sharedInstance];
    [webServices setDelegate:self];
    [reset_email setDelegate:self];
    loader = [[UIAlertView alloc] initWithTitle:@"Loading.. Please wait...."
                                        message:nil
                                       delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:nil, nil];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(139.5, 75.5); // .5 so it doesn't blur
    [loader addSubview:spinner];
    [spinner startAnimating];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleWidth;
    
    isRequestSended = NO;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)resetPassword:(id)sender {
    
    UIAlertView* alertView;
    
    if(![self testInternetConnection]) {
        alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                               message:@"Fyndher requires an active network connection"
                                              delegate:self
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if ([[reset_email.text stringByReplacingOccurrencesOfString:@" " withString:@""] length] == 0) {
        
        alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                               message:@"Email field is Empty!"
                                              delegate:self
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    if ([self validateEmailAddress:reset_email.text] == NO) {
        
        alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                               message:@"Invalid Email !"
                                              delegate:self
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if([[reset_email.text stringByReplacingOccurrencesOfString:@" " withString:@""] length] >0 ) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        NSString* urlString = [NSString stringWithFormat:@"%@/%@?email=%@",BASEURL,APIRESETPASSWORD,reset_email.text];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"GET"];
        NSLog(@"Requset url:%@",urlString);
        
        [NSURLConnection connectionWithRequest:request delegate:self];
        isRequestSended = YES;
        [loader show];
        
        
    }
}
- (IBAction)gotoLoginOrRegister:(id)sender {
    //webServices.isLoginViewControllerCalled = YES;
    ////RegistrationViewController* regVC = [RegistrationViewController new];
    //[self presentModalViewController:regVC animated:YES];
    //[self presentViewController:regVC animated:YES completion:NULL];
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}


-(void)processFail:(NSString *)paraResponse {
    
}

-(void)processSuccessful:(NSArray *)paraResponse {
    
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    //NSLog(@"didReceiveResponse method");
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    intStatusCode = [httpResponse statusCode];
    
    
    // NSLog(@"intStatusCode:--- %d", intStatusCode);
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    //NSLog(@"didReceiveData method");
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Resppnse value:%@",responseString);
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    // NSLog(@"connectionDidFinishLoading method");
    [loader dismissWithClickedButtonIndex:0 animated:YES];
    isRequestSended = NO;
    if( intStatusCode == 200 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Password was sent to your mail" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } else if ( intStatusCode == 403 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"Email address does not exists" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } else if (intStatusCode >= 500 ) {
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Fyndher server is busy, please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Fyndher requires an active internet connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    }else if(![self testInternetConnection]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"Fyndher requires an active network connection"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    //NSLog(@"didFailWithError method");
    [loader dismissWithClickedButtonIndex:0 animated:YES];
    
    isRequestSended = NO;
	if (intStatusCode >= 500 ) {
        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Fyndher server is busy, please try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Fyndher requires an active internet connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }else if(![self testInternetConnection]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                        message:@"Fyndher requires an active network connection"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        
    }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
    static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
    static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
    static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
    static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
    
    CGRect textFieldRect =
    [self.view convertRect:textField.bounds fromView:textField];
    
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
    //[UIView setAnimationDelegate:self];
    
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self changeFrameSize];
    
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    animatedDistance=0;
    
    return YES;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [reset_email resignFirstResponder];
    
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

-(BOOL)validateEmailAddress:(NSString*) email
{
    
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
    
}
- (BOOL)testInternetConnection
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    //NSLog(@">>>NetWork Status:%@",[NSString stringWithFormat:@"%u",networkStatus]);
    return !(networkStatus == NotReachable);
}
@end
