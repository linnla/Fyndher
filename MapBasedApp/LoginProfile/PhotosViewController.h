//
//  PhotosViewController.h
//  Fyndher
//
//  Created by Laure Linn on 15/10/12.
//  Copyright (c) 2012 Mobile Analytics   All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "AQGridView.h"
#import "WebAPI.h"
#import "GlobalConstants.h"
#import <CoreLocation/CoreLocation.h>
#import "ChatWebAPI.h"



@interface PhotosViewController : UIViewController<AQGridViewDelegate, AQGridViewDataSource, ADBannerViewDelegate,UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate>{
    
    IBOutlet UITableView *tableView;
    AQGridView * gridView, * recentChatGridView;
    
    IBOutlet UIButton *messagecount;
    WebAPI *webServices;
    ChatWebAPI *chatWebservices;
    NSMutableArray *arrayUsers;
    NSMutableArray *onlineUsers;
    NSMutableArray *favoriteUsers;
    NSMutableArray *recentChatUsers;
    NSMutableArray *recentChatMessages;
    NSMutableArray *unreadMessageDetails;
    
    NSTimer* locationUpdateTimer;
    
    int intImageIndex, userListStartPosition, isNearestRequestSended, isFavouriteRequestSended , isOnlineRequestSended, isRecentChatRequestSended, isRequestsended, isFinished, isViewProfile , isGetImageCompleted;
    
    IBOutlet UISegmentedControl *segment;
    BOOL isMoreclicked;
    
    IBOutlet UIButton *btAll, *btFavorite, *btOnline, *btChat;
    int selectedPosition;
    UIAlertView *alertView;
    
    BOOL isNearestUsers, isOnlineUsers, isFavoriteUsers, isRecentChatUsers , isRefresh, isGetUnreadMessageRequestSend;
}

@property (nonatomic, retain) NSMutableArray *arrayUsers;
@property (nonatomic, retain) NSMutableArray *onlineUsers;
@property (nonatomic, retain) NSMutableArray *favoriteUsers;
@property (nonatomic, retain) NSMutableArray *recentChatUsers;
@property (nonatomic, retain) NSMutableArray *recentChatMessages;
@property (nonatomic, retain) NSMutableArray *unreadMessageDetails;

@property (strong, nonatomic) ADBannerView *bannerView;
@property (nonatomic, readonly) dispatch_queue_t fileQueue;


- (IBAction)ClickButton:(id)sender;
-(void)UnSelectButtons;



@end
