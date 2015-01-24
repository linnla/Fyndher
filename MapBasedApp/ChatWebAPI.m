//
//  ChatWebAPI.m
//  Fyndher
//
//  Created by Harigharan on 08/04/13.
//  Copyright (c) 2013 Mobile Analytics   All rights reserved.
//

#import "ChatWebAPI.h"
#import "JSON.h"
#import "GlobalConstants.h"
#import "Reachability.h"

@implementation ChatWebAPI
@synthesize dataResponse, isCookie;
@synthesize delegate;
@synthesize strURL, imgUser;

#pragma mark Singleton Methods

static ChatWebAPI *sharedInstance = nil;
@synthesize dictSelectedUser;

// Get the shared instance and create it if necessary.
+ (ChatWebAPI *)sharedInstance {
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
    // NSLog(@"---ChatWebAPI callAPI method---");
    self.dataResponse = [[NSMutableData alloc] init];
    
    NSString *jsonPostBody = [paraDict JSONRepresentation];
    
    NSURL *url;
    strURL = [BASEURL stringByAppendingString:paraAPIName];
    
    NSLog(@"url string : %@", strURL);
    NSLog(@"Parameters : %@", jsonPostBody);
    
    url = [NSURL URLWithString:strURL];
    
    NSUserDefaults *prefrences = [NSUserDefaults standardUserDefaults];
    
    NSString* postDataLengthString = [[NSString alloc] initWithFormat:@"%d", [[jsonPostBody stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] length]];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:180.0];
    
    if ([paraAPIName isEqualToString:APIGETALLREADMESSAGESFROMUSER] ||
        [paraAPIName isEqualToString:APIFAVORITEUSERDETAILS] ||
        [paraAPIName isEqualToString:APISEARCHNEARESTUSERSBYUSERPROFILEATTRIBUTE] ||
        [paraAPIName isEqualToString:APIDELETEPARTICULARUSERCHATHISTORY] || [paraAPIName isEqualToString:APIDELETECHATHISTORY] || [paraAPIName isEqualToString:APIGETUNREADMESSAGESANDCHATTINGUSERDETAILS] || [paraAPIName isEqualToString:APIGETPARTICULARUSERCHATHISTORY]){
        
        //NSUserDefaults *prefrences = [NSUserDefaults standardUserDefaults];
        //[request setValue:[prefrences valueForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
        
    }
    else if ([paraAPIName isEqualToString:APIVIEWPROFILE] ||
             [paraAPIName isEqualToString:APIONLINEUSERS] ||
             [paraAPIName isEqualToString:APINEXTNEARESTUSERS] ||
             [paraAPIName isEqualToString:APISEARCHNEXTNEARESTUSERSBYUSERPROFILEATTRIBUTE] ||
             [paraAPIName isEqualToString:APIGETMOREFAVORITEUSERDETAILS] ||
             [paraAPIName isEqualToString:APIGETRECENTCHATTINGUSER] ||
             [paraAPIName isEqualToString:APISEARCHNEXTNEARESTONLINEUSERS] ||
             [paraAPIName isEqualToString:APIRESETPASSWORD]) {
        
        // NSUserDefaults *prefrences = [NSUserDefaults standardUserDefaults];
        //[request setValue:[prefrences valueForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
        [request setHTTPMethod:@"GET"];
    }
    else if ([paraAPIName isEqualToString:APINEARESTNEIGHBOR] || [paraAPIName isEqualToString:APIGETUNREADMESSAGES]) {
        
        [request setHTTPMethod:@"GET"];
    }
    else
        [request setHTTPMethod:@"POST"];
    
    if([paraAPIName isEqualToString:APIFAVORITEUSERDETAILS] || [paraAPIName isEqualToString:APIDELETEPARTICULARUSERCHATHISTORY] || [paraAPIName isEqualToString:APIDELETECHATHISTORY] || [paraAPIName isEqualToString:APIGETUNREADMESSAGESANDCHATTINGUSERDETAILS] || [paraAPIName isEqualToString:APIGETPARTICULARUSERCHATHISTORY]) {
        [request setHTTPMethod:@"POST"];
    }
    
    
    [request setValue:[prefrences valueForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
    
    [request setHTTPBody:[jsonPostBody dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postDataLengthString forHTTPHeaderField:@"Content-Length"];
    
    [NSURLConnection connectionWithRequest:request delegate:self];
    // NSLog(@"request is sended");
}



#pragma mark -
#pragma mark NSURLConnectionDelegates

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    intStatusCode = [httpResponse statusCode];
    
    if (isCookie) {
        
        NSDictionary *headers = [httpResponse allHeaderFields];
        
        NSRange range;
        range.location = 0;
        range.length = 33;
        
        NSUserDefaults *prefrences = [NSUserDefaults standardUserDefaults];
        [prefrences setValue:[headers valueForKey:@"Set-Cookie"] forKey:@"Cookie"];
        //NSLog(@"Header Values : >>>>>>>> %@", [prefrences valueForKey:@"Cookie"]);
        
        [prefrences synchronize];
        isCookie = NO;
    }
    NSLog(@"intStatusCode:--- %d", intStatusCode);
}

-(void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    
    [dataResponse appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSString *responseString = [[NSString alloc] initWithData:dataResponse encoding:NSUTF8StringEncoding];
    dataResponse = nil;
    //NSLog(@"connectionDidFinishLoadings: %@", responseString);
    
    if (intStatusCode == 200) {
        NSLog(@"Status code is 200");
        NSMutableArray *arrayPara = [NSMutableArray new];
        [arrayPara addObject:[NSString stringWithFormat:@"%d", intStatusCode]];
        if ([responseString length] > 0) {
            NSMutableDictionary *dictResponse = [responseString JSONValue];
            [arrayPara addObject:dictResponse];
            //  NSLog(@"Response String: %d",[dictResponse );
            //NSLog(@"Json value: %@",dictResponse);
            //NSLog(@"size of return reponse %d",[[arrayPara objectAtIndex:1] count]);
        }
        
        [[self delegate] chatSchdularprocessSuccessful:arrayPara];
        
        // dataResponse = nil;
    }else if (intStatusCode == 400) {
        NSMutableArray *arrayPara = [NSMutableArray new];
        [arrayPara addObject:[NSString stringWithFormat:@"%d", intStatusCode]];
        [[self delegate] chatSchdularprocessSuccessful:arrayPara];
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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	connection = nil;
    
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

- (BOOL)testInternetConnection
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    //NSLog(@">>>NetWork Status:%@",[NSString stringWithFormat:@"%u",networkStatus]);
    return !(networkStatus == NotReachable);
}


@end