

#import "RequestHeaders.h"


@implementation RequestHeaders

+(NSDictionary *)commonHeaders {
	
   NSDictionary *headerDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"MyAccessMobile for iOS v.1.0",@"User-Agent", @"application/json", @"Accept", @"application/json", @"Content-Type", nil] ;
    
    return headerDictionary;
}


+(NSDictionary *)commonHeadersForText {
	
    NSDictionary *headerDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"MyAccessMobile for iOS v.1.0",@"User-Agent", @"text/plain", @"Accept", @"application/json", @"Content-Type", nil] ;
    
    return headerDictionary;
}

@end
