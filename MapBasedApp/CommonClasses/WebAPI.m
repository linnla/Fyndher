//
//  WebAPI.m
//  Fyndher
//
//  Created by Laure Linn on 03/11/12.
//  Copyright (c) 2012 Mobile Analytics   All rights reserved.
//

#import "WebAPI.h"
#import "JSON.h"
#import "GlobalConstants.h"
#import <CoreLocation/CoreLocation.h>
#import "Reachability.h"

@implementation WebAPI
@synthesize dataResponse, isCookie,isFavouriteUser,isLoginViewControllerCalled, totalUnreadMessages, onlineStatus, sessionId, isBackFromChat,chatReplyTimer;
@synthesize delegate;
@synthesize strURL, imgUser, oldMessageCount;

#pragma mark Singleton Methods

static WebAPI *sharedInstance = nil;
@synthesize dictSelectedUser,locationUpdateTimer,loggedInUserDetails,loggedInUserImage, isCallFromChat, isCallFromProfileView, isBlockedUser;

// Get the shared instance and create it if necessary.
+ (WebAPI *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
        
    }
    
    return sharedInstance;
}

// We don't want to allocate a new instance, so return the current one.
+ (id)allocWithZone:(NSZone*)zone {
    return [self sharedInstance];
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}



- (void) callAPI : (NSString *)paraAPIName dictionary : (NSDictionary *)paraDict
{
    self.dataResponse = [[NSMutableData alloc] init];
    
    NSString *jsonPostBody = [paraDict JSONRepresentation];
    
    NSURL *url;
    strURL = [BASEURL stringByAppendingString:paraAPIName];
    
    NSLog(@"url string : %@", strURL);
    NSLog(@"Parameters : %@", jsonPostBody);
    
    url = [NSURL URLWithString:strURL];
    
    NSString* postDataLengthString = [[NSString alloc] initWithFormat:@"%d", [[jsonPostBody stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] length]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:180.0];
    
    if ([paraAPIName isEqualToString:APIGETALLREADMESSAGESFROMUSER] ||
        [paraAPIName isEqualToString:APIFAVORITEUSERDETAILS] ||
        [paraAPIName isEqualToString:APISEARCHNEARESTUSERSBYUSERPROFILEATTRIBUTE] || [paraAPIName isEqualToString:APIREPORTUSER] || [paraAPIName isEqualToString:APIDELETEPARTICULARUSERCHATHISTORY]) {
        
        NSUserDefaults *prefrences = [NSUserDefaults standardUserDefaults];
        [request setValue:[prefrences valueForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
        
    }
    else if ([paraAPIName isEqualToString:APIVIEWPROFILE] ||
             [paraAPIName isEqualToString:APIONLINEUSERS] ||
             [paraAPIName isEqualToString:APINEXTNEARESTUSERS] ||
             [paraAPIName isEqualToString:APISEARCHNEXTNEARESTUSERSBYUSERPROFILEATTRIBUTE] ||
             [paraAPIName isEqualToString:APIGETMOREFAVORITEUSERDETAILS] ||
             [paraAPIName isEqualToString:APIGETRECENTCHATTINGUSER] ||
             [paraAPIName isEqualToString:APISEARCHNEXTNEARESTONLINEUSERS] ||
             [paraAPIName isEqualToString:APIRESETPASSWORD]) {
        
        NSUserDefaults *prefrences = [NSUserDefaults standardUserDefaults];
        [request setValue:[prefrences valueForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
        [request setHTTPMethod:@"GET"];
    }
    else if ([paraAPIName isEqualToString:APINEARESTNEIGHBOR] || [paraAPIName isEqualToString:APIGETUNREADMESSAGES] || [paraAPIName isEqualToString:APILOGOUT] ) {
        
        [request setHTTPMethod:@"GET"];
    }
    else
        [request setHTTPMethod:@"POST"];
    
    if([paraAPIName isEqualToString:APIFAVORITEUSERDETAILS] || [paraAPIName isEqualToString:APIREPORTUSER] || [paraAPIName isEqualToString:APIDELETEPARTICULARUSERCHATHISTORY] || [paraAPIName isEqualToString:APIDELETECHATHISTORY]) {
        [request setHTTPMethod:@"POST"];
    }
    if([paraAPIName isEqualToString:APILOGOUT])
        isLogoutRequestsend = YES;
    else
        isLogoutRequestsend = NO;
    if([self readSessionId] != nil && ![[self readSessionId] isEqual: @"null"])
        [request setValue:[self readSessionId] forHTTPHeaderField:@"Cookie"];
    
    [request setHTTPBody:[jsonPostBody dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postDataLengthString forHTTPHeaderField:@"Content-Length"];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
    //NSLog(@"request is sent");
}

- (void) updateUserLocation : (CLLocation *)newLocation
{
    // NSLog(@">>>updateUserLocation method<<<<");
    //self.dataResponse = [[NSMutableData alloc] init];
    float latitude = 0.00, longtitude = 0.00;
    if( newLocation != NULL) {
        latitude =newLocation.coordinate.latitude;
        longtitude = newLocation.coordinate.longitude;
    }
    NSMutableDictionary *dictParam = [NSMutableDictionary new];
    
    [dictParam setValue:[NSString stringWithFormat:@"%f", latitude] forKey:@"lattitude"];
    [dictParam setValue:[NSString stringWithFormat:@"%f", longtitude] forKey:@"longitude"];
    
    NSString *jsonPostBody = [dictParam JSONRepresentation];
    
    NSURL *url;
    //http://fyndher.appspot.com
    
    url = [NSURL URLWithString:[BASEURL stringByAppendingString:@"/rest/1/user/updateLocation"]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:180.0];
    
    [request setHTTPMethod:@"POST"];
    
    [request setHTTPBody:[jsonPostBody dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    
    NSString* postDataLengthString = [[NSString alloc] initWithFormat:@"%d", [[jsonPostBody stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] length]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postDataLengthString forHTTPHeaderField:@"Content-Length"];
    if([self readSessionId] != nil && ![[self readSessionId] isEqual: @"null"])
        [request setValue:[self readSessionId] forHTTPHeaderField:@"Cookie"];
    
    //[NSURLConnection connectionWithRequest:request delegate:self];
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    //NSLog(@"Update location Response:%@",returnString);
    if( messageAlertView != nil) {
        [messageAlertView dismissWithClickedButtonIndex:0 animated:YES];
        messageAlertView = nil;
    }
    if ([returnString length] > 0) {
        NSMutableDictionary *dictResponse = [returnString JSONValue];
        
        if(((NSNull *)[dictResponse valueForKey:@"totalUnreadMessages"] != [NSNull null])&& [[dictResponse valueForKey:@"totalUnreadMessages"] intValue] > oldMessageCount) {
            // LAL commented out of v1.0
            /*messageAlertView = [[UIAlertView alloc] initWithTitle:@"New Message is Received"
             message:[NSString stringWithFormat:@"Inbox count:%@",[dictResponse valueForKey:@"totalUnreadMessages"]]
             delegate:nil
             cancelButtonTitle:@"OK"
             otherButtonTitles:nil];
             [messageAlertView show];*/
            
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            
            NSDate *now = [NSDate date];
            
            localNotification.fireDate = now;
            localNotification.alertBody = [NSString stringWithFormat:@"New message is received\nInbox count:%@",[dictResponse valueForKey:@"totalUnreadMessages"]];
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            localNotification.applicationIconBadgeNumber = [[dictResponse valueForKey:@"totalUnreadMessages"] intValue]; // increment
            
            
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
            
        }
        
        if ((NSNull *)[dictResponse valueForKey:@"totalUnreadMessages"] != [NSNull null]) {
            oldMessageCount = [[dictResponse valueForKey:@"totalUnreadMessages"] intValue];
        }else
            oldMessageCount = 0;
    }
}


#pragma mark -
#pragma mark NSURLConnectionDelegates

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    intStatusCode = [httpResponse statusCode];
    
    if (isCookie) {
        
        NSDictionary *headers = [httpResponse allHeaderFields];
        //NSLog(@"headers value:%@",headers);
        
        NSRange range;
        range.location = 11;
        range.length = 22;
        
        NSUserDefaults *prefrences = [NSUserDefaults standardUserDefaults];
        //[prefrences setValue:[[headers valueForKey:@"Set-Cookie"] substringWithRange:range] forKey:@"Cookie"];
        [prefrences setValue:[headers valueForKey:@"Set-Cookie"] forKey:@"Cookie"];
        //NSLog(@"Header Values : >>>>>>>> %@", [prefrences valueForKey:@"Cookie"]);
        sessionId = [prefrences valueForKey:@"Cookie"];
        [prefrences synchronize];
        [self writeSessionId:sessionId];
        isCookie = NO;
    }
    //NSLog(@"intStatusCode:--- %d", intStatusCode);
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    if(isLogoutRequestsend == NO)
        [dataResponse appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if(isLogoutRequestsend == NO ) {
        
        NSString *responseString = [[NSString alloc] initWithData:dataResponse encoding:NSUTF8StringEncoding];
        dataResponse = nil;
        
        // NSLog(@">>>connectionDidFinishLoadings: %@", responseString);
        
        if( intStatusCode == 420 || intStatusCode == 400 )
        {
            NSMutableArray *arrayPara = [NSMutableArray new];
            [arrayPara addObject:[NSString stringWithFormat:@"%d", intStatusCode]];
            [arrayPara addObject:responseString];
            [[self delegate] processSuccessful:arrayPara];
        }
        
        if (intStatusCode == 200) {
            // NSLog(@"Status code is 200");
            NSMutableArray *arrayPara = [NSMutableArray new];
            [arrayPara addObject:[NSString stringWithFormat:@"%d", intStatusCode]];
            if ([responseString length] > 0) {
                NSMutableDictionary *dictResponse = [responseString JSONValue];
                [arrayPara addObject:dictResponse];
                //  NSLog(@"Response String: %d",[dictResponse );
                //NSLog(@"Json value: %@",dictResponse);
                //NSLog(@"size of return reponse %d",[[arrayPara objectAtIndex:1] count]);
            }
            [[self delegate] processSuccessful:arrayPara];
            
        }else if (intStatusCode == 204 ) {
            
            //NSLog(@"emptyResponse method to be called");
            NSMutableArray *arrayPara = [NSMutableArray new];
            [arrayPara addObject:[NSString stringWithFormat:@"%d", intStatusCode]];
            //[arrayPara addObject:responseString ];
            [[self delegate] processSuccessful:arrayPara];
            
        }else if (intStatusCode == 403 ) {
            
            NSMutableArray *arrayPara = [NSMutableArray new];
            [arrayPara addObject:[NSString stringWithFormat:@"%d", intStatusCode]];
            [arrayPara addObject:responseString];
            [[self delegate] processSuccessful:arrayPara];
            
        }
        
        else {
            
            
            if(![self testInternetConnection]) {
                
                if(networkStatusAlert == nil) {
                    networkStatusAlert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                    message:@"Fyndher requires an active network connection"
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil, nil];
                }
                else
                    [networkStatusAlert dismissWithClickedButtonIndex:0 animated:YES];
                
                [networkStatusAlert show];
            }else if(intStatusCode >= 500){
                
                if(serverStatusAlert == nil) {
                    serverStatusAlert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                                   message:@"Fyndher requires an active network connection"
                                         //message:@"Fyndher server is busy, please try again later"
                                                                  delegate:self
                                                         cancelButtonTitle:@"OK"
                                                         otherButtonTitles:nil, nil];
                }
                else
                    [serverStatusAlert dismissWithClickedButtonIndex:0 animated:YES];
                
                [serverStatusAlert show];
            }
            
            [[self delegate] processFail:responseString];
            
            
        }
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	connection = nil;
    //NSLog(@"Web api didfailwithError");
    // NSLog(@"networkstatus alertview is:%@",networkStatusAlert);
    if(![self testInternetConnection]) {
        
        if(networkStatusAlert == nil) {
            networkStatusAlert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Fyndher requires an active network connection"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        }
        else
            [networkStatusAlert dismissWithClickedButtonIndex:0 animated:YES];
        
        [networkStatusAlert show];
    }else if(intStatusCode >= 500){
        
        if(serverStatusAlert == nil) {
            serverStatusAlert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                           message:@"Fyndher requires an active network connection"
                                 //message:@"Fyndher server is busy, please try again later"
                                                          delegate:self
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil, nil];
        }
        else
            [serverStatusAlert dismissWithClickedButtonIndex:0 animated:YES];
        
        [serverStatusAlert show];
    }
    [[self delegate] processFail:error.description];
	
	
}
-(void)startUpdateLocationThread
{
    [self stopUpdateLocationThread];
    if(locationManager == nil) {
        locationManager = [[CLLocationManager alloc] init];
        
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationManager.delegate = self;
    }
    //isLocationUpdateFromBackGround = NO;
    if( locationUpdateTimer == nil) {
        locationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:240 target:self selector:@selector(callLocationUpdate) userInfo:nil repeats:YES];
    }
}

-(void)stopUpdateLocationThread
{
    //[locationManager stopUpdatingLocation];
    
    if( [locationUpdateTimer isValid]) {
        [locationUpdateTimer invalidate];
        locationUpdateTimer = nil;
        locationManager = nil;
        //NSLog(@"timer is invalidated");
    }
    //isLocationUpdateFromBackGround = NO;
}

-(void)callLocationUpdate
{
    
    //isLocationUpdateFromBackGround = NO;
    [locationManager startUpdatingLocation ];
}

- (void) locationManager: (CLLocationManager *) manager
     didUpdateToLocation: (CLLocation *) newLocation
            fromLocation: (CLLocation *) oldLocation{
    
    
    [locationManager stopUpdatingLocation];
    [self updateUserLocation:newLocation];
    
    
}

- (void) locationManager: (CLLocationManager *) manager
        didFailWithError: (NSError *) error {
    
    
    [locationManager stopUpdatingLocation];
    [self updateUserLocation:NULL];
    
}
- (BOOL)testInternetConnection
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    return !(networkStatus == NotReachable);
}

-(void)writeSessionId:(NSString*) sessionValue{
    
    if (sessionValue != nil) {
        
        NSError* error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:@"imageFolder"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
            
        }
        path = [path stringByAppendingPathComponent:@"sessionId"];
        
        [sessionValue writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    
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


-(void)startBackgroundLocationUpdate {
    
    if(locationManager == nil) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        locationManager.delegate = self;
    }
    
    [locationManager startUpdatingLocation];
    //isLocationUpdateFromBackGround = YES;
    
}

-(void)stopBackgroundLocationUpdate {
    if( locationManager != nil ) {
        [locationManager stopUpdatingLocation];
        locationManager = nil;
    }
    //isLocationUpdateFromBackGround = NO;
}

-(void)writeImageValue_ImagePath:(NSString*)imagepath imageForUser:(UIImage*) image {
    
    // NSLog(@">>Write Image method<<");
    if (image != nil)
    {
        NSError* error;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:@"imageFolder"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
            //NSLog(@">>Directory is Created<<<");
        }
        path = [path stringByAppendingPathComponent:imagepath];
        
        
        // laure.linn 6.16 Faster than png save
        //NSData* data = UIImagePNGRepresentation(image);
        NSData* data = UIImageJPEGRepresentation(image, 1);
        
        
        [data writeToFile:path atomically:YES];
        //NSLog(@">>IsWritten:%d",isWritten);
        
        
    }
}

-(id)readImageValue_ImagePath:(NSString*) imagePath
{
    //NSLog(@">>>Read image method<<");
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
        // NSLog(@">>IsFileExists:%d",[[NSFileManager defaultManager] fileExistsAtPath:path]);
        //NSLog(@">>File Path:%@",path);
        return [[NSFileManager defaultManager] fileExistsAtPath:path];
        
    }
    return NO;
}

@end
