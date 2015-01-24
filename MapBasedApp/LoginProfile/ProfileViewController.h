//
//  ProfileViewController.h
//  Fyndher
//
//  Created by Laure Linn on 25/09/12.
//  Copyright (c) 2012 Mobile Analytics   All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebAPI.h"

#import <CoreLocation/CoreLocation.h>
#import <iAd/iAd.h>


@interface ProfileViewController : UIViewController<CLLocationManagerDelegate, ProcessDataDelegate, ADBannerViewDelegate>
{
    
    IBOutlet UIImageView *onlineStatus;
    
    IBOutlet UIImageView *imgViewProfile;
    
    IBOutlet UIImageView *textBackgroundImage;
    NSMutableData *dataResponse;
    
    CLLocationManager *locationManager;
    WebAPI *webServices;
    
    IBOutlet UILabel *loginedUserScreenName;
    IBOutlet UILabel *attributeValueDescription;
    IBOutlet UILabel *attributeDescription;
    int intCount;
    
    IBOutlet UIButton *btBlock;
    IBOutlet UIButton *btFavorite;
    BOOL isFavouriteUser, isBlockedUser;
    
    UIAlertView *alertView;
    NSMutableArray *favouriteUserList, *BlockedUserList;
    NSUserDefaults *preferences;
}

@property (nonatomic, retain) NSArray *photos;
@property (strong, nonatomic) ADBannerView *bannerView;

- (IBAction)clickBack:(id)sender;

-(IBAction)clickButton:(id)sender;

@end
