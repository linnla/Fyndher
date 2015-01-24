

#import "HTTPService.h"


@implementation HTTPService

@synthesize receivedData,connection ;
@synthesize delegate,serviceURLString,headersDictionary,bodyString,isPOST,serviceRequestMethod ;
@synthesize identifier;
 
- (id)init
{
    return [self initWithURLString:nil headers:nil body:nil delegate:nil requestMethod:kRequestMethodNone identifier:nil];
}

- (id)initWithURLString : (NSString *)urlString headers : (NSDictionary *)headers body : (NSString *)body 
               delegate : (id<HTTPServiceDelegate>)serviceDelegate requestMethod : (RequestMethod)requestMethod identifier:(NSString *)name {
    NSLog(@"URL IN HTTPSERVICE:%@",urlString);
    if (self=[super init]) {
        serviceURLString =urlString ;//[serviceURLString retain] ;
        if(headers == nil) {
            headersDictionary=[RequestHeaders commonHeaders] ;//[headersDictionary retain] ;
        } else {
            headersDictionary = headers;//[headers retain];
        }
        bodyString = body ;//[bodyString retain];
        delegate=serviceDelegate ;
        serviceRequestMethod =requestMethod ;
        identifier = name;
    }
    return self ;
}

- (void)startService { //setup the post request header and body and start connection
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.serviceURLString] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:90];
    
    if (serviceRequestMethod == kRequestMethodPOST) { //set up request type 
       [request setHTTPMethod:@"POST"] ; 
    } else if(serviceRequestMethod == kRequestMethodDELETE) {
        [request setHTTPMethod:@"DELETE"];
    } else if(serviceRequestMethod == kRequestMethodPUT) {
        [request setHTTPMethod:@"PUT"];
    }
    
    if (headersDictionary!=nil) { //setup headers
        NSArray *headerKeys = [self.headersDictionary allKeys];
        
        for (NSString *headerKey in headerKeys) {
            [request setValue:[self.headersDictionary objectForKey:headerKey] forHTTPHeaderField:headerKey];
        }
    }

    if (bodyString!=nil) { //setup body
        [request setHTTPBody:[NSData dataWithBytes:[bodyString UTF8String] length:[bodyString length]]];
    }
    
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];

    if (!self.connection) {
        [self.delegate serviceDidFailWithError:nil identifier:identifier];
    }
}

#pragma mark - NSURLConnection delegate methods

// Only accept self-signed certificates when debugging, and never present the user with a questioin about certificates



//- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
//    
//    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
//    
//    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
//    
//}
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}



- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (self.receivedData==nil) {
        self.receivedData = [[NSMutableData alloc] init];
    }
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.delegate didReceiveResponse:self.receivedData identifier:identifier];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.delegate serviceDidFailWithError:error identifier:identifier];
}


- (void)cancelHTTPService {
    [self.connection cancel] ;
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    
    int code = [httpResponse statusCode];
    if ([self.delegate respondsToSelector:@selector(responseCode:identifier:)]) {
        [self.delegate responseCode:code identifier:identifier];
    }

    
}
#pragma mark -


- (void)dealloc {
  //  [receivedData release];
    delegate = nil;
    //[connection release];
    //[serviceURLString release];
    //[headersDictionary release];
    //[bodyString release];
    //[identifier release];
//    [super dealloc];
}


@end
