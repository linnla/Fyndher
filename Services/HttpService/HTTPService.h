

#import <Foundation/Foundation.h>
#import "RequestHeaders.h"

@protocol HTTPServiceDelegate<NSObject>
- (void)didReceiveResponse :(NSData *)data identifier:(NSString *)name;
- (void)serviceDidFailWithError : (NSError *)error identifier:(NSString *)name;
- (void)responseCode:(int)code identifier:(NSString *)name;
@end

typedef enum {
    kRequestMethodGET,
    kRequestMethodPOST,
    kRequestMethodDELETE,
    kRequestMethodPUT,
    kRequestMethodNone
} RequestMethod;

@interface HTTPService : NSObject

@property(nonatomic,retain) NSMutableData *receivedData;
@property(nonatomic, retain) NSURLConnection *connection;
@property(nonatomic,assign) id<HTTPServiceDelegate>delegate;
@property(nonatomic,retain) NSString *serviceURLString;
@property(nonatomic,retain) NSDictionary *headersDictionary;
@property(nonatomic,retain) NSString *bodyString;
@property(nonatomic) BOOL isPOST;
@property(nonatomic) RequestMethod serviceRequestMethod;
@property(nonatomic, retain) NSString *identifier;

- (id)initWithURLString : (NSString *)urlString headers : (NSDictionary *)headers body : (NSString *)body 
               delegate : (id<HTTPServiceDelegate>)serviceDelegate requestMethod : (RequestMethod)requestMethod identifier:(NSString *)name;
- (void)startService;
- (void)cancelHTTPService ;

@end
