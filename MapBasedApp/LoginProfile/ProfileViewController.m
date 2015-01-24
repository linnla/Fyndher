//
//  ProfileViewController.m
//  Fyndher
//
//  Created by Laure Linn on 25/09/12.
//  Copyright (c) 2012 Mobile Analytics   All rights reserved.
//
#import <math.h>
#import "GlobalConstants.h"
#import "ProfileViewController.h"
#import "RegistrationViewController.h"

#import "GridViewCell.h"
#import "UpdateProfileViewController.h"
#import "ChatViewController.h"
#import "ReportViewController.h"

#import "JSON.h"

#import "WebAPI.h"

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@">>Profile view controller viewdidload method<<");
    self.title = @"Friends";
    
    webServices = [WebAPI sharedInstance];
    [webServices setDelegate:self];
    webServices.isFavouriteUser = NO;
    webServices.isBlockedUser = NO;
    isBlockedUser = NO;
    isFavouriteUser = NO;
    btFavorite.hidden = YES;
    btBlock.hidden = YES;
    
    alertView = [[UIAlertView alloc] initWithTitle:@"Please Wait..."
                                           message:@"\n"
                                          delegate:self
                                 cancelButtonTitle:nil
                                 otherButtonTitles:nil];
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(139.5, 75.5); // .5 so it doesn't blur
    [alertView addSubview:spinner];
    [spinner startAnimating];
    [alertView show];
    
    [NSThread detachNewThreadSelector:@selector(showUserDetails) toTarget:self withObject:nil];
    
    
}

-(void) showUserDetails {
    
    if ((NSNull *)[webServices.dictSelectedUser valueForKey:@"photo"] != [NSNull null]) {
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/rest/1/file/%@?pixel=%d",BASEURL,[webServices.dictSelectedUser valueForKey:@"photo"],300]];
        //NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/rest/1/file/%@",BASEURL,[webServices.dictSelectedUser valueForKey:@"photo"]]];
        
        // ll 6.16
        NSLog(@"ProfileViewController imageWithData START");
        UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
        
        // How does it perform wo image lookup? --- We need to cache the images on disk --- this was way faster!!!
        //UIImage* image = [UIImage imageWithContentsOfFile:@"Default.png"];
        NSLog(@"ProfileViewController imageWithData END");
        
        if( image != nil) {
            imgViewProfile.image = image;
        }else if(webServices.imgUser != nil)
            imgViewProfile.image = webServices.imgUser;
        else
            imgViewProfile.image = [UIImage imageNamed:@"blank_user.png"];
        //imgViewProfile.image = webServices.imgUser;
        
    }else{
        imgViewProfile.image = [UIImage imageNamed:@"blank_user.png"];
    }
    
    
    preferences = [NSUserDefaults standardUserDefaults];
    favouriteUserList = [NSMutableArray new];
    BlockedUserList = [NSMutableArray new];
    
    for (int i = 0; i < [[preferences valueForKey:KEYFAVORITEUSERS] count]; i++) {
        [favouriteUserList addObject:[[preferences valueForKey:KEYFAVORITEUSERS] objectAtIndex:i]];
    }
    for (int i = 0; i < [[preferences valueForKey:KEYBLOCKEDUSERS] count]; i++) {
        [BlockedUserList addObject:[[preferences valueForKey:KEYBLOCKEDUSERS] objectAtIndex:i]];
    }
    if (webServices.loggedInUserDetails != nil && (NSNull *)[webServices.dictSelectedUser valueForKey:@"screenName"] != [NSNull null]) {
        loginedUserScreenName.text = [webServices.loggedInUserDetails valueForKey:@"screenName"];
    }
    
    
    for (int i = 0; i < [[preferences valueForKey:KEYFAVORITEUSERS] count]; i++) {
        
        if ([[[preferences valueForKey:KEYFAVORITEUSERS] objectAtIndex:i] isEqual:[webServices.dictSelectedUser valueForKey:@"userId"]] ) {
            btFavorite.selected = YES;
            isFavouriteUser = YES;
            btFavorite.hidden = NO;
            btBlock.hidden = YES;
            webServices.isFavouriteUser = YES;
            
            break;
        }
    }
    
    if( isFavouriteUser == NO ) {
        for (int i = 0; i < [[preferences valueForKey:KEYBLOCKEDUSERS] count]; i++) {
            if ([[[preferences valueForKey:KEYBLOCKEDUSERS] objectAtIndex:i] isEqual:[webServices.dictSelectedUser valueForKey:@"userId"]] ) {
                btBlock.selected = YES;
                isBlockedUser = YES;
                btBlock.hidden = NO;
                btFavorite.hidden = YES;
                webServices.isBlockedUser = YES;
                break;
            }
        }
    }
    if( isBlockedUser == NO && isFavouriteUser == NO ) {
        btFavorite.hidden = NO;
        btBlock.hidden = NO;
    }
    //NSLog(@"User Details : %@", webServices.dictSelectedUser);
    
    if([[webServices.dictSelectedUser valueForKey:@"onlineStatus"] intValue] == 1) {
        onlineStatus.hidden = NO;
        [onlineStatus setImage:[UIImage imageNamed:@"online"]];
    }
    else
        onlineStatus.hidden = YES;
    
    if(((NSNull *)[webServices.dictSelectedUser valueForKey:@"screenName"] != [NSNull null]) && ![[[webServices.dictSelectedUser valueForKey:@"screenName"] stringByReplacingOccurrencesOfString:@" " withString:@""] isEqual: @""]) {
        attributeDescription.text = @"\t\t";
        attributeDescription.text = [attributeDescription.text stringByAppendingString:@"ScreenName:"];
        attributeValueDescription.text = [webServices.dictSelectedUser valueForKey:@"screenName"] ;
        attributeDescription.text = [attributeDescription.text stringByAppendingFormat:@"\n"];
        attributeValueDescription.text = [attributeValueDescription.text stringByAppendingFormat:@"\n"];
    }
    attributeDescription.text = [attributeDescription.text stringByAppendingFormat:@"\t\t"];
    attributeDescription.text =[attributeDescription.text stringByAppendingString:@"Distance:"];
    
    long distanceInMeters = [[webServices.dictSelectedUser valueForKey:@"distance"] longValue];
    double distanceInFeet = distanceInMeters * 3.28084;
    
    if( distanceInFeet > 6000 ) {
        
        double distanceInMiles = distanceInMeters * 0.000621371;
        //NSString* distanceValue = [NSString stringWithFormat:@"%.2f",distanceInMiles];
        
        int myInt = (int)distanceInMiles;
        
        if (myInt < 2) {
            attributeValueDescription.text = [attributeValueDescription.text stringByAppendingFormat:@"%d\t mile away",myInt];
        } else {
            attributeValueDescription.text = [attributeValueDescription.text stringByAppendingFormat:@"%d\t miles away",myInt];
        }
        
        
        //double integerValue;
        //float remainder = modf([distanceValue doubleValue], &integerValue);
        
        //NSString* formatedIntegerValue = [NSString stringWithFormat:@"%.0f",integerValue];
        
        // laure.linn 6.16 --- want to drop digits from miles away, commented this out
        /*NSString* formatedRemainderValue = [NSString stringWithFormat:@"%.2f",remainder];
         
         if([formatedRemainderValue isEqualToString:@"0.00"])
         attributeValueDescription.text =[attributeValueDescription.text stringByAppendingString:formatedIntegerValue];
         
         else if([formatedRemainderValue doubleValue] < 0.25 ) {
         attributeValueDescription.text =[attributeValueDescription.text stringByAppendingString:formatedIntegerValue];
         }
         else if( [formatedRemainderValue doubleValue] >=0.25 && [formatedRemainderValue doubleValue] <0.50)
         attributeValueDescription.text =[attributeValueDescription.text stringByAppendingFormat:@"%@.%d\t",formatedIntegerValue,25];
         
         else if( [formatedRemainderValue doubleValue] >=0.50 && [formatedRemainderValue doubleValue] <0.75)
         attributeValueDescription.text =[attributeValueDescription.text stringByAppendingFormat:@"%@.%d",formatedIntegerValue,50];
         
         else if( [formatedRemainderValue doubleValue] >=0.75 && [formatedRemainderValue doubleValue] <1.00)
         attributeValueDescription.text =[attributeValueDescription.text stringByAppendingFormat:@"%@.%d",formatedIntegerValue,75];*/
        
        // laure.linn 6.16 --- want to drop digits from miles away, added this line
        //attributeValueDescription.text =[attributeValueDescription.text stringByAppendingString:formatedIntegerValue];
        
        //attributeValueDescription.text = [attributeValueDescription.text stringByAppendingFormat:@"\tmiles away"];
        
        
    }else{
        //laure.linn 6.19 -- drop decimals, this else may be redundant, same as above
        //attributeValueDescription.text = [attributeValueDescription.text stringByAppendingFormat:@"%.0f\t feet away",distanceInFeet];
        int myInt = (int)distanceInFeet;
        attributeValueDescription.text = [attributeValueDescription.text stringByAppendingFormat:@"%d\t feet away",myInt];
    }
    
    if(((NSNull *)[webServices.dictSelectedUser valueForKey:@"ageRange"] != [NSNull null]) && ![[webServices.dictSelectedUser valueForKey:@"ageRange"] isEqual: @"Do not display"]) {
        attributeDescription.text = [attributeDescription.text stringByAppendingFormat:@"\n\t\t"];
        attributeDescription.text =[attributeDescription.text stringByAppendingString:@"Age:"];
        
        attributeValueDescription.text = [attributeValueDescription.text stringByAppendingFormat:@"\n"];
        
        attributeValueDescription.text =[attributeValueDescription.text stringByAppendingString:[webServices.dictSelectedUser valueForKey:@"ageRange"]];
    }
    
    
    if(((NSNull *)[webServices.dictSelectedUser valueForKey:@"sexualOrientationEnum"] != [NSNull null]) && ![[webServices.dictSelectedUser valueForKey:@"sexualOrientationEnum"] isEqual: @"Do not display"]) {
        attributeDescription.text = [attributeDescription.text stringByAppendingFormat:@"\n\t\t"];
        attributeDescription.text =[attributeDescription.text stringByAppendingString:@"Interests:"];
        
        attributeValueDescription.text = [attributeValueDescription.text stringByAppendingFormat:@"\n"];
        
        attributeValueDescription.text =[attributeValueDescription.text stringByAppendingString:[webServices.dictSelectedUser valueForKey:@"sexualOrientationEnum"]];
    }
    
    
    if(((NSNull *)[webServices.dictSelectedUser valueForKey:@"race"] != [NSNull null]) && ![[webServices.dictSelectedUser valueForKey:@"race"] isEqual: @"Do not display"]) {
        attributeDescription.text = [attributeDescription.text stringByAppendingFormat:@"\n\t\t"];
        attributeDescription.text =[attributeDescription.text stringByAppendingString:@"Race:"];
        
        attributeValueDescription.text = [attributeValueDescription.text stringByAppendingFormat:@"\n"];
        
        attributeValueDescription.text =[attributeValueDescription.text stringByAppendingString:[webServices.dictSelectedUser valueForKey:@"race"] ];
    }
    
    
    if(((NSNull *)[webServices.dictSelectedUser valueForKey:@"relationshipStatus"] != [NSNull null]) && ![[webServices.dictSelectedUser valueForKey:@"relationshipStatus"] isEqual: @"Do not display"]) {
        attributeDescription.text = [attributeDescription.text stringByAppendingFormat:@"\n\t\t"];
        attributeDescription.text =[attributeDescription.text stringByAppendingString:@"Currently:"];
        
        attributeValueDescription.text = [attributeValueDescription.text stringByAppendingFormat:@"\n"];
        
        attributeValueDescription.text =[attributeValueDescription.text stringByAppendingString:[webServices.dictSelectedUser valueForKey:@"relationshipStatus"]];
        
    }
    
    
    
    if(((NSNull *)[webServices.dictSelectedUser valueForKey:@"seekingConnectionList"] != [NSNull null]) && [[webServices.dictSelectedUser valueForKey:@"seekingConnectionList"] count] >0 ) {
        
        if(!([[webServices.dictSelectedUser valueForKey:@"seekingConnectionList"] count] == 1  && [[[webServices.dictSelectedUser valueForKey:@"seekingConnectionList"] objectAtIndex:0] isEqualToString:@"Do not display"])) {
            
            attributeDescription.text = [attributeDescription.text stringByAppendingFormat:@"\n\t\t"];
            
            attributeDescription.text = [attributeDescription.text stringByAppendingString:@"Looking For:"];
            
            attributeValueDescription.text = [attributeValueDescription.text stringByAppendingFormat:@"\n"];
            int count = 0;
            for (int i=0; i< [[webServices.dictSelectedUser valueForKey:@"seekingConnectionList"] count]; i++) {
                count++;
                
                if(![[[webServices.dictSelectedUser valueForKey:@"seekingConnectionList"] objectAtIndex:i] isEqual: @"Do not display"] && count == [[webServices.dictSelectedUser valueForKey:@"seekingConnectionList"] count])
                {
                    attributeValueDescription.text = [attributeValueDescription.text stringByAppendingString:[[webServices.dictSelectedUser valueForKey:@"seekingConnectionList"] objectAtIndex:i]];
                    
                    if(((NSNull *)[webServices.dictSelectedUser valueForKey:@"education"] != [NSNull null]) && [[webServices.dictSelectedUser valueForKey:@"education"] isEqual: @"Do not display"] && (((NSNull *)[webServices.dictSelectedUser valueForKey:@"employmentType"] != [NSNull null]) && [[webServices.dictSelectedUser valueForKey:@"employmentType"] isEqual: @"Do not display"]))
                        attributeDescription.text = [attributeDescription.text stringByAppendingFormat:@"\n"];
                    
                }
                else if(![[[webServices.dictSelectedUser valueForKey:@"seekingConnectionList"] objectAtIndex:i] isEqual: @"Do not display"])
                {
                    attributeValueDescription.text = [attributeValueDescription.text stringByAppendingString:[[webServices.dictSelectedUser valueForKey:@"seekingConnectionList"] objectAtIndex:i]];
                    if(![[[webServices.dictSelectedUser valueForKey:@"seekingConnectionList"] objectAtIndex:i+1] isEqual: @"Do not display"]) {
                        attributeValueDescription.text = [attributeValueDescription.text stringByAppendingString:@","];
                        attributeValueDescription.text = [attributeValueDescription.text stringByAppendingFormat:@"\n"];
                        attributeDescription.text = [attributeDescription.text stringByAppendingFormat:@"\n"];
                    }
                    
                }
            }
        }
    }
    
    if(((NSNull *)[webServices.dictSelectedUser valueForKey:@"education"] != [NSNull null]) && ![[webServices.dictSelectedUser valueForKey:@"education"] isEqual: @"Do not display"]) {
        attributeDescription.text = [attributeDescription.text stringByAppendingFormat:@"\n\t\t"];
        attributeDescription.text =[attributeDescription.text stringByAppendingString:@"Education:"];
        
        attributeValueDescription.text = [attributeValueDescription.text stringByAppendingFormat:@"\n"];
        
        attributeValueDescription.text =[attributeValueDescription.text stringByAppendingString:[webServices.dictSelectedUser valueForKey:@"education"]];
    }
    
    
    if(((NSNull *)[webServices.dictSelectedUser valueForKey:@"employmentType"] != [NSNull null]) && ![[webServices.dictSelectedUser valueForKey:@"employmentType"] isEqual: @"Do not display"]) {
        attributeDescription.text = [attributeDescription.text stringByAppendingFormat:@"\n\t\t"];
        attributeDescription.text =[attributeDescription.text stringByAppendingString:@"Employment:"];
        
        attributeValueDescription.text = [attributeValueDescription.text stringByAppendingFormat:@"\n"];
        
        attributeValueDescription.text =[attributeValueDescription.text stringByAppendingString:[webServices.dictSelectedUser valueForKey:@"employmentType"]];
    }
    // CGRect screenRect = [[UIScreen mainScreen] bounds];
    //CGFloat screenWidth = screenRect.size.width;
    //CGFloat screenHeight = screenRect.size.height;
    
    CGFloat imageHeight = imgViewProfile.bounds.size.height;
    
    CGRect labelFrame = attributeValueDescription.frame;
    labelFrame.size = [attributeValueDescription.text sizeWithFont:attributeValueDescription.font
                                                 constrainedToSize:CGSizeMake(attributeValueDescription.frame.size.width, imageHeight+15)
                                                     lineBreakMode:attributeValueDescription.lineBreakMode];
    labelFrame.size.width = 170.00;
    labelFrame.size.height = labelFrame.size.height + 20.00;
    labelFrame.origin.y = imageHeight-labelFrame.size.height+30.00;
    attributeValueDescription.frame = labelFrame;
    
    labelFrame = attributeDescription.frame;
    labelFrame.size = [attributeValueDescription.text sizeWithFont:attributeValueDescription.font
                                                 constrainedToSize:CGSizeMake(attributeValueDescription.frame.size.width, imageHeight+15)
                                                     lineBreakMode:attributeValueDescription.lineBreakMode];
    
    labelFrame.size.width = 130.00;
    labelFrame.size.height = attributeValueDescription.frame.size.height;
    labelFrame.origin.y = attributeValueDescription.frame.origin.y;
    
    attributeDescription.frame = labelFrame;
    textBackgroundImage.image = [UIImage imageNamed:@"profile_attribute_bg.png"];
    
    textBackgroundImage.frame = CGRectMake(attributeDescription.frame.origin.x, attributeDescription.frame.origin.y, 295, attributeValueDescription.frame.size.height);
    
    [attributeValueDescription removeFromSuperview];
    [attributeDescription removeFromSuperview];
    [textBackgroundImage removeFromSuperview];
    
    [self.view addSubview:textBackgroundImage];
    [self.view addSubview:attributeDescription];
    [self.view addSubview:attributeValueDescription];
    
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    //imgViewProfile.alpha = 0.6;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    //  _bannerView = [[ADBannerView alloc]
    // initWithFrame:CGRectMake(0, self.view.frame.size.height - 3, 320, 3)];
    
    //_bannerView.delegate = self;
    webServices.delegate = self;
    if(webServices.onlineStatus == YES) {
        onlineStatus.hidden = NO;
        [onlineStatus setImage:[UIImage imageNamed:@"online"]];
    }else
        onlineStatus.hidden = YES;
    // NSLog(@">>IsBack From chat:%d",webServices.isBackFromChat);
    if( webServices.isBackFromChat == YES) {
        
        btFavorite.selected = NO;
        btBlock.selected = NO;
        btBlock.hidden = YES;
        btFavorite.hidden = YES;
        webServices.isBackFromChat = NO;
        [favouriteUserList removeAllObjects];
        [BlockedUserList removeAllObjects];
        
        for (int i = 0; i < [[preferences valueForKey:KEYFAVORITEUSERS] count]; i++) {
            [favouriteUserList addObject:[[preferences valueForKey:KEYFAVORITEUSERS] objectAtIndex:i]];
        }
        for (int i = 0; i < [[preferences valueForKey:KEYBLOCKEDUSERS] count]; i++) {
            [BlockedUserList addObject:[[preferences valueForKey:KEYBLOCKEDUSERS] objectAtIndex:i]];
        }
        
        isFavouriteUser = NO;
        isBlockedUser = NO;
        btBlock.hidden = YES;
        btFavorite.hidden = YES;
        
        if(webServices.isFavouriteUser) {
            btFavorite.hidden = NO;
            btFavorite.selected = YES;
            btBlock.hidden = YES;
            isFavouriteUser = YES;
            
        }else if (webServices.isBlockedUser) {
            isBlockedUser = YES;
            btBlock.hidden = NO;
            btBlock.selected = YES;
            btFavorite.hidden = YES;
        }else {
            btFavorite.hidden = NO;
            btBlock.hidden = NO;
        }
        
        
        
    }
    
}

#pragma mark - GridView Datasource

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    //    _tableView.tableHeaderView = _bannerView;
    [self.view addSubview:_bannerView];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickBack:(id)sender {
    
    [preferences setValue:favouriteUserList forKey:KEYFAVORITEUSERS];
    [preferences setValue:BlockedUserList forKey:KEYBLOCKEDUSERS];
    [preferences synchronize];
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    //[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)processSuccessful:(NSArray *)paraResponse
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    
    
}
-(void)processFail:(NSString *)paraResponse
{
}

-(IBAction)clickButton:(id)sender
{
    UIButton *btTemp = (UIButton *)sender;
    
    
    
    if ([btTemp tag] == 11) {
        
        if (isFavouriteUser) {
            
            NSMutableDictionary *dictParam = [NSMutableDictionary new];
            [dictParam setValue:[webServices.dictSelectedUser valueForKey:@"userId"] forKey:@"toUserId"];
            [webServices callAPI:APIDELETERELATIONSHIP dictionary:dictParam];
            [favouriteUserList removeObject:[webServices.dictSelectedUser valueForKey:@"userId"]];
            
            webServices.isFavouriteUser = NO;
            btFavorite.hidden = NO;
            btBlock.hidden = NO;
            btFavorite.selected = NO;
            btBlock.selected = NO;
            isFavouriteUser = NO;
            isBlockedUser = NO;
            
        }
        else
        {
            NSMutableDictionary *dictParam = [NSMutableDictionary new];
            [dictParam setValue:[webServices.dictSelectedUser valueForKey:@"userId"] forKey:@"toUserId"];
            [dictParam setValue:@"FAVOURITE" forKey:@"relationshipType"];
            
            [webServices callAPI:APIUPDATERELATIONSHIP dictionary:dictParam];
            
            [favouriteUserList addObject:[webServices.dictSelectedUser valueForKey:@"userId"]];
            isFavouriteUser = YES;
            btBlock.selected = NO;
            btBlock.hidden = YES;
            btFavorite.selected = YES;
            isBlockedUser = NO;
            webServices.isFavouriteUser = YES;
        }
        
        
    }
    else if ([btTemp tag] == 12)
    {
        
        if ( isBlockedUser == NO ) {
            
            NSMutableDictionary *dictParam = [NSMutableDictionary new];
            [dictParam setValue:[webServices.dictSelectedUser valueForKey:@"userId"] forKey:@"toUserId"];
            [dictParam setValue:@"BLOCKED" forKey:@"relationshipType"];
            
            [webServices callAPI:APIUPDATERELATIONSHIP dictionary:dictParam];
            
            [BlockedUserList addObject:[webServices.dictSelectedUser valueForKey:@"userId"]];
            webServices.isBlockedUser = YES;
            isBlockedUser = YES;
            isFavouriteUser = NO;
            btFavorite.selected = NO;
            btFavorite.hidden = YES;
            btBlock.selected = YES;
            
            
        }
        else
        {
            NSMutableDictionary *dictParam = [NSMutableDictionary new];
            [dictParam setValue:[webServices.dictSelectedUser valueForKey:@"userId"] forKey:@"toUserId"];
            [webServices callAPI:APIDELETERELATIONSHIP dictionary:dictParam];
            
            [BlockedUserList removeObject:[webServices.dictSelectedUser valueForKey:@"userId"]];
            isBlockedUser = NO;
            isFavouriteUser = NO;
            btBlock.hidden = NO;
            btFavorite.hidden = NO;
            btBlock.selected = NO;
            btFavorite.selected = NO;
            webServices.isBlockedUser = NO;
            
        }
        
    }
    else if ([btTemp tag] == 13) {
        
        if(webServices.isFavouriteUser)
            [webServices.dictSelectedUser setValue:@"1" forKey:@"favouriteUser"];
        else
            [webServices.dictSelectedUser setValue:@"0" forKey:@"favouriteUser"];
        
        [preferences setValue:favouriteUserList forKey:KEYFAVORITEUSERS];
        [preferences setValue:BlockedUserList forKey:KEYBLOCKEDUSERS];
        [preferences synchronize];
        NSLog(@"Is call from Chat:%d",webServices.isCallFromChat);
        if( webServices.isCallFromChat == YES) {
            webServices.isCallFromChat = NO;
            
            [self dismissViewControllerAnimated:YES completion:NULL];
        }else {
            //webServices.isCallFromProfileView = YES;
            ChatViewController *chatVC = [ChatViewController new];
            [self presentViewController:chatVC animated:YES completion:NULL];
        }
    }
    else if ([btTemp tag] == 14 ) {
        
        ReportViewController *reportVC = [ReportViewController new];
        [self presentViewController:reportVC animated:YES completion:NULL];
    }
    
    
}
- (IBAction)logout:(id)sender {
    [webServices callAPI:APILOGOUT dictionary:NULL];
    [webServices stopUpdateLocationThread];
    [webServices writeSessionId:@"null"];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
   
    if(webServices.chatReplyTimer)
    {
        [webServices.chatReplyTimer invalidate];
        webServices.chatReplyTimer = nil;
        NSLog(@">>Timer is validated<<");
    }
    
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    webServices.isLoginViewControllerCalled = YES;
    //RegistrationViewController *profileVC = [RegistrationViewController new];
    //[self presentViewController:profileVC animated:YES completion:NULL];
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewDidUnload {
    onlineStatus = nil;
    [super viewDidUnload];
}



@end
