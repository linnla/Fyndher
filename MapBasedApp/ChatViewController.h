//
//  ChatViewController.h
//  Fyndher
//
//  Created by Harigharan on 04/04/13.
//  Copyright (c) 2013 Mobile Analytics   All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebAPI.h"
#import "GlobalConstants.h"
#import <iAd/iAd.h>
#import "AQGridView.h"
#import "BannerViewController.h"
#import "ChatWebAPI.h"

@interface ChatViewController : UIViewController< ADBannerViewDelegate,UITextFieldDelegate,UITextViewDelegate, UITableViewDelegate,UITableViewDataSource> {
    
    IBOutlet UIImageView *relatioShipStatus;
    IBOutlet UIImageView *onlineStatus;
    // IBOutlet UITextView *loginedUserProfilename;
    WebAPI *webServices;
    IBOutlet UITextView *text_message_id;
    ChatWebAPI *chatWebServices;
    NSMutableArray* chatUserDetails;
    NSMutableArray* chatMessageDetails;
    NSMutableArray* chatImageDetails;
   // NSTimer* timer;
    NSMutableDictionary* listOfUserIdDetails;
    NSMutableArray* arrayListOfUserIds;
    UIAlertView *alertView;
    int is_GetUnReadMessageRequest_send, isSendMessageRequest_send , isKeyBoardHidden, isRequestSended;
    int is_viewProfileRequset_send, is_ChangeMessageStatusRequest_send, isGet_ChatHistoryRequestSended;
    
    BannerViewController *_bannerViewController;
    CGFloat animatedDistance;
    IBOutlet UITableView *chat_tableview;
    IBOutlet UILabel *messageHint_label;
    int original_Xaxis_value, original_Yaxis_value;
}
@property (nonatomic, retain) NSMutableArray *chatUserDetails;
@property (nonatomic, retain) NSMutableArray *chatMessageDetails;
@property (nonatomic, retain) NSMutableArray *chatImageDetails;

@property (strong, nonatomic) ADBannerView *bannerView;

@end
