//
//  RegistrationViewController.m
//  Fyndher
//
//  Created by Laure Linn on 24/09/12.
//  Copyright (c) 2012 Mobile Analytics   All rights reserved.
//

#import "RegistrationViewController.h"
#import "JSON.h"
#import "WebAPI.h"
#import "GlobalConstants.h"

#import "ProfileViewController.h"

#import "PhotosViewController.h"
#import "ForgetPasswordViewController.h"
#import "Reachability.h"
#import <CoreLocation/CoreLocation.h>


@interface RegistrationViewController ()

@end

@implementation RegistrationViewController
@synthesize dataResponse = _dataResponse;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    // NSLog(@"Init with nib name method");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@">>view did load method<<");
    [txtUsername setDelegate:self];
    [txtPassword setDelegate:self];
    webServices = [WebAPI sharedInstance];
    [webServices setDelegate:self];
    isRequestSended = NO;
    isRegistrationRequestSend = NO;
    isLocationUpdateRequsetSended = NO;
    isAnimationFinished = YES;
    loader = [[UIAlertView alloc] initWithTitle:@"Loading.. Please wait..."
                                        message:nil
                                       delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:nil, nil];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(139.5, 75.5); // .5 so it doesn't blur
    [loader addSubview:spinner];
    [spinner startAnimating];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    locationManager.delegate = self;
    
    // Laure Added to resolve issue that screen aren't rezing with iPhone 4
    self.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleHeight| UIViewAutoresizingFlexibleWidth;
    
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"page_pg.png"]];
    
    if(webServices.loggedInUserDetails != nil) {
        
        [webServices.loggedInUserDetails removeAllObjects];
        webServices.loggedInUserDetails = nil;
    }
    if( webServices.loggedInUserImage != nil ) {
        webServices.loggedInUserImage = nil;
    }
    
    if( webServices.readSessionId != nil && ![webServices.readSessionId isEqual: @"null"] && [CLLocationManager locationServicesEnabled])
    {
        [loader show];
        [locationManager startUpdatingLocation];
        [webServices startUpdateLocationThread];
    }
    //NSLog(@">>LoggedInUserDetails:%@",webServices.loggedInUserDetails);
    // NSLog(@">>LoggedInUserImage:%@",webServices.loggedInUserImage);
    
}
-(void)viewWillAppear:(BOOL)animated
{
    //NSLog(@"-----View will appear -----");
    
    [webServices setDelegate:self];
    [txtPassword resignFirstResponder];
    [txtUsername resignFirstResponder];
    if(webServices.loggedInUserDetails != nil) {
        
        [webServices.loggedInUserDetails removeAllObjects];
        webServices.loggedInUserDetails = nil;
    }
    if( webServices.loggedInUserImage != nil ) {
        webServices.loggedInUserImage = nil;
    }
    
    
}
- (IBAction)SignUp:(id)sender {
    
    if( isRequestSended == NO ) {
        
        NSString* email = [txtUsername.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString* password = [txtPassword.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        UIAlertView* login_Alertview;
        
        if(![self testInternetConnection]) {
            login_Alertview = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                         message:@"Fyndher requires an active network connection"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [login_Alertview show];
            return;
        }
        /*  NSLog(@"ISlocation service Enabled:%d",[CLLocationManager locationServicesEnabled]);
         if(![CLLocationManager locationServicesEnabled] ) {
         login_Alertview = [[UIAlertView alloc] initWithTitle:@"Alert"
         message:@"Gps is not Enabled, Please turn on Gps.."
         delegate:self
         cancelButtonTitle:@"OK"
         otherButtonTitles:nil, nil];
         [login_Alertview show];
         return;
         }*/
        
        if([email length] == 0) {
            login_Alertview = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                         message:@"Email field is empty!"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [login_Alertview show];
            return;
        }
        if ([self validateEmailAddress:email] == NO) {
            login_Alertview = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                         message:@"Invalid Email address"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [login_Alertview show];
            return;
        }
        
        if ([password length] == 0) {
            login_Alertview = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                         message:@"Password field is empty"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [login_Alertview show];
            return;
        }
        if([password length] < 6) {
            
            login_Alertview = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                         message:@"Password is less than 6 characters"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [login_Alertview show];
            return;
        }
        
        NSMutableDictionary *dictParam = [NSMutableDictionary new];
        
        [dictParam setValue:txtPassword.text forKey:@"password"];
        [dictParam setValue:txtUsername.text forKey:@"email"];
        [dictParam setValue:txtUsername.text forKey:@"uuid"];
        
        // NSLog(@"UUID:%@",[[[UIDevice currentDevice] identifierForVendor] UUIDString]);
        //[indicator startAnimating];
        [loader show];
        
        webServices.isCookie = YES;
        [webServices callAPI:APILOGINUSER dictionary:dictParam];
        isRequestSended = YES;
        btLogin.selected = YES;
    }
    
}

- (IBAction)clickNewUser:(id)sender {
    
    if( isRequestSended == NO) {
        
        NSMutableDictionary *dictParam = [NSMutableDictionary new];
        NSString* email = [txtUsername.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString* password = [txtPassword.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        UIAlertView* login_Alertview;
        
        if(![self testInternetConnection]) {
            login_Alertview = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                         message:@"Fyndher requires an active network connection"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [login_Alertview show];
            return;
        }
        
        
        if([email length] == 0) {
            login_Alertview = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                         message:@"Email field is empty"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [login_Alertview show];
            return;
        }
        if ([self validateEmailAddress:email] == NO) {
            login_Alertview = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                         message:@"Invalid Email address"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [login_Alertview show];
            return;
        }
        
        if ([password length] == 0) {
            login_Alertview = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                         message:@"Password field is empty"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            [login_Alertview show];
            return;
        }
        if([password length] < 6) {
            
            login_Alertview = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                         message:@"Password is less than 6 characters"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
            
            return;
        }
        [dictParam setValue:txtPassword.text forKey:@"password"];
        [dictParam setValue:txtUsername.text forKey:@"email"];
        [dictParam setValue:txtUsername.text forKey:@"uuid"];
        
        //[indicator startAnimating];
        [loader show];
        [webServices callAPI:APISIGNUPUSER dictionary:dictParam];
        isRequestSended = YES;
        isRegistrationRequestSend = YES;
        btNewUser.selected = YES;
        //webServices.isNewUserRegistered = YES;
        
    }
    
}




- (void)processSuccessful:(NSArray *)paraResponse
{
    
    //NSLog(@"Success Response >> Registration View >>>>>>>>>Favorite %@", paraResponse);
    
    if([[paraResponse objectAtIndex:0] intValue] == 200 && isRequestSended == YES )
    {
        
        if( isRegistrationRequestSend == YES ) {
            
            isRegistrationRequestSend = NO;
            
            // Laure
            [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(sendLoginRequest) userInfo:nil repeats:NO];
            
            //[NSThread detachNewThreadSelector:@selector(sendLoginRequest) toTarget:self withObject:nil];
            
            //[indicator startAnimating];
        }
        else{
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            [defaults setObject:[[paraResponse objectAtIndex:1] valueForKey:@"favouriteUserIds"] forKey:KEYFAVORITEUSERS];
            
            [defaults setObject:[[paraResponse objectAtIndex:1] valueForKey:@"blockedUserIds"] forKey:KEYBLOCKEDUSERS];
            
            [defaults setObject:[[[paraResponse objectAtIndex:1] valueForKey:@"loginDetailsFromEmail"] valueForKey:@"email"] forKey:KEYEMAIL];
            [defaults synchronize];
            
            isRequestSended = NO;
            
            [locationManager startUpdatingLocation];
            [webServices startUpdateLocationThread];
            
            
            
            
        }
        
        
    }
    else if ([[paraResponse objectAtIndex:0] intValue] == 420 && isRequestSended == YES )
    {
        // [indicator stopAnimating];
        [loader dismissWithClickedButtonIndex:0 animated:YES];
        // NSLog(@">>Response value:%@",[paraResponse objectAtIndex:1]);
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Invalid ID or password"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        isRequestSended = NO;
        btNewUser.selected = NO;
        btLogin.selected = NO;
    }
    else if ( [[paraResponse objectAtIndex:0] intValue] == 403 && isRequestSended == YES)
    {
        //[indicator stopAnimating];
        [loader dismissWithClickedButtonIndex:0 animated:YES];
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:[paraResponse objectAtIndex:1]
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertView show];
        isRequestSended = NO;
        btNewUser.selected = NO;
        btLogin.selected = NO;
    }
    
}
- (void)processFail:(NSString *)paraResponse
{
    //[indicator stopAnimating];
    // NSLog(@">>ProcessFail method<<");
    [loader dismissWithClickedButtonIndex:0 animated:YES];
    
    btNewUser.selected = NO;
    btLogin.selected = NO;
    isRequestSended = NO;
    isRegistrationRequestSend = NO;
    isLocationUpdateRequsetSended = NO;
}
- (IBAction)resetPassword:(id)sender {
    ForgetPasswordViewController *forgetPasswordVC = [ForgetPasswordViewController new];
    [self presentViewController:forgetPasswordVC animated:YES completion:NULL];
}

- (void) locationManager: (CLLocationManager *) manager
     didUpdateToLocation: (CLLocation *) newLocation
            fromLocation: (CLLocation *) oldLocation{
    // NSLog(@">>location update Pass<<");
    [locationManager stopUpdatingLocation];
    [self sendUpdateLocationRequest:newLocation];
    
}

- (void) locationManager: (CLLocationManager *) manager
        didFailWithError: (NSError *) error {
    // NSLog(@">>location update fail<<");
    [locationManager stopUpdatingLocation];
    
    [self sendUpdateLocationRequest:NULL];
    
    /*[loader dismissWithClickedButtonIndex:0 animated:YES];
     PhotosViewController *objPhotosVC = [PhotosViewController new];
     [self presentViewController:objPhotosVC animated:YES completion:NULL];*/
    
    
    
}
-(void) sendUpdateLocationRequest:(CLLocation *) newLocation
{
    float latitude = 0.00;
    float longitude = 0.00;
    if(newLocation != NULL ) {
        latitude = newLocation.coordinate.latitude;
        longitude = newLocation.coordinate.longitude;
    }
    
    NSMutableDictionary *paraDict = [NSMutableDictionary new];
    
    [paraDict setValue:[NSString stringWithFormat:@"%f", latitude] forKey:@"lattitude"];
    [paraDict setValue:[NSString stringWithFormat:@"%f", longitude] forKey:@"longitude"];
    
    
    NSString *jsonPostBody = [paraDict JSONRepresentation];
    
    NSURL *url;
    NSString* strURL = [BASEURL stringByAppendingString:APIUPDATEUSERLOCATION];
    
    NSLog(@"url string : %@", strURL);
    NSLog(@"Parameters : %@", jsonPostBody);
    
    url = [NSURL URLWithString:strURL];
    
    NSString* postDataLengthString = [[NSString alloc] initWithFormat:@"%d", [[jsonPostBody stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] length]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:180.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[jsonPostBody dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postDataLengthString forHTTPHeaderField:@"Content-Length"];
    // NSUserDefaults *prefrences = [NSUserDefaults standardUserDefaults];
    if([webServices readSessionId] != nil && ![[webServices readSessionId] isEqual: @"null"])
        [request setValue:[webServices readSessionId] forHTTPHeaderField:@"Cookie"];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    intStatusCode = [httpResponse statusCode];
    
    
    //NSLog(@"intStatusCode:--- %d", intStatusCode);
    
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"Update location response:%@",responseString);
    if( intStatusCode == 200 ) {
        NSMutableArray *arrayPara = [NSMutableArray new];
        [arrayPara addObject:[NSString stringWithFormat:@"%d", intStatusCode]];
        if ([responseString length] > 0) {
            NSMutableDictionary *dictResponse = [responseString JSONValue];
            [arrayPara addObject:dictResponse];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            [defaults setValue:[[arrayPara objectAtIndex:1] valueForKey:@"screenName"] forKey:KEYLOGINEDUSERSCREENNAME];
            
            webServices.loggedInUserDetails = [arrayPara objectAtIndex:1];
            if ((NSNull *)[[arrayPara objectAtIndex:1] valueForKey:@"photo"] != [NSNull null]) {
                if ([webServices isFileExists:[[arrayPara objectAtIndex:1] valueForKey:@"photo"]]) {
                    
                    webServices.loggedInUserImage = [webServices readImageValue_ImagePath:[[arrayPara objectAtIndex:1] valueForKey:@"photo"]];
                    
                }else {
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/rest/1/file/%@?pixel=100",BASEURL,[webServices.loggedInUserDetails valueForKey:@"photo"]]];
                    webServices.loggedInUserImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                    [webServices writeImageValue_ImagePath:[[arrayPara objectAtIndex:1] valueForKey:@"photo"] imageForUser:webServices.loggedInUserImage];
                }
            }
            else
                webServices.loggedInUserImage = [UIImage imageNamed:@"blank_user.png"];
            
            // NSLog(@">>LoggedInUser Image:%@",webServices.loggedInUserImage);
            
            
        }
    }
    
    [loader dismissWithClickedButtonIndex:0 animated:YES];
    PhotosViewController *objPhotosVC = [PhotosViewController new];
    [self presentViewController:objPhotosVC animated:YES completion:NULL];
    txtPassword.text = @"";
    btNewUser.selected = NO;
    btLogin.selected = NO;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    //NSLog(@"connectionDidFinishLoading method");
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	//NSLog(@"didFailWithError method");
    
    [loader dismissWithClickedButtonIndex:0 animated:YES];
    PhotosViewController *objPhotosVC = [PhotosViewController new];
    [self presentViewController:objPhotosVC animated:YES completion:NULL];
    txtPassword.text = @"";
    btNewUser.selected = NO;
    btLogin.selected = NO;
}

-(void)sendLoginRequest
{
    NSMutableDictionary *dictParam = [NSMutableDictionary new];
    [dictParam setValue:txtPassword.text forKey:@"password"];
    [dictParam setValue:txtUsername.text forKey:@"email"];
    [dictParam setValue:txtUsername.text forKey:@"uuid"];
    webServices.isCookie = YES;
    [webServices callAPI:APILOGINUSER dictionary:dictParam];
    isRequestSended = YES;
    
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
    
    if( webServices.isLoginViewControllerCalled == YES ) {
        if( orientation == UIDeviceOrientationLandscapeRight) {
            viewFrame.origin.x -= animatedDistance;
            
        }else if ( orientation == UIDeviceOrientationLandscapeLeft) {
            viewFrame.origin.x += animatedDistance;
            
        }else {
            viewFrame.origin.y -= animatedDistance;
            
        }
    }
    else{
        viewFrame.origin.y -= animatedDistance;
    }
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    isAnimationFinished = NO;
    
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
    [txtUsername resignFirstResponder];
    [txtPassword resignFirstResponder];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

-(void)changeFrameSize
{
    
    int isChangeFrameSize = NO, Xvalue = self.view.frame.origin.x, Yvalue = self.view.frame.origin.y;
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    //webServices.isLoginViewControllerCalled = YES;
    if( webServices.isLoginViewControllerCalled == YES) {
        
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
    else if(self.view.frame.origin.y < 0){
        static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
        CGRect viewFrame = self.view.frame;
        
        viewFrame.origin.y += animatedDistance;
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

//Read and Write image method in WebApi.m
/*-(void)writeImageValue_ImagePath:(NSString*)imagepath imageForUser:(UIImage*) image {
 
 NSLog(@">>Write Image method<<");
 if (image != nil)
 {
 NSError* error;
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
 NSUserDomainMask, YES);
 NSString *documentsDirectory = [paths objectAtIndex:0];
 NSString* path = [documentsDirectory stringByAppendingPathComponent:@"imageFolder"];
 if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
 [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
 NSLog(@">>Directory is Created<<<");
 }
 path = [path stringByAppendingPathComponent:imagepath];
 
 
 // laure.linn 6.16 Faster than png save
 //NSData* data = UIImagePNGRepresentation(image);
 NSData* data = UIImageJPEGRepresentation(image, 1);
 
 
 BOOL isWritten = [data writeToFile:path atomically:YES];
 NSLog(@">>IsWritten:%d",isWritten);
 
 
 }
 }
 
 -(id)readImageValue_ImagePath:(NSString*) imagePath
 {
 NSLog(@">>>Read image method<<");
 if(imagePath != NULL) {
 
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
 NSUserDomainMask, YES);
 NSString *documentsDirectory = [paths objectAtIndex:0];
 NSString* path = [documentsDirectory stringByAppendingPathComponent:@"imageFolder"];
 path = [path stringByAppendingPathComponent:imagePath];
 
 UIImage* image = [UIImage imageWithContentsOfFile:path];
 return image;
 
 }
 return  NULL;
 
 }
 -(BOOL)isFileExists:(NSString*) imagePath
 {
 if( imagePath != NULL) {
 
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
 NSUserDomainMask, YES);
 NSString *documentsDirectory = [paths objectAtIndex:0];
 NSString* path = [documentsDirectory stringByAppendingPathComponent:@"imageFolder"];
 path = [path stringByAppendingPathComponent:imagePath];
 NSLog(@">>IsFileExists:%d",[[NSFileManager defaultManager] fileExistsAtPath:path]);
 //NSLog(@">>File Path:%@",path);
 return [[NSFileManager defaultManager] fileExistsAtPath:path];
 
 }
 return NO;
 }
 
 -(NSString*)readSessionId
 {
 NSLog(@">>>Read sessionId method<<");
 
 NSError* error;
 
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
 NSUserDomainMask, YES);
 NSString *documentsDirectory = [paths objectAtIndex:0];
 NSString* path = [documentsDirectory stringByAppendingPathComponent:@"imageFolder"];
 path = [path stringByAppendingPathComponent:@"sessionId"];
 
 NSString* sessionId1 = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
 NSLog(@">>SessionId value:%@",sessionId1);
 return sessionId1;
 
 
 
 }*/

@end
