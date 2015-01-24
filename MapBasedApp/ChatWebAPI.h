//
//  ChatWebAPI.h
//  Fyndher
//
//  Created by Harigharan on 08/04/13.
//  Copyright (c) 2013 Mobile Analytics   All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChatProcessDataDelegate <NSObject>
@required
- (void)chatSchdularprocessSuccessful:(NSArray *)paraResponse;
- (void)processFail:(NSString *)paraResponse;
@end

@interface ChatWebAPI : NSObject <NSURLConnectionDelegate>
{
    NSMutableData *dataResponse;
    
    int intStatusCode;
    
    BOOL isCookie;
    
    id <ChatProcessDataDelegate> delegate;
    
    NSMutableDictionary *dictSelectedUser;
    
    NSString *strURL;
    UIImage *imgUser;
    UIAlertView *networkStatusAlert, *serverStatusAlert;
}

@property (nonatomic, retain) NSMutableDictionary *dictSelectedUser;
@property (nonatomic, retain) NSString *strURL;
@property (nonatomic, retain) UIImage *imgUser;

@property (retain) id delegate;
@property (strong, nonatomic) NSMutableData *dataResponse;
@property (assign, nonatomic) BOOL isCookie;

+ (id)sharedInstance;



- (void) callAPI : (NSString *)paraAPIName dictionary : (NSDictionary *)paraDict;


@end
