//
//  PhotosViewController.m
//  Fyndher
//
//  Created by Laure Linn on 15/10/12.
//  Copyright (c) 2012 Mobile Analytics   All rights reserved.
//

#import "PhotosViewController.h"
#import "ProfileViewController.h"
#import "RegistrationViewController.h"
#import "ChatViewController.h"
#import "UpdateProfileViewController.h"

#import "GridViewCell.h"
#import "RecentChatGridViewCell.h"
#import "JSON.h"
#import "BannerViewController.h"


@interface PhotosViewController ()
{
    //BannerViewController *_bannerViewController;
}

@end

@implementation PhotosViewController
@synthesize  arrayUsers, favoriteUsers, onlineUsers, recentChatUsers, recentChatMessages, unreadMessageDetails, fileQueue = _fileQueue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        onlineUsers = [NSMutableArray new];
        favoriteUsers = [NSMutableArray new];
        recentChatUsers = [NSMutableArray new];
        recentChatMessages = [NSMutableArray new];
        unreadMessageDetails = [NSMutableArray new];
        
        isNearestUsers = NO;
        isOnlineUsers = NO;
        isFavoriteUsers = NO;
        isRecentChatUsers = NO;
        isRefresh = NO;
        isGetUnreadMessageRequestSend = NO;
        isFinished = NO;
        isViewProfile = NO;
        isGetImageCompleted = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Where should sharedInstance be defined?
    webServices = [WebAPI sharedInstance];
    [webServices setDelegate:self];
    chatWebservices =[ChatWebAPI sharedInstance];
    [chatWebservices setDelegate:self];
    
    // Put this is load data method
    alertView = [[UIAlertView alloc] initWithTitle:@"Please Wait..."
                                           message:@"\n"
                                          delegate:self
                                 cancelButtonTitle:nil
                                 otherButtonTitles:nil];
    
    [alertView show];
    
    // Refactor - Create separate method to control activity indicator, call from load data method
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(139.5, 75.5); // .5 so it doesn't blur
    [alertView addSubview:spinner];
    [spinner startAnimating];
    
    // Refactor
    arrayUsers = [NSMutableArray new];
    
    // Define
    intImageIndex = -1;
    userListStartPosition = 0;
    
    // Refactor - Can this go in the initWithNibName
    /*onlineUsers = [NSMutableArray new];
     favoriteUsers = [NSMutableArray new];
     recentChatUsers = [NSMutableArray new];
     recentChatMessages = [NSMutableArray new];
     unreadMessageDetails = [NSMutableArray new];
     
     isNearestUsers = NO;
     isOnlineUsers = NO;
     isFavoriteUsers = NO;
     isRecentChatUsers = NO;
     isRefresh = NO;
     isGetUnreadMessageRequestSend = NO;
     isFinished = NO;
     isViewProfile = NO;
     isGetImageCompleted = NO;*/
    
    [tableView removeFromSuperview];
    // Original
    //gridView = [[AQGridView alloc] initWithFrame:CGRectMake(0, self.view.frame.origin.y + 45, 320, self.view.frame.size.height -85)];
    
    // Laure - Pictures scrolled over the tab bar buttons after buttons were sized correctly
    //gridView = [[AQGridView alloc] initWithFrame:CGRectMake(0, self.view.frame.origin.y + 45, 320, self.view.frame.size.height -105)];
    
    // Laure Change v2
    // Portrait --- Top bar Height = 45, Bottom Button Height = 60 : 60 + 45 = 105
    // Landscape -- Top bar Height = 32, Bottom Button Height = ?? : ?? + 32 = ???
    
    /*
     // If orientation is landscape
     if (self.view.frame.size.width > self.view.frame.size.height) {
     gridView = [[AQGridView alloc] initWithFrame:CGRectMake(0, 32, self.view.bounds.size.width, self.view.bounds.size.height - 118)];
     } else {
     gridView = [[AQGridView alloc] initWithFrame:CGRectMake(0, 45, self.view.bounds.size.width, self.view.bounds.size.height - 105)];
     }*/
    
    [self createGridView];
    
    // Laure
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(callService) userInfo:nil repeats:NO];
    
    //[NSThread detachNewThreadSelector:@selector(callService) toTarget:self withObject:nil];
    
    isNearestRequestSended = NO;
    isFavouriteRequestSended = NO;
    isOnlineRequestSended = NO;
    isRecentChatRequestSended = NO;
    isRequestsended = YES;
    selectedPosition = -1;
}

-(void)createGridView
{
    gridView = [[AQGridView alloc] initWithFrame:CGRectMake(0, 45, self.view.bounds.size.width, self.view.bounds.size.height - 105)];
    
    gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
   	gridView.autoresizesSubviews = YES;
	gridView.delegate = self;
	gridView.dataSource = self;
    
    [self.view addSubview:gridView];
    
    CGRect frame = tableView.frame;
    frame.origin.x = gridView.frame.origin.x;
    frame.origin.y = gridView.frame.origin.y;
    frame.size.width = gridView.frame.size.width;
    frame.size.height = gridView.frame.size.height;
    tableView.frame = frame;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    // laure.linn 6.16, required of photo doesn't get unhighlighted
    [self->gridView deselectItemAtIndex:self->gridView.indexOfSelectedItem animated:YES];
    
   // NSLog(@">>View will appear method<<");
    // CGRect rect =  CGRectMake(0, self.view.frame.size - 50, 320, 50)
    
    //_bannerView = [[ADBannerView alloc]
    //initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, 320, 0)];
    
    //  _bannerView.delegate = self;
    webServices.delegate = self;
    [chatWebservices setDelegate:self];
    
    if( selectedPosition != -1) {
        //NSLog(@">>Photo: IsFavouriteUser:%d",webServices.isFavouriteUser);
        // NSLog(@">>Photo Online status:%d",webServices.onlineStatus);
        
        [messagecount setTitle:webServices.totalUnreadMessages forState:UIControlStateNormal];
        // NSLog(@"View will appear method Total UnreadMessages:%@",webServices.totalUnreadMessages);
        if( isNearestUsers == YES) {
            
            if (webServices.isFavouriteUser == YES) {
                [[arrayUsers objectAtIndex:selectedPosition] setValue:@"1" forKey:@"favouriteUser"];
            }else
                [[arrayUsers objectAtIndex:selectedPosition] setValue:@"0" forKey:@"favouriteUser"];
            
            if (webServices.onlineStatus == YES) {
                [[arrayUsers objectAtIndex:selectedPosition] setValue:@"1" forKey:@"onlineStatus"];
            }else
                [[arrayUsers objectAtIndex:selectedPosition] setValue:@"0" forKey:@"onlineStatus"];
            
            selectedPosition = -1;
            webServices.isFavouriteUser = NO;
            webServices.onlineStatus = NO;
            [gridView reloadData];
        }else if (isFavoriteUsers == YES ){
            
            if (webServices.isFavouriteUser == NO) {
                [favoriteUsers removeObjectAtIndex:selectedPosition];
                
            }else if (webServices.onlineStatus == YES) {
                [[favoriteUsers objectAtIndex:selectedPosition] setValue:@"1" forKey:@"onlineStatus"];
            }else
                [[favoriteUsers objectAtIndex:selectedPosition] setValue:@"0" forKey:@"onlineStatus"];
            
            selectedPosition = -1;
            webServices.isFavouriteUser = NO;
            webServices.onlineStatus = NO;
            [gridView reloadData];
            
        }else if (isOnlineUsers == YES) {
            
            if (webServices.onlineStatus == YES) {
                [[onlineUsers objectAtIndex:selectedPosition] setValue:@"1" forKey:@"onlineStatus"];
                if (webServices.isFavouriteUser == YES) {
                    [[onlineUsers objectAtIndex:selectedPosition] setValue:@"1" forKey:@"favouriteUser"];
                }else
                    [[onlineUsers objectAtIndex:selectedPosition] setValue:@"0" forKey:@"favouriteUser"];
            }else {
                
                [onlineUsers removeObjectAtIndex:selectedPosition];
            }
            
            selectedPosition = -1;
            webServices.isFavouriteUser = NO;
            webServices.onlineStatus = NO;
            [gridView reloadData];
            
        }
        else if (isRecentChatUsers == YES ){
            
            if (webServices.onlineStatus == YES) {
                [[recentChatUsers objectAtIndex:selectedPosition] setValue:@"1" forKey:@"onlineStatus"];
            }else
                [[recentChatUsers objectAtIndex:selectedPosition] setValue:@"0" forKey:@"onlineStatus"];
            
            if (webServices.isFavouriteUser == YES) {
                [[recentChatUsers objectAtIndex:selectedPosition] setValue:@"1" forKey:@"favouriteUser"];
            }else
                [[recentChatUsers objectAtIndex:selectedPosition] setValue:@"0" forKey:@"favouriteUser"];
            
            webServices.onlineStatus = NO;
            webServices.isFavouriteUser = NO;
            [tableView reloadData];
            selectedPosition = -1;
        }
    }
}

//#pragma mark - GridView Datasource

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
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

-(void)callService
{
    [webServices callAPI:APINEARESTNEIGHBOR dictionary:NULL];
    isNearestRequestSended = YES;
    isRequestsended = YES;
    [self UnSelectButtons];
    isNearestUsers = YES;
    [btAll setImage:[UIImage imageNamed:@"all_tab_active"] forState:UIControlStateNormal];
    
}


- (NSUInteger)numberOfItemsInGridView:(AQGridView *)aGridView {
    
    if( isNearestUsers == YES) {
        if([arrayUsers count] % 3 == 0)
            return ([arrayUsers count]+2);
        else
            return ([arrayUsers count]+1);
    }
    else if (isOnlineUsers == YES ) {
        if([onlineUsers count] %3 == 0)
            return ([onlineUsers count]+2);
        else
            return ([onlineUsers count]+1);
    }
    else if (isFavoriteUsers == YES) {
        if([favoriteUsers count] % 3 == 0)
            return ([favoriteUsers count]+2);
        else
            return ([favoriteUsers count]+1);
    }
    else if (isRecentChatUsers == YES)
        return ([recentChatUsers count]);
    
    return 0;
}

- (CGSize)portraitGridCellSizeForGridView:(AQGridView *)aGridView {
    
    if( isRecentChatUsers == NO ) {
        return (CGSizeMake(105, 134));
    }
    else {
        
        return (CGSizeMake(self.view.frame.size.width, 120));
    }
    
    // return (CGSizeMake(0.0, 0.0));
}

- (AQGridViewCell *)gridView:(AQGridView *)aGridView cellForItemAtIndex:(NSUInteger)index {
    
    
    static NSString * CellIdentifier = @"GridViewCell";
    
    GridViewCell * cell;
    
    cell= (GridViewCell *)[aGridView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( cell == nil ){
        cell = [[GridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 105, 134) reuseIdentifier: CellIdentifier];
        
    }
    
    if( isNearestUsers == YES ) {
        
        if( index >= [arrayUsers count]) {
            [cell.indicator stopAnimating];
            
            if([arrayUsers count] %3 == 0) {
                if( index == [arrayUsers count]) {
                    
                    cell.more_Button.hidden = YES;
                    cell.imgUser.hidden = YES;
                    cell.imgChat.hidden = YES;
                    cell.imgFavorite.hidden = YES;
                    cell.imgOnline.hidden = YES;
                    cell.lbName.hidden = YES;
                    cell.lbMsgCount.hidden = YES;
                    cell.grid_bg.hidden = YES;
                    
                    [cell setSelectionStyle:AQGridViewCellSelectionStyleGray];
                    return cell;
                    
                }else if(index == [arrayUsers count]+1) {
                    
                    cell.more_Button.hidden = NO;
                    [cell.more_Button addTarget:self
                                         action:@selector(getNextListOfUsers)
                               forControlEvents:UIControlEventTouchUpInside];
                    cell.imgUser.hidden = YES;
                    cell.imgChat.hidden = YES;
                    cell.imgFavorite.hidden = YES;
                    cell.imgOnline.hidden = YES;
                    cell.lbName.hidden = YES;
                    cell.lbMsgCount.hidden = YES;
                    cell.grid_bg.hidden = YES;
                    
                    [cell setSelectionStyle:AQGridViewCellSelectionStyleGray];
                    return cell;
                }
                
            }else if(index == [arrayUsers count]){
                
                cell.more_Button.hidden = NO;
                [cell.more_Button addTarget:self
                                     action:@selector(getNextListOfUsers)
                           forControlEvents:UIControlEventTouchUpInside];
                cell.imgUser.hidden = YES;
                cell.imgChat.hidden = YES;
                cell.imgFavorite.hidden = YES;
                cell.imgOnline.hidden = YES;
                cell.lbName.hidden = YES;
                cell.lbMsgCount.hidden = YES;
                cell.grid_bg.hidden = YES;
                
                [cell setSelectionStyle:AQGridViewCellSelectionStyleGray];
                return cell;
                
            }
        }
        else if(index < [arrayUsers count]){
            
            cell.imgUser.hidden = NO;
            cell.imgChat.hidden = NO;
            cell.imgFavorite.hidden = NO;
            cell.imgOnline.hidden = NO;
            cell.lbName.hidden = NO;
            cell.lbMsgCount.hidden = NO;
            cell.grid_bg.hidden = NO;
            cell.more_Button.hidden = YES;
            
            if((NSNull *)[[arrayUsers objectAtIndex:index] valueForKey:@"screenName"] != [NSNull null])
                cell.lbName.text = [[arrayUsers objectAtIndex:index] valueForKey:@"screenName"];
            else
                cell.lbName.text = @" ";
            
            
            if((NSNull *)[[arrayUsers objectAtIndex:index] valueForKey:@"photo"] != [NSNull null]) {
                
                UIImage* image = [webServices readImageValue_ImagePath:[[arrayUsers objectAtIndex:index] valueForKey:@"photo"]];
                if (image != nil) {
                    cell.imgUser.image = image;
                }else
                    cell.imgUser.image = [UIImage imageNamed:@"blank_user.png"];
                
                [cell.indicator stopAnimating];
                
            } else {
                
                cell.imgUser.image = [UIImage imageNamed:@"blank_user.png"];
                
                [cell.indicator stopAnimating];
            }
            
            
            int isOnline = NO;
            
            if (((NSNull *)[[arrayUsers objectAtIndex:index] valueForKey:@"onlineStatus"] != [NSNull null]) && [[[arrayUsers objectAtIndex:index] valueForKey:@"onlineStatus"] intValue] == 1) {
                cell.imgOnline.hidden = NO;
                cell.imgOnline.image = [UIImage imageNamed:@"online.png"];
                isOnline = YES;
            }else
            {
                cell.imgOnline.hidden = YES;
            }
            if(isOnline == NO) {
                CGRect frame = cell.lbMsgCount.frame;
                frame.origin.x = cell.imgOnline.frame.origin.x;
                frame.origin.y = cell.imgOnline.frame.origin.y;
                cell.lbMsgCount.frame = frame;
                
            }else{
                CGRect frame = cell.lbMsgCount.frame;
                //frame.origin.x = 10.00;
                //frame.origin.y = 105.00;
                
                // Laure - Message count not aligning properly
                frame.origin.x = cell.imgOnline.frame.origin.x + 8;
                frame.origin.y = cell.imgOnline.frame.origin.y;
                
                cell.lbMsgCount.frame = frame;
            }
            if(((NSNull *)[[arrayUsers objectAtIndex:index] valueForKey:@"totalUnreadMessages"] != [NSNull null]) && ![[[[arrayUsers objectAtIndex:index] valueForKey:@"totalUnreadMessages"] stringValue] isEqual: @"0"]) {
                
                cell.lbMsgCount.hidden = NO;
                cell.lbMsgCount.background = [UIImage imageNamed:@"grid_chatcount.png"];
                cell.lbMsgCount.text = [[[arrayUsers objectAtIndex:index] valueForKey:@"totalUnreadMessages"] stringValue];
            } else {
                cell.lbMsgCount.hidden = YES;
            }
            [cell.lbMsgCount setEnabled:NO];
            
            
            
            
            if ( ((NSNull *)[[arrayUsers objectAtIndex:index] valueForKey:@"favouriteUser"] != [NSNull null]) && [[[arrayUsers objectAtIndex:index] valueForKey:@"favouriteUser"] intValue] == 1) {
                cell.imgFavorite.hidden = NO;
                cell.imgFavorite.image = [UIImage imageNamed:@"Star.png"];
            }else
                cell.imgFavorite.hidden = YES;
            
            
            cell.more_Button.hidden = YES;
            [cell setSelectionStyle:AQGridViewCellSelectionStyleGray];
            
            return cell;
        }
    }
    else if (isOnlineUsers == YES) {
        
        if( index >= [onlineUsers count]) {
            
            {
                [cell.indicator stopAnimating];
                if([onlineUsers count] %3 == 0) {
                    if( index == [onlineUsers count]) {
                        
                        cell.more_Button.hidden = YES;
                        cell.imgUser.hidden = YES;
                        cell.imgChat.hidden = YES;
                        cell.imgFavorite.hidden = YES;
                        cell.imgOnline.hidden = YES;
                        cell.lbName.hidden = YES;
                        cell.lbMsgCount.hidden = YES;
                        cell.grid_bg.hidden = YES;
                        
                        [cell setSelectionStyle:AQGridViewCellSelectionStyleGray];
                        return cell;
                        
                    }else if(index == [onlineUsers count]+1) {
                        
                        cell.more_Button.hidden = NO;
                        [cell.more_Button addTarget:self
                                             action:@selector(getNextListOfUsers)
                                   forControlEvents:UIControlEventTouchUpInside];
                        cell.imgUser.hidden = YES;
                        cell.imgChat.hidden = YES;
                        cell.imgFavorite.hidden = YES;
                        cell.imgOnline.hidden = YES;
                        cell.lbName.hidden = YES;
                        cell.lbMsgCount.hidden = YES;
                        cell.grid_bg.hidden = YES;
                        
                        [cell setSelectionStyle:AQGridViewCellSelectionStyleGray];
                        return cell;
                    }
                    
                }else if(index == [onlineUsers count]){
                    
                    cell.more_Button.hidden = NO;
                    [cell.more_Button addTarget:self
                                         action:@selector(getNextListOfUsers)
                               forControlEvents:UIControlEventTouchUpInside];
                    cell.imgUser.hidden = YES;
                    cell.imgChat.hidden = YES;
                    cell.imgFavorite.hidden = YES;
                    cell.imgOnline.hidden = YES;
                    cell.lbName.hidden = YES;
                    cell.lbMsgCount.hidden = YES;
                    cell.grid_bg.hidden = YES;
                    
                    [cell setSelectionStyle:AQGridViewCellSelectionStyleGray];
                    return cell;
                    
                }
            }
        }
        else if(index < [onlineUsers count]){
            
            
            cell.imgUser.hidden = NO;
            cell.imgChat.hidden = NO;
            cell.imgFavorite.hidden = NO;
            cell.imgOnline.hidden = NO;
            cell.lbName.hidden = NO;
            cell.lbMsgCount.hidden = NO;
            cell.grid_bg.hidden = NO;
            cell.more_Button.hidden = YES;
            
            if ((NSNull *)[[onlineUsers objectAtIndex:index] valueForKey:@"photo"] != [NSNull null]) {
                
                
                UIImage* image = [webServices readImageValue_ImagePath:[[onlineUsers objectAtIndex:index] valueForKey:@"photo"]];
                
                if (image != nil) {
                    cell.imgUser.image = image;
                }else
                    cell.imgUser.image = [UIImage imageNamed:@"blank_user.png"];
                
                [cell.indicator stopAnimating];
                
            }else {
                cell.imgUser.image = [UIImage imageNamed:@"blank_user.png"];
                
                [cell.indicator stopAnimating];
            }
            
            int isOnline = NO;
            if ( ((NSNull *)[[onlineUsers objectAtIndex:index] valueForKey:@"onlineStatus"] != [NSNull null]) && [[[onlineUsers objectAtIndex:index] valueForKey:@"onlineStatus"] intValue] == 1) {
                cell.imgOnline.hidden = NO;
                cell.imgOnline.image = [UIImage imageNamed:@"online.png"];
                isOnline = YES;
            }else
                cell.imgOnline.hidden = YES;
            
            if(isOnline == NO) {
                CGRect frame = cell.lbMsgCount.frame;
                frame.origin.x = cell.imgOnline.frame.origin.x;
                frame.origin.y = cell.imgOnline.frame.origin.y;
                cell.lbMsgCount.frame = frame;
                
            }else{
                CGRect frame = cell.lbMsgCount.frame;
                //frame.origin.x = 10.00;
                //frame.origin.y = 105.00;
                
                // Laure - Message count not aligning properly
                frame.origin.x = cell.imgOnline.frame.origin.x + 8;
                frame.origin.y = cell.imgOnline.frame.origin.y;
                
                cell.lbMsgCount.frame = frame;
            }
            if (((NSNull *)[[onlineUsers objectAtIndex:index] valueForKey:@"favouriteUser"] != [NSNull null]) && [[[onlineUsers objectAtIndex:index] valueForKey:@"favouriteUser"] intValue] == 1) {
                cell.imgFavorite.hidden = NO;
                cell.imgFavorite.image = [UIImage imageNamed:@"Star.png"];
            }
            else
                cell.imgFavorite.hidden = YES;
            if((NSNull *)[[onlineUsers objectAtIndex:index] valueForKey:@"screenName"] != [NSNull null])
                cell.lbName.text = [[onlineUsers objectAtIndex:index] valueForKey:@"screenName"];
            else
                cell.lbName.text = @" ";
            
            if(((NSNull *)[[onlineUsers objectAtIndex:index] valueForKey:@"totalUnreadMessages"] != [NSNull null])&& ![[[[onlineUsers objectAtIndex:index] valueForKey:@"totalUnreadMessages"] stringValue] isEqual: @"0"]) {
                cell.lbMsgCount.hidden = NO;
                cell.lbMsgCount.background = [UIImage imageNamed:@"grid_chatcount.png"];
                cell.lbMsgCount.text = [[[onlineUsers objectAtIndex:index] valueForKey:@"totalUnreadMessages"] stringValue];
            }
            else
                cell.lbMsgCount.hidden = YES;
            
            [cell.lbMsgCount setEnabled:NO];
            
            [cell setSelectionStyle:AQGridViewCellSelectionStyleGray];
            
            return  cell;
        }
    }
    else if(isFavoriteUsers == YES) {
        
        if( index >= [favoriteUsers count]) {
            [cell.indicator stopAnimating];
            
            if([favoriteUsers count] %3 == 0) {
                if( index == [favoriteUsers count]) {
                    
                    cell.more_Button.hidden = YES;
                    cell.imgUser.hidden = YES;
                    cell.imgChat.hidden = YES;
                    cell.imgFavorite.hidden = YES;
                    cell.imgOnline.hidden = YES;
                    cell.lbName.hidden = YES;
                    cell.lbMsgCount.hidden = YES;
                    cell.grid_bg.hidden = YES;
                    
                    [cell setSelectionStyle:AQGridViewCellSelectionStyleGray];
                    return cell;
                    
                }else if(index == [favoriteUsers count]+1) {
                    
                    cell.more_Button.hidden = NO;
                    [cell.more_Button addTarget:self
                                         action:@selector(getNextListOfUsers)
                               forControlEvents:UIControlEventTouchUpInside];
                    cell.imgUser.hidden = YES;
                    cell.imgChat.hidden = YES;
                    cell.imgFavorite.hidden = YES;
                    cell.imgOnline.hidden = YES;
                    cell.lbName.hidden = YES;
                    cell.lbMsgCount.hidden = YES;
                    cell.grid_bg.hidden = YES;
                    
                    [cell setSelectionStyle:AQGridViewCellSelectionStyleGray];
                    return cell;
                }
                
            }else if(index == [favoriteUsers count]){
                
                cell.more_Button.hidden = NO;
                [cell.more_Button addTarget:self
                                     action:@selector(getNextListOfUsers)
                           forControlEvents:UIControlEventTouchUpInside];
                cell.imgUser.hidden = YES;
                cell.imgChat.hidden = YES;
                cell.imgFavorite.hidden = YES;
                cell.imgOnline.hidden = YES;
                cell.lbName.hidden = YES;
                cell.lbMsgCount.hidden = YES;
                cell.grid_bg.hidden = YES;
                
                [cell setSelectionStyle:AQGridViewCellSelectionStyleGray];
                return cell;
                
            }
        }
        else if(index < [favoriteUsers count]){
            
            
            cell.imgUser.hidden = NO;
            cell.imgChat.hidden = NO;
            cell.imgFavorite.hidden = NO;
            cell.imgOnline.hidden = NO;
            cell.lbName.hidden = NO;
            cell.lbMsgCount.hidden = NO;
            cell.grid_bg.hidden = NO;
            cell.more_Button.hidden = YES;
            
            if((NSNull *)[[favoriteUsers objectAtIndex:index] valueForKey:@"photo"] != [NSNull null]) {
                
                
                UIImage* image = [webServices readImageValue_ImagePath:[[favoriteUsers objectAtIndex:index] valueForKey:@"photo"]];
                if ( image != nil) {
                    cell.imgUser.image = image;
                }else
                    cell.imgUser.image = [UIImage imageNamed:@"blank_user.png"];
                
                [cell.indicator stopAnimating];
                
            }else {
                cell.imgUser.image = [UIImage imageNamed:@"blank_user.png"];
                
                [cell.indicator stopAnimating];
            }
            
            
            int isOnline = NO;
            if (((NSNull *)[[favoriteUsers objectAtIndex:index] valueForKey:@"onlineStatus"] != [NSNull null]) && [[[favoriteUsers objectAtIndex:index] valueForKey:@"onlineStatus"] intValue] == 1) {
                cell.imgOnline.hidden = NO;
                cell.imgOnline.image = [UIImage imageNamed:@"online.png"];
                isOnline = YES;
            }else
                cell.imgOnline.hidden = YES;
            
            if(isOnline == NO) {
                CGRect frame = cell.lbMsgCount.frame;
                frame.origin.x = cell.imgOnline.frame.origin.x;
                frame.origin.y = cell.imgOnline.frame.origin.y;
                cell.lbMsgCount.frame = frame;
                
            }else{
                CGRect frame = cell.lbMsgCount.frame;
                //frame.origin.x = 10.00;
                //frame.origin.y = 105.00;
                
                // Laure - Message count not aligning properly
                frame.origin.x = cell.imgOnline.frame.origin.x + 8;
                frame.origin.y = cell.imgOnline.frame.origin.y;
                
                cell.lbMsgCount.frame = frame;
            }
            
            if (((NSNull *)[[favoriteUsers objectAtIndex:index] valueForKey:@"favouriteUser"] != [NSNull null]) && [[[favoriteUsers objectAtIndex:index] valueForKey:@"favouriteUser"] intValue] == 1) {
                cell.imgFavorite.hidden = NO;
                cell.imgFavorite.image = [UIImage imageNamed:@"Star.png"];
            }else
                cell.imgFavorite.hidden = YES;
            if((NSNull *)[[favoriteUsers objectAtIndex:index] valueForKey:@"screenName"] != [NSNull null])
                cell.lbName.text = [[favoriteUsers objectAtIndex:index] valueForKey:@"screenName"];
            else
                cell.lbName.text = @" ";
            
            
            if(((NSNull *)[[favoriteUsers objectAtIndex:index] valueForKey:@"totalUnreadMessages"] != [NSNull null])&& ![[[[favoriteUsers objectAtIndex:index] valueForKey:@"totalUnreadMessages"] stringValue] isEqual: @"0"]) {
                cell.lbMsgCount.hidden = NO;
                cell.lbMsgCount.background = [UIImage imageNamed:@"grid_chatcount.png"];
                cell.lbMsgCount.text = [[[favoriteUsers objectAtIndex:index] valueForKey:@"totalUnreadMessages"] stringValue];
            }else
                cell.lbMsgCount.hidden= YES;
            
            [cell.lbMsgCount setEnabled:NO];
            
            
            [cell setSelectionStyle:AQGridViewCellSelectionStyleGray];
            return  cell;
        }
    }
    
    
    return  0 ;
}

//#pragma mark - GridView Deleg

- (void)gridView: (AQGridView *)gridView didSelectItemAtIndex:(NSUInteger)index {
    
    selectedPosition = index;
    
    //ujvt[self highlightItemAtIndex:index animated:YES scrollPosition:AQGridViewScrollPositionNone];
    
    webServices.isCallFromProfileView = NO;
    webServices.isCallFromChat = NO;
    ProfileViewController *profileVC;
    if( isNearestUsers == YES && index < [arrayUsers count]) {
        webServices.dictSelectedUser = [arrayUsers objectAtIndex:index];
        
        if ((NSNull *)[[arrayUsers objectAtIndex:index] valueForKey:@"photo"] != [NSNull null])
            webServices.imgUser = [webServices readImageValue_ImagePath:[[arrayUsers objectAtIndex:index] valueForKey:@"photo"]];
        else
            webServices.imgUser = [UIImage imageNamed:@"blank_user.png"];
        
        if (((NSNull *)[[arrayUsers objectAtIndex:index] valueForKey:@"onlineStatus"] != [NSNull null]) && [[[arrayUsers objectAtIndex:index] valueForKey:@"onlineStatus"] intValue] == 1) {
            webServices.onlineStatus = YES;
            
        }else
            webServices.onlineStatus = NO;
        
        profileVC = [ProfileViewController new];
        
        [self presentViewController:profileVC animated:YES completion:NULL];
    }
    else if (isOnlineUsers == YES && index < [onlineUsers count])  {
        webServices.dictSelectedUser = [onlineUsers objectAtIndex:index];
        
        
        if ((NSNull *)[[onlineUsers objectAtIndex:index] valueForKey:@"photo"] != [NSNull null])
            webServices.imgUser = [webServices readImageValue_ImagePath:[[onlineUsers objectAtIndex:index] valueForKey:@"photo"]];
        else
            webServices.imgUser = [UIImage imageNamed:@"blank_user.png"];
        
        if (((NSNull *)[[onlineUsers objectAtIndex:index] valueForKey:@"onlineStatus"] != [NSNull null]) && [[[onlineUsers objectAtIndex:index] valueForKey:@"onlineStatus"] intValue] == 1) {
            webServices.onlineStatus = YES;
            
        }else
            webServices.onlineStatus = NO;
        
        profileVC = [ProfileViewController new];
        [self presentViewController:profileVC animated:YES completion:NULL];
    }
    else if (isFavoriteUsers == YES && index < [favoriteUsers count]) {
        
        webServices.dictSelectedUser = [favoriteUsers objectAtIndex:index];
        
        if ((NSNull *)[[favoriteUsers objectAtIndex:index] valueForKey:@"photo"] != [NSNull null])
            webServices.imgUser = [webServices readImageValue_ImagePath:[[favoriteUsers objectAtIndex:index] valueForKey:@"photo"]];
        else
            webServices.imgUser = [UIImage imageNamed:@"blank_user.png"];
        
        if (((NSNull *)[[favoriteUsers objectAtIndex:index] valueForKey:@"onlineStatus"] != [NSNull null]) && [[[favoriteUsers objectAtIndex:index] valueForKey:@"onlineStatus"] intValue] == 1) {
            webServices.onlineStatus = YES;
            
        }else
            webServices.onlineStatus = NO;
        
        profileVC = [ProfileViewController new];
        [self presentViewController:profileVC animated:YES completion:NULL];
    }
    
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)processSuccessful:(NSArray *)paraResponse
{
    
    userListStartPosition = 0;
    //NSLog(@" >>>>>>>photoview controller Success Response<<<<<");
    
    if( [[paraResponse objectAtIndex:0] intValue] == 200 ) {
        if (isViewProfile == YES && isRequestsended == YES) {
            // NSLog(@">>view profile Response<<");
            isRequestsended = NO;
            webServices.loggedInUserDetails = [paraResponse objectAtIndex:1];
            if ((NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"photo"] != [NSNull null]) {
                
                if(![webServices isFileExists:[[paraResponse objectAtIndex:1] valueForKey:@"photo"]]) {
                    
                    UIImage* image  =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rest/1/file/%@?pixel=100",BASEURL,[[paraResponse objectAtIndex:1] valueForKey:@"photo"]]]]];
                    //intImageIndex = i;
                    if(image != nil) {
                        webServices.loggedInUserImage = image;
                        [webServices writeImageValue_ImagePath:[[paraResponse objectAtIndex:1] valueForKey:@"photo"] imageForUser:webServices.loggedInUserImage];
                    }else
                        webServices.loggedInUserImage = [UIImage imageNamed:@"blank_user.png"];
                }else
                    webServices.loggedInUserImage = [webServices readImageValue_ImagePath:[webServices.loggedInUserDetails valueForKey:@"photo"]];
                
            }else
                webServices.loggedInUserImage = [UIImage imageNamed:@"blank_user.png"];
            
            //NSLog(@"LoggedInUserImage:%@",webServices.loggedInUserImage);
            isViewProfile = NO;
            if (isGetImageCompleted == YES) {
                isGetImageCompleted = NO;
                [alertView dismissWithClickedButtonIndex:0 animated:YES];
            }
            
        }
        else if (isNearestUsers && isRequestsended == YES ) {
            
            isMoreclicked = NO;
            isRequestsended = NO;
            
            if ([paraResponse count] > 1) {
                userListStartPosition = [arrayUsers count];
                
                for (int i = 0; i < [[[paraResponse objectAtIndex:1] valueForKey:@"listOfUserResponse"] count]; i++) {
                    [arrayUsers addObject:[[[paraResponse objectAtIndex:1] valueForKey:@"listOfUserResponse"] objectAtIndex:i]];
                }
                
                if(((NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] != [NSNull null])) {
                    [messagecount setTitle:[[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] stringValue] forState:UIControlStateNormal];
                    webServices.totalUnreadMessages = [[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] stringValue];
                    [UIApplication sharedApplication].applicationIconBadgeNumber = [[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] intValue];
                    webServices.oldMessageCount = [[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] intValue];
                }else {
                    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                    webServices.totalUnreadMessages = @"0";
                    webServices.oldMessageCount = 0;
                }
            }
            
            [NSThread detachNewThreadSelector:@selector(dataThread) toTarget:self withObject:nil];
            if( webServices.loggedInUserDetails == nil) {
                [webServices callAPI:APIVIEWPROFILE dictionary:NULL];
                isViewProfile = YES;
                isRequestsended = YES;
            }else if (webServices.loggedInUserImage == nil) {
                
                if ((NSNull *)[webServices.loggedInUserDetails valueForKey:@"photo"] != [NSNull null]) {
                    
                    if(![webServices isFileExists:[webServices.loggedInUserDetails valueForKey:@"photo"]]) {
                        
                        UIImage* image  =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rest/1/file/%@?pixel=100",BASEURL,[webServices.loggedInUserDetails valueForKey:@"photo"]]]]];
                        //intImageIndex = i;
                        if(image != nil) {
                            webServices.loggedInUserImage = image;
                            [webServices writeImageValue_ImagePath:[[paraResponse objectAtIndex:1] valueForKey:@"photo"] imageForUser:webServices.loggedInUserImage];
                        }else
                            webServices.loggedInUserImage = [UIImage imageNamed:@"blank_user.png"];
                    }else
                        webServices.loggedInUserImage = [webServices readImageValue_ImagePath:[webServices.loggedInUserImage valueForKey:@"photo"]];
                    
                }else
                    webServices.loggedInUserImage = [UIImage imageNamed:@"blank_user.png"];
                
                //NSLog(@"LoggedInUserImage:%@",webServices.loggedInUserImage);
            }
            //NSLog(@"Total UnreadMessages:%@",webServices.totalUnreadMessages);
        }
        else if(isFavoriteUsers && isRequestsended == YES )
        {
            
            isMoreclicked = NO;
            isRequestsended = NO;
            
            if ([paraResponse count] > 1) {
                if( [[[paraResponse objectAtIndex:1] valueForKey:@"listOfUserResponse"] count] > 0) {
                    userListStartPosition = [favoriteUsers count];
                    
                    for (int i = 0; i < [[[paraResponse objectAtIndex:1] valueForKey:@"listOfUserResponse"] count]; i++) {
                        [favoriteUsers addObject:[[[paraResponse objectAtIndex:1] valueForKey:@"listOfUserResponse"] objectAtIndex:i]];
                    }
                    
                    
                    if(((NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] != [NSNull null])) {
                        [messagecount setTitle:[[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] stringValue] forState:UIControlStateNormal];
                        webServices.totalUnreadMessages = [[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] stringValue];
                        [UIApplication sharedApplication].applicationIconBadgeNumber = [[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] intValue];
                        webServices.oldMessageCount = [[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] intValue];
                    }else {
                        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                        webServices.totalUnreadMessages = @"0";
                        webServices.oldMessageCount = 0;
                    }
                    
                    
                    [NSThread detachNewThreadSelector:@selector(dataThread) toTarget:self withObject:nil];
                    
                }
                else if (isFavoriteUsers == YES && isRefresh == NO) {
                    [gridView reloadData];
                    [alertView dismissWithClickedButtonIndex:0 animated:YES];
                    UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:nil
                                                                         message:@"You have not set up any favorites"
                                                                        delegate:self
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil, nil];
                    [alertView1 show];
                }
                else
                    [alertView dismissWithClickedButtonIndex:0 animated:YES];
                
            }
            
        }
        else if (isOnlineUsers && isRequestsended == YES )
        {
            isRequestsended = NO;
            
            isMoreclicked = NO;
            if ([paraResponse count] > 1) {
                if([[[paraResponse objectAtIndex:1] valueForKey:@"listOfUserResponse"] count] > 0) {
                    userListStartPosition = [onlineUsers count];
                    for (int i = 0; i < [[[paraResponse objectAtIndex:1] valueForKey:@"listOfUserResponse"] count]; i++) {
                        [onlineUsers addObject:[[[paraResponse objectAtIndex:1] valueForKey:@"listOfUserResponse"] objectAtIndex:i]];
                    }
                    
                    if(((NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] != [NSNull null])) {
                        [messagecount setTitle:[[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] stringValue] forState:UIControlStateNormal];
                        webServices.totalUnreadMessages = [[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] stringValue];
                        [UIApplication sharedApplication].applicationIconBadgeNumber = [[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] intValue];
                        webServices.oldMessageCount = [[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] intValue];
                    }else {
                        webServices.totalUnreadMessages = @"0";
                        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                        webServices.oldMessageCount = 0;
                    }
                    
                    [NSThread detachNewThreadSelector:@selector(dataThread) toTarget:self withObject:nil];
                    
                    
                }else if (isOnlineUsers == YES && isRefresh == NO) {
                    [gridView reloadData];
                    [alertView dismissWithClickedButtonIndex:0 animated:YES];
                    UIAlertView *alertView1 = [[UIAlertView alloc] initWithTitle:nil
                                                                         message:@"No users are online"
                                                                        delegate:self
                                                               cancelButtonTitle:@"OK"
                                                               otherButtonTitles:nil, nil];
                    [alertView1 show];
                }
                else
                    [alertView dismissWithClickedButtonIndex:0 animated:YES];
                
            }
            
        }else if (isRecentChatUsers && isGetUnreadMessageRequestSend == NO && isRequestsended == YES)
        {
            isRequestsended = NO;
            
            if ([paraResponse count] > 1) {
                
                [recentChatUsers removeAllObjects];
                [recentChatMessages removeAllObjects];
                [unreadMessageDetails removeAllObjects];
                
                if([[[paraResponse objectAtIndex:1] valueForKey:@"listOfRecentChattingUsers"] count] >0) {
                    
                    for (int i = 0; i < [[[paraResponse objectAtIndex:1] valueForKey:@"listOfRecentChattingUsers"] count]; i++) {
                        [recentChatUsers addObject:[[[paraResponse objectAtIndex:1] valueForKey:@"listOfRecentChattingUsers"] objectAtIndex:i]];
                    }
                    
                    
                    for (int i = 0; i<[[[paraResponse objectAtIndex:1] valueForKey:@"listOfRecentMessageDetails"] count]; i++) {
                        [recentChatMessages addObject:[[[paraResponse objectAtIndex:1] valueForKey:@"listOfRecentMessageDetails"] objectAtIndex:i]];
                    }
                    
                    
                    if(((NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] != [NSNull null])) {
                        [messagecount setTitle:[[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] stringValue] forState:UIControlStateNormal];
                        webServices.totalUnreadMessages = [[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] stringValue];
                        [UIApplication sharedApplication].applicationIconBadgeNumber = [[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] intValue];
                        webServices.oldMessageCount = [[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] intValue];
                    }else {
                        webServices.totalUnreadMessages = @"0";
                        webServices.oldMessageCount = 0;
                        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                    }
                    
                    isFinished = NO;
                    
                    [NSThread detachNewThreadSelector:@selector(dataThread) toTarget:self withObject:nil];
                    //[gridView reloadData];
                    [webServices callAPI:APIGETUNREADMESSAGES dictionary: NULL];
                    isGetUnreadMessageRequestSend = YES;
                    isRequestsended = YES;
                    
                }else {
                    [alertView dismissWithClickedButtonIndex:0 animated:YES];
                    
                    if(((NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] != [NSNull null])) {
                        [messagecount setTitle:[[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] stringValue] forState:UIControlStateNormal];
                        [UIApplication sharedApplication].applicationIconBadgeNumber = [[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] intValue];
                        webServices.oldMessageCount = [[[paraResponse objectAtIndex:1] valueForKey:@"loggedInUserTotalUnReadMessages"] intValue];
                    }else {
                        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                        webServices.oldMessageCount = 0;
                    }
                    
                    [tableView reloadData];
                    UIAlertView*  alertView1 = [[UIAlertView alloc] initWithTitle:nil
                                                                          message:@"No Chat History"
                                                                         delegate:self
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil, nil];
                    [alertView1 show];
                }
                
            }
        }
        else if (isGetUnreadMessageRequestSend && isRequestsended == YES) {
            isRequestsended = NO;
            
            if([paraResponse count] > 1 && [[paraResponse objectAtIndex:0] intValue] == 200 ) {
                
                for (int i=0; i < [[paraResponse objectAtIndex:1] count]; i++) {
                    [unreadMessageDetails addObject:[[paraResponse objectAtIndex:1] objectAtIndex:i]];
                }
                
            }
            isGetUnreadMessageRequestSend = NO;
            if( isFinished == YES) {
                [alertView dismissWithClickedButtonIndex:0 animated:YES];
            }
            [tableView reloadData];
        }
        
    }
    else if([[paraResponse objectAtIndex:0] intValue] == 204 && isRequestsended==YES)
    {
        isRequestsended = NO;
        
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        UIAlertView* alertView1;
        
        // NEW --- error message for more button not required except for favorites
        if (isFavoriteUsers == YES && isRefresh == NO && isMoreclicked == NO) {
            alertView1 = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"You have not set up any favorites"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
            [alertView1 show];
        } else if (isViewProfile == YES) {
            isViewProfile = NO;
        } else
            isMoreclicked = NO;
        
        
        
        
    }else if ([[paraResponse objectAtIndex:0] intValue] >= 400 && [[paraResponse objectAtIndex:0] intValue] < 500 && isRequestsended == YES) {
        
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        isRequestsended = NO;
        
        [webServices callAPI:APILOGOUT dictionary:NULL];
        [webServices stopUpdateLocationThread];
        [webServices writeSessionId:@"null"];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
        webServices.isLoginViewControllerCalled = YES;
        // RegistrationViewController *profileVC = [RegistrationViewController new];
        // [self presentViewController:profileVC animated:YES completion:NULL];
        [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
        
        //[self dismissViewControllerAnimated:YES completion:NULL];
    }
    
    
}

- (void)processFail:(NSString *)paraResponse
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    
    if (isViewProfile == YES) {
        isViewProfile = NO;
        
    }
    isRequestsended = NO;
    
}



-(void)dataThread
{
    
    if(isNearestUsers) {
        
        for (int i = userListStartPosition; i < [arrayUsers count]; i++) {
            
            UIImage *image;
            
            if ((NSNull *)[[arrayUsers objectAtIndex:i] valueForKey:@"photo"] != [NSNull null]) {
                
                if(![webServices isFileExists:[[arrayUsers objectAtIndex:i] valueForKey:@"photo"]]) {
                    
                    image =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rest/1/file/%@?pixel=100",BASEURL,[[arrayUsers objectAtIndex:i] valueForKey:@"photo"]]]]];
                    //intImageIndex = i;
                    [webServices writeImageValue_ImagePath:[[arrayUsers objectAtIndex:i] valueForKey:@"photo"] imageForUser:image];
                }
                
            }
            
            
        }
        isGetImageCompleted = YES;
        [gridView reloadData];
    }
    else if (isFavoriteUsers)
    {
        
        for (int i = userListStartPosition; i < [favoriteUsers count]; i++) {
            UIImage *image;
            
            if ((NSNull *)[[favoriteUsers objectAtIndex:i] valueForKey:@"photo"] != [NSNull null]) {
                
                if(![webServices isFileExists:[[favoriteUsers objectAtIndex:i] valueForKey:@"photo"]]) {
                    
                    image =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rest/1/file/%@?pixel=100",BASEURL,[[favoriteUsers objectAtIndex:i] valueForKey:@"photo"]]]]];
                    [webServices writeImageValue_ImagePath:[[favoriteUsers objectAtIndex:i] valueForKey:@"photo"] imageForUser:image];
                }
                
            }
            
        }
        
        [gridView reloadData];
    }
    else if (isOnlineUsers)
    {
        
        
        for (int i = userListStartPosition; i < [onlineUsers count]; i++) {
            UIImage *image;
            if ((NSNull *)[[onlineUsers objectAtIndex:i] valueForKey:@"photo"] != [NSNull null]) {
                
                if(![webServices isFileExists:[[onlineUsers objectAtIndex:i] valueForKey:@"photo"]]) {
                    
                    image =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rest/1/file/%@?pixel=100",BASEURL,[[onlineUsers objectAtIndex:i] valueForKey:@"photo"]]]]];
                    [webServices writeImageValue_ImagePath:[[onlineUsers objectAtIndex:i] valueForKey:@"photo"] imageForUser:image];
                }
                
            }
            
            
        }
        
        [gridView reloadData];
    }
    else if (isRecentChatUsers)
    {
        
        for (int i = 0; i < [recentChatUsers count]; i++) {
            UIImage *image;
            if ((NSNull *)[[recentChatUsers objectAtIndex:i] valueForKey:@"photo"] != [NSNull null]) {
                
                if(![webServices isFileExists:[[recentChatUsers objectAtIndex:i] valueForKey:@"photo"]]) {
                    
                    image =[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/rest/1/file/%@?pixel=100",BASEURL, [[recentChatUsers objectAtIndex:i] valueForKey:@"photo"]]]]];
                    //intImageIndex = i;
                    [webServices writeImageValue_ImagePath:[[recentChatUsers objectAtIndex:i] valueForKey:@"photo"] imageForUser:image];
                }
            }
            
        }
        
        isFinished = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            //all you ever do with UIKit.. in your case the reloadData call
            [tableView reloadData];
        });
        
    }
    if (isViewProfile == NO && isGetUnreadMessageRequestSend == NO) {
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        isGetImageCompleted = NO;
        
    }
}


- (void)viewDidUnload {
    [super viewDidUnload];
}
- (IBAction)ClickButton:(id)sender {
    [alertView show];
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    
    if( isRecentChatUsers == YES  && [sender tag] != 14) {
        
        [tableView removeFromSuperview];
        
        if( orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight )
        {
            CGRect tableFrame = gridView.frame;
            //tableFrame.size.height = 100.00;
            tableFrame.size.height = 195.00;
            tableFrame.size.width = 480.00;
            gridView.frame = tableFrame;
            
        }
        else{
            CGRect tableFrame = gridView.frame;
            
            if ([UIScreen mainScreen].bounds.size.height == 568.f)
            {
                tableFrame.size.height = 440.00;
            } else {
                //tableFrame.size.height = 350.00;
                tableFrame.size.height = 355.00;
            }
            
            tableFrame.size.width = 320.00;
            gridView.frame = tableFrame;
        }
        [self.view addSubview:gridView];
        
        
    }else if (isRecentChatUsers == NO && [sender tag] == 14) {
        [gridView removeFromSuperview];
        
        if( orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight )
        {
            CGRect tableFrame = tableView.frame;
            //tableFrame.size.height = 100.00;
            tableFrame.size.height = 195.00;
            tableFrame.size.width = 480.00;
            tableView.frame = tableFrame;
            
            
        }
        else{
            CGRect tableFrame = tableView.frame;
            
            if ([UIScreen mainScreen].bounds.size.height == 568.f)
            {
                tableFrame.size.height = 438.00;
            } else {
                //tableFrame.size.height = 350.00;
                tableFrame.size.height = 355.00;
            }
            
            //tableFrame.size.height = 373.00;
            //tableFrame.size.height = 360.00;
            
            tableFrame.size.width = 320.00;
            tableView.frame = tableFrame;
        }
        
        [self.view addSubview:tableView];
        
    }
    
    if([sender tag] != 15 ) {
        
        [self UnSelectButtons];
        
    }
    
    if([sender tag] == 11 ) {
        
        isNearestUsers = YES;
        
        [btAll setImage:[UIImage imageNamed:@"all_tab_active"] forState:UIControlStateNormal];
        
        if( isNearestRequestSended == NO) {
            isNearestRequestSended = YES;
            [webServices callAPI:APINEARESTNEIGHBOR dictionary:NULL];
            isRequestsended = YES;
            isRefresh = NO;
            [arrayUsers removeAllObjects];
            [gridView reloadData];
        }
        else {
            [gridView reloadData];
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        }
    }
    else if ([sender tag] == 12  ){
        
        isFavoriteUsers = YES;
        [btFavorite setImage:[UIImage imageNamed:@"favorites_active"] forState:UIControlStateNormal];
        
        if(isFavouriteRequestSended == NO) {
            isFavouriteRequestSended = YES;
            NSMutableDictionary *dictParam = [NSMutableDictionary new];
            [dictParam setValue:@"FAVOURITE" forKey:@"relationshipType"];
            [webServices callAPI:APIFAVORITEUSERDETAILS dictionary:dictParam];
            isRequestsended = YES;
            isRefresh = NO;
            [favoriteUsers removeAllObjects];
            [gridView reloadData];
        }
        else{
            [gridView reloadData];
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        }
    }
    else if([sender tag] == 13 ) {
        [btOnline setImage:[UIImage imageNamed:@"online_active"] forState:UIControlStateNormal];
        isOnlineUsers = YES;
        if( isOnlineRequestSended == NO ) {
            isOnlineRequestSended = YES;
            [webServices callAPI:APIONLINEUSERS dictionary:NULL];
            isRequestsended = YES;
            isRefresh = NO;
            [onlineUsers removeAllObjects];
            [gridView reloadData];
        }
        else {
            [gridView reloadData];
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        }
    }
    else if ([sender tag] == 14 ) {
        isRecentChatUsers = YES;
        
        [btChat setImage:[UIImage imageNamed:@"chats_active"] forState:UIControlStateNormal];
        
        if( isRecentChatRequestSended == NO) {
            isRecentChatRequestSended = YES;
            
            [recentChatUsers removeAllObjects];
            [recentChatMessages removeAllObjects];
            [unreadMessageDetails removeAllObjects];
            
            /* if( orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight )
             {
             CGRect tableFrame = tableView.frame;
             tableFrame.size.height = 213.00;
             tableFrame.size.width = 480.00;
             tableView.frame = tableFrame;
             
             }*/
            
            [webServices callAPI:APIGETRECENTCHATTINGUSER dictionary:NULL];
            isRequestsended = YES;
            isRefresh = NO;
        }
        else {
            [tableView reloadData];
            [alertView dismissWithClickedButtonIndex:0 animated:YES];
        }
    }
    else
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
}
- (IBAction)logout:(id)sender {
    
    [webServices callAPI:APILOGOUT dictionary:NULL];
    [webServices stopUpdateLocationThread];
    [webServices writeSessionId:@"null"];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    webServices.isLoginViewControllerCalled = YES;
    // RegistrationViewController *profileVC = [RegistrationViewController new];
    // [self presentViewController:profileVC animated:YES completion:NULL];
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}
- (IBAction)refresh:(id)sender {
    [alertView show];
    
    isRefresh = YES;
    isMoreclicked = NO;
    
    if(isNearestUsers == YES) {
        [arrayUsers removeAllObjects];
        
        [webServices callAPI:APINEARESTNEIGHBOR dictionary:NULL];
        isRequestsended = YES;
        [gridView reloadData];
    }
    else if (isFavoriteUsers == YES ) {
        [favoriteUsers removeAllObjects];
        
        NSMutableDictionary *dictParam = [NSMutableDictionary new];
        [dictParam setValue:@"FAVOURITE" forKey:@"relationshipType"];
        [webServices callAPI:APIFAVORITEUSERDETAILS dictionary:dictParam];
        isRequestsended = YES;
        [gridView reloadData];
        
    }
    else if (isOnlineUsers == YES ) {
        
        [onlineUsers removeAllObjects];
        [webServices callAPI:APIONLINEUSERS dictionary:NULL];
        isRequestsended = YES;
        [gridView reloadData];
        
    }
    else if (isRecentChatUsers == YES) {
        
        [recentChatUsers removeAllObjects];
        [recentChatMessages removeAllObjects];
        [unreadMessageDetails removeAllObjects];
        [webServices callAPI:APIGETRECENTCHATTINGUSER dictionary:NULL];
        isRequestsended = YES;
        [tableView reloadData];
    }
    
    else
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)UnSelectButtons
{
    isNearestUsers = NO;
    isFavoriteUsers = NO;
    isOnlineUsers = NO;
    isRecentChatUsers = NO;
    [btAll setImage:[UIImage imageNamed:@"all_normal"] forState:UIControlStateNormal];
    [btFavorite setImage:[UIImage imageNamed:@"favorites_normal"] forState:UIControlStateNormal];
    [btOnline setImage:[UIImage imageNamed:@"online_normal"] forState:UIControlStateNormal];
    [btChat setImage:[UIImage imageNamed:@"chats_normal"] forState:UIControlStateNormal];
    
}
- (IBAction)starRecentChatActivity:(id)sender {
    
    [self UnSelectButtons];
    isRecentChatUsers = YES;
    [alertView show];
    [gridView removeFromSuperview];
    [self.view addSubview:tableView];
    
    [btChat.imageView setImage:[UIImage imageNamed:@"chats_active"]];
    [recentChatUsers removeAllObjects];
    
    [recentChatMessages removeAllObjects];
    [unreadMessageDetails removeAllObjects];
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    
    
    if( orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight )
    {
        
        CGRect tableFrame = tableView.frame;
        //tableFrame.size.height = 100.00;
        tableFrame.size.height = 195.00;
        tableFrame.size.width = 480.00;
        tableView.frame = tableFrame;
        
        
    }
    else{
        CGRect tableFrame = tableView.frame;
        
        if ([UIScreen mainScreen].bounds.size.height == 568.f)
        {
            tableFrame.size.height = 438.00;
        } else {
            //tableFrame.size.height = 350.00;
            tableFrame.size.height = 355.00;
        }
        
        //tableFrame.size.height = 373.00;
        //tableFrame.size.height = 360.00;
        
        tableFrame.size.width = 320.00;
        tableView.frame = tableFrame;
    }
    [webServices callAPI:APIGETRECENTCHATTINGUSER dictionary:NULL];
    isRequestsended = YES;
    isRefresh = NO;
    [tableView reloadData];
    isRecentChatRequestSended = YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return NO;
}

-  (NSInteger)tableView:(UITableView *)tableView
  numberOfRowsInSection:(NSInteger)section
{
    return [recentChatUsers count];
}
-(UITableViewCell *)tableView:(UITableView *)
tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int index = indexPath.row;
    
    static NSString *identifer = @"RecentChatGridViewCell";
    
    RecentChatGridViewCell *cell = [tableView1 dequeueReusableCellWithIdentifier:identifer];
    
    if(cell == nil) {
        cell = [[RecentChatGridViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: identifer] ;
    }
    
    CGRect frame1 = cell.frame;
    frame1.size.height = 115.00;
    cell.frame = frame1;
    
    CGRect frame = cell.recentchat_bg.frame;
    frame.size.height = 110.00;
    cell.recentchat_bg.frame=frame;
    
    if ( isFinished == YES)  {
        
        if((NSNull *)[[recentChatUsers objectAtIndex:index] valueForKey:@"photo"] != [NSNull null]) {
            
            UIImage* image = [webServices readImageValue_ImagePath:[[recentChatUsers objectAtIndex:index] valueForKey:@"photo"]];
            if ( image != nil) {
                cell.userimage.image = image;
            }else
                cell.userimage.image = [UIImage imageNamed:@"blank_user.png"];
            
            
        }else
            cell.userimage.image = [UIImage imageNamed:@"blank_user.png"];
    }else
        cell.userimage.image = [UIImage imageNamed:@"blank_user.png"];
    cell.screenName.text = [[recentChatUsers objectAtIndex:index] valueForKey:@"screenName"];
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    
    [cell.screenName sizeToFit];
    
    CGRect textViewFrame;
    if( orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight )
    {
        if( cell.screenName.frame.size.width > 220.00)
        {
            textViewFrame = cell.screenName.frame;
            textViewFrame.size.width = 220.00;
            cell.screenName.frame = textViewFrame;
        }
    }else if( cell.screenName.frame.size.width > 160.00) {
        textViewFrame = cell.screenName.frame;
        textViewFrame.size.width = 160.00;
        cell.screenName.frame = textViewFrame;
    }
    
    cell.relationshipStats.frame = CGRectMake(CGRectGetMaxX(cell.screenName.frame), cell.relationshipStats.frame.origin.y, cell.relationshipStats.frame.size.width, cell.relationshipStats.frame.size.height);
    
    //cell.onlineStatus.frame = CGRectMake(CGRectGetMaxX(cell.relationshipStats.frame)-10.00, cell.onlineStatus.frame.origin.y, cell.onlineStatus.frame.size.width, cell.onlineStatus.frame.size.height);
    
    // Laure - Trying to fix chat list fav and online icon alignment
    cell.onlineStatus.frame = CGRectMake(CGRectGetMaxX(cell.relationshipStats.frame), cell.onlineStatus.frame.origin.y, cell.onlineStatus.frame.size.width, cell.onlineStatus.frame.size.height);
    
    if ( ((NSNull *)[[recentChatUsers objectAtIndex:index] valueForKey:@"onlineStatus"] != [NSNull null]) && [[[recentChatUsers objectAtIndex:index] valueForKey:@"onlineStatus"] intValue] == 1) {
        cell.onlineStatus.hidden = NO;
        cell.onlineStatus.image = [UIImage imageNamed:@"online.png"];
    }
    else
        cell.onlineStatus.hidden = YES;
    
    
    if ( ((NSNull *)[[recentChatUsers objectAtIndex:index] valueForKey:@"favouriteUser"] != [NSNull null]) && [[[recentChatUsers objectAtIndex:index] valueForKey:@"favouriteUser"] intValue] == 1) {
        cell.relationshipStats.hidden = NO;
        cell.relationshipStats.image = [UIImage imageNamed:@"star.png"];
    }
    else
        cell.relationshipStats.hidden = YES;
    
    cell.recentChatMessage.text = @"";
    
    
    for (int i=0; i<[recentChatMessages count]; i++) {
        
        if(([[[recentChatMessages objectAtIndex:i] valueForKey:@"senderId"] intValue] == [[[recentChatUsers objectAtIndex:index] valueForKey:@"userId"] intValue]) || ([[[recentChatMessages objectAtIndex:i] valueForKey:@"receiverId"] intValue] == [[[recentChatUsers objectAtIndex:index] valueForKey:@"userId"] intValue]))
        {
            
            cell.recentChatMessage.text = [cell.recentChatMessage.text stringByAppendingString:[[recentChatMessages objectAtIndex:i] valueForKey:@"messageText"]];
            cell.recentChatMessage.text = [cell.recentChatMessage.text stringByAppendingFormat:@"\n"];
        }
    }
    
    int unReadMsgCount = 0;
    for (int i=0; i < [unreadMessageDetails count]; i++) {
        
        if (([[[unreadMessageDetails objectAtIndex:i] valueForKey:@"senderId"] intValue] == [[[recentChatUsers objectAtIndex:index] valueForKey:@"userId"] intValue]) && ([[[unreadMessageDetails objectAtIndex:i] valueForKey:@"messageStatus"] isEqual: @"UNREAD"])) {
            unReadMsgCount++;
        }
    }
    if( unReadMsgCount != 0)
    {
        NSString *string = [NSString stringWithFormat:@"%d", unReadMsgCount];
        cell.messageCount.hidden = NO;
        [cell.messageCount setBackground:[UIImage imageNamed:@"grid_chatcount.png"]];
        [cell.messageCount setText:string];
        cell.messageCount.enabled = NO;
    }
    else {
        cell.messageCount.hidden = YES;
        cell.messageCount.enabled = NO;
    }
    cell.gotoChat.tag = index;
    //[cell.gotoChat addTarget:self
    //                 action:@selector(callChatController:)
    //       forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfileView:)];
    // if labelView is not set userInteractionEnabled, you must do so
    [cell.userimage setUserInteractionEnabled:YES];
    gesture.numberOfTapsRequired = 1;
    gesture.numberOfTouchesRequired = 1;
    cell.userimage.tag = index;
    [cell.userimage addGestureRecognizer:gesture];
    
    
    UITapGestureRecognizer *gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callChatController:)];
    [cell.recentChatMessage setUserInteractionEnabled:YES];
    gesture1.numberOfTapsRequired = 1;
    gesture1.numberOfTouchesRequired = 1;
    cell.recentChatMessage.tag = index;
    [cell.recentChatMessage addGestureRecognizer:gesture1];
    
    [cell.gotoChat setUserInteractionEnabled:YES];
    [cell.gotoChat addGestureRecognizer:gesture1];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@">>Height for row at indexpath method<<");
    return  115.00;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@">>Table view didSelectRowAtIndexPath method<<");
    // NSLog(@">>selected position:%d",indexPath.row);
    selectedPosition = indexPath.row;
    webServices.isCallFromProfileView = NO;
    webServices.isCallFromChat = NO;
    
    [self showChatView];
    
}


-(void)showProfileView:(UIGestureRecognizer*)gestureRecognizer {
    //NSLog(@">>Show profile method<<");
    int index = gestureRecognizer.view.tag;
    // NSLog(@">>Index:%d",index);
    selectedPosition = index;
    webServices.isCallFromProfileView = NO;
    webServices.isCallFromChat = NO;
    
    if( index < [recentChatUsers count]) {
        webServices.dictSelectedUser = [recentChatUsers objectAtIndex:index];
        
        if ((NSNull *)[[recentChatUsers objectAtIndex:index] valueForKey:@"photo"] != [NSNull null])
            webServices.imgUser = [webServices readImageValue_ImagePath:[[recentChatUsers objectAtIndex:index] valueForKey:@"photo"]];
        else
            webServices.imgUser = [UIImage imageNamed:@"blank_user.png"];
        
        if (((NSNull *)[[recentChatUsers objectAtIndex:index] valueForKey:@"onlineStatus"] != [NSNull null]) && [[[recentChatUsers objectAtIndex:index] valueForKey:@"onlineStatus"] intValue] == 1) {
            webServices.onlineStatus = YES;
            
        }else
            webServices.onlineStatus = NO;
        
        
        ProfileViewController *profileVC = [ProfileViewController new];
        
        [self presentViewController:profileVC animated:YES completion:NULL];
    }
}

-(void)callChatController:(UIGestureRecognizer*)gestureRecognizer
{
    //NSLog(@">>Call chat Controller method<<");
    //UIButton *clicked = (UIButton *) sender;
    webServices.isCallFromProfileView = NO;
    webServices.isCallFromChat = NO;
    
    selectedPosition = gestureRecognizer.view.tag;
    
    [self showChatView];
}
-(void)showChatView {
    
    if( selectedPosition < [recentChatUsers count]) {
        
        webServices.dictSelectedUser = [recentChatUsers objectAtIndex:selectedPosition];
        
        
        if ((NSNull *)[[recentChatUsers objectAtIndex:selectedPosition] valueForKey:@"photo"] != [NSNull null])
            webServices.imgUser = [webServices readImageValue_ImagePath:[[recentChatUsers objectAtIndex:selectedPosition] valueForKey:@"photo"]];
        else
            webServices.imgUser = [UIImage imageNamed:@"blank_user.png"];
        
        
        
        if (((NSNull *)[[recentChatUsers objectAtIndex:selectedPosition] valueForKey:@"onlineStatus"] != [NSNull null]) && [[[recentChatUsers objectAtIndex:selectedPosition] valueForKey:@"onlineStatus"] intValue] == 1) {
            webServices.onlineStatus = YES;
            
        }else
            webServices.onlineStatus = NO;
        
        if ( ((NSNull *)[[recentChatUsers objectAtIndex:selectedPosition] valueForKey:@"favouriteUser"] != [NSNull null]) && [[[recentChatUsers objectAtIndex:selectedPosition] valueForKey:@"favouriteUser"] intValue] == 1) {
            webServices.isFavouriteUser = YES;
        }
        else
            webServices.isFavouriteUser = NO;
        
        
        ChatViewController *chatVC = [ChatViewController new];
        [self presentViewController:chatVC animated:YES completion:NULL];
        
        for (int i=0; i<[unreadMessageDetails count]; i++) {
            
            if (([[[unreadMessageDetails objectAtIndex:i] valueForKey:@"senderId"] intValue] == [[[recentChatUsers objectAtIndex:selectedPosition] valueForKey:@"userId"] intValue]) && ([[[unreadMessageDetails objectAtIndex:i] valueForKey:@"messageStatus"] isEqual: @"UNREAD"])) {
                
                [[unreadMessageDetails objectAtIndex:i] setValue:@"READ" forKey:@"messageStatus"];
            }
        }
        
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView1 commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        int index = indexPath.row;
        NSMutableDictionary *dictParam = [NSMutableDictionary new];
        
        if(index < [recentChatUsers count]) {
            
            int messageCountForParticularUser = 0;
            for (int i=0; i<[unreadMessageDetails count]; i++) {
                
                if (([[[unreadMessageDetails objectAtIndex:i] valueForKey:@"senderId"] intValue] == [[[recentChatUsers objectAtIndex:index] valueForKey:@"userId"] intValue]) && ([[[unreadMessageDetails objectAtIndex:i] valueForKey:@"messageStatus"] isEqual: @"UNREAD"])) {
                    
                    [[unreadMessageDetails objectAtIndex:i] setValue:@"READ" forKey:@"messageStatus"];
                    messageCountForParticularUser++;
                }
            }
            //NSLog(@"Message for Particular User:%d",messageCountForParticularUser);
            if( messageCountForParticularUser>0)
            {
                webServices.totalUnreadMessages = [NSString stringWithFormat:@"%d",[webServices.totalUnreadMessages intValue] - messageCountForParticularUser];
                if ([webServices.totalUnreadMessages intValue] > 0) {
                    [messagecount setTitle:webServices.totalUnreadMessages forState:UIControlStateNormal];
                }else
                    [messagecount setTitle:@"0" forState:UIControlStateNormal];
            }
            //NSLog(@"Total unread messages:%@",webServices.totalUnreadMessages);
            
            [dictParam setValue:[[recentChatUsers objectAtIndex:index] valueForKey:@"userId"] forKey:@"toFromUserId"];
            [recentChatUsers removeObjectAtIndex:index];
            //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView reloadData];
            
            [chatWebservices callAPI:APIDELETEPARTICULARUSERCHATHISTORY dictionary:dictParam];
        }
        
        
    }
}

-(void)chatSchdularprocessSuccessful:(NSArray*) paraResponse {
    
    //  NSLog(@">>Photoview chat schdular process successfull method<<");
    
}
- (NSString *)tableView:(UITableView *)tableView
titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Delete";
}
- (IBAction)updateProfile:(id)sender {
    if( webServices.loggedInUserDetails != nil && (NSNull *)[webServices.loggedInUserDetails valueForKey:@"photo"] != [NSNull null])
        webServices.loggedInUserImage = [webServices readImageValue_ImagePath:[webServices.loggedInUserDetails valueForKey:@"photo"]];
    else
        webServices.loggedInUserImage = [UIImage imageNamed:@"blank_user.png"];
    
    UpdateProfileViewController *updateProfileVC = [UpdateProfileViewController new];
    [self presentViewController:updateProfileVC animated:YES completion:NULL];
    
}

-(void)getNextListOfUsers
{
    
    
    [alertView show];
    isMoreclicked = YES;
    
    
    
    if( isNearestUsers == YES ) {
        [webServices callAPI:APINEXTNEARESTUSERS dictionary:NULL];
        isNearestUsers = YES;
        isRequestsended = YES;
        
    }
    else if (isFavoriteUsers == YES) {
        [webServices callAPI:APIGETMOREFAVORITEUSERDETAILS dictionary:NULL];
        isFavoriteUsers = YES;
        isRequestsended = YES;
    }
    else if (isOnlineUsers == YES) {
        [webServices callAPI:APISEARCHNEXTNEARESTONLINEUSERS dictionary:NULL];
        isOnlineUsers = YES;
        isRequestsended = YES;
    }else
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    
}
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    if(isRecentChatUsers == NO)
        [gridView reloadData];
    else
        [tableView reloadData];
    
}
//All Comment method in WebApi.m
/*-(void)writeImageValue_ImagePath:(NSString*)imagepath imageForUser:(UIImage*) image {
 
 NSLog(@">>Write Image method<<");
 if (image != nil)
 {
 NSError* error;
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
 NSUserDomainMask, YES);
 NSString *documentsDirectory = [paths objectAtIndex:0];
 NSString* path = [documentsDirectory stringByAppendingPathComponent:@"imageFolder"];
 if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
 [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error];
 
 }
 path = [path stringByAppendingPathComponent:imagepath];
 
 // laure.linn 6.16 Faster than png save
 //NSData* data = UIImagePNGRepresentation(image);
 NSData* data = UIImageJPEGRepresentation(image, 1);
 
 BOOL isWritten = [data writeToFile:path atomically:YES];
 NSLog(@">>IsWritten:%d",isWritten);
 
 
 }
 }
 
 -(id)readImageValue_ImagePath:(NSString*) imagePath
 {
 NSLog(@">>>Read image method<<");
 if(imagePath != NULL) {
 
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
 NSUserDomainMask, YES);
 NSString *documentsDirectory = [paths objectAtIndex:0];
 NSString* path = [documentsDirectory stringByAppendingPathComponent:@"imageFolder"];
 path = [path stringByAppendingPathComponent:imagePath];
 
 UIImage* image = [UIImage imageWithContentsOfFile:path];
 return image;
 
 }
 return  NULL;
 
 }
 -(BOOL)isFileExists:(NSString*) imagePath
 {
 if( imagePath != NULL) {
 
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
 NSUserDomainMask, YES);
 NSString *documentsDirectory = [paths objectAtIndex:0];
 NSString* path = [documentsDirectory stringByAppendingPathComponent:@"imageFolder"];
 path = [path stringByAppendingPathComponent:imagePath];
 NSLog(@">>IsFileExists:%d",[[NSFileManager defaultManager] fileExistsAtPath:path]);
 NSLog(@">>File Path:%@",path);
 return [[NSFileManager defaultManager] fileExistsAtPath:path];
 
 }
 return NO;
 }*/
@end
