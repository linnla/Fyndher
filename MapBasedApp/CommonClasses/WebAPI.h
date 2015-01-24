//
//  WebAPI.h
//  Fyndher
//
//  Created by Laure Linn on 03/11/12.
//  Copyright (c) 2012 Mobile Analytics   All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol ProcessDataDelegate <NSObject>
@required
- (void)processSuccessful:(NSArray *)paraResponse;
- (void)processFail:(NSString *)paraResponse;
//-(void)emptyResponse:(NSString *) paraResponse;
@end



@interface WebAPI : NSObject <NSURLConnectionDelegate, CLLocationManagerDelegate>
{
    NSMutableData *dataResponse;
    
    int intStatusCode, oldMessageCount ;
    NSString* totalUnreadMessages;
    // int isChangeMessageStatusRequest, isUnReadMessageRequest, viewProfileRequest, sendMessageRequest;
    int isLogoutRequestsend;
    
    BOOL isCookie, isNewUserRegistered,isLoginViewControllerCalled, isFavouriteUser, onlineStatus, isCallFromProfileView, isCallFromChat, isBackFromChat , isBlockedUser;
    
    id <ProcessDataDelegate> delegate;
    NSTimer* locationUpdateTimer, *chatReplyTimer;
    NSMutableDictionary *dictSelectedUser, *loggedInUserDetails;
    CLLocationManager* locationManager;
    NSString *strURL, *sessionId;
    UIImage *imgUser,*loggedInUserImage;
    UIAlertView *networkStatusAlert, *serverStatusAlert;
    UIAlertView *messageAlertView;
}

@property (nonatomic, retain) NSMutableDictionary *dictSelectedUser, *loggedInUserDetails;
@property (nonatomic, retain) NSTimer *locationUpdateTimer, *chatReplyTimer;
@property (nonatomic, retain) NSString* totalUnreadMessages, *sessionId;

@property (nonatomic, retain) NSString *strURL;
@property (nonatomic, retain) UIImage *imgUser, *loggedInUserImage;
@property (assign, nonatomic) int oldMessageCount;

@property (retain) id delegate;
@property (strong, nonatomic) NSMutableData *dataResponse;
@property (assign, nonatomic) BOOL isCookie, isLoginViewControllerCalled, isFavouriteUser, onlineStatus, isCallFromProfileView, isCallFromChat, isBackFromChat, isBlockedUser;

+ (id)sharedInstance;


- (void) updateUserLocation : (CLLocation *)newLocation;

-(void)startUpdateLocationThread;
-(void)stopUpdateLocationThread;
-(NSString*)readSessionId;
-(void)writeSessionId : (NSString*) sessionValue;
-(void)callLocationUpdate;
- (void) callAPI : (NSString *)paraAPIName dictionary : (NSDictionary *)paraDict;
-(void)startBackgroundLocationUpdate;
-(void)stopBackgroundLocationUpdate;
-(void)writeImageValue_ImagePath:(NSString*) imagePath imageForUser:(UIImage*) image;
-(BOOL)isFileExists:(NSString*) imagePath;
-(id)readImageValue_ImagePath:(NSString*) imagePath;
@end
