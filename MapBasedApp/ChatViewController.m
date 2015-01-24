//
//  ChatViewController.m
//  Fyndher
//
//  Created by Harigharan on 04/04/13.
//  Copyright (c) 2013 Mobile Analytics   All rights reserved.
//

#import "ChatViewController.h"
#import "ChatGridViewCell.h"
#import "ReplyChatGridViewCell.h"
#import "JSON.h"
#import "RegistrationViewController.h"
#import "ProfileViewController.h"

@interface ChatViewController ()
- (IBAction)sendMessage:(id)sender;

@end

@implementation ChatViewController

@synthesize chatUserDetails , chatMessageDetails, chatImageDetails ;
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
    //NSLog(@"view did load method is called");
    // Do any additional setup after loading the view from its nib.
    webServices = [WebAPI sharedInstance];
    [webServices setDelegate:self];
    
    chatWebServices =[ChatWebAPI sharedInstance];
    [chatWebServices setDelegate:self];
    
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
    
    [text_message_id setDelegate:self];
    is_GetUnReadMessageRequest_send = NO;
    chatUserDetails = [NSMutableArray new];
    chatMessageDetails = [NSMutableArray new];
    chatImageDetails = [NSMutableArray new];
    is_viewProfileRequset_send = NO;
    is_ChangeMessageStatusRequest_send = NO;
    isSendMessageRequest_send = NO;
    isKeyBoardHidden = YES;
    isRequestSended = NO;
    isGet_ChatHistoryRequestSended = NO;
    
    
    if( ((NSNull *)[webServices.dictSelectedUser valueForKey:@"onlineStatus"] != [NSNull null]) && [[webServices.dictSelectedUser valueForKey:@"onlineStatus"] intValue] == 1) {
        onlineStatus.hidden = NO;
        [onlineStatus setImage:[UIImage imageNamed:@"online"]];
    }else
        onlineStatus.hidden = YES;
    
    if ( ((NSNull *)[webServices.dictSelectedUser valueForKey:@"favouriteUser"] != [NSNull null]) && [[webServices.dictSelectedUser valueForKey:@"favouriteUser"] intValue] == 1) {
        relatioShipStatus.hidden = NO;
        [relatioShipStatus setImage:[UIImage imageNamed:@"star.png"]];
    }else
        relatioShipStatus.hidden = YES;
    
    [text_message_id setDelegate:self];
    
    messageHint_label.text = @"Enter Message.... ";
    text_message_id.textAlignment = NSTextAlignmentLeft ;
    
    
    //Laure - Added thread
    [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(getLoginedUserDetails) userInfo:nil repeats:NO];
    
    //[NSThread detachNewThreadSelector:@selector(getLoginedUserDetails) toTarget:self withObject:nil];
    
    arrayListOfUserIds = [NSMutableArray new];
    [arrayListOfUserIds addObject:[webServices.dictSelectedUser valueForKey:@"userId"]];
    listOfUserIdDetails= [NSMutableDictionary new];
    [listOfUserIdDetails setValue:arrayListOfUserIds forKey:@"listOfUserIds"];
    
    [chat_tableview setDataSource:self];
    [chat_tableview setDelegate:self];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    // CGRect rect =  CGRectMake(0, self.view.frame.size - 50, 320, 50)
    
    //_bannerView = [[ADBannerView alloc]
    //              initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)];
    
    _bannerView.delegate = self;
    webServices.delegate = self;
    chatWebServices.delegate = self;
    webServices.isCallFromChat = NO;
    [text_message_id setDelegate:self];
    [chat_tableview setDataSource:self];
    [chat_tableview setDelegate:self];
    
    if(webServices.isFavouriteUser && [chatUserDetails count] > 0) {
        [[chatUserDetails objectAtIndex:0] setValue:@"1" forKey:@"favouriteUser"];
        relatioShipStatus.hidden = NO;
        [relatioShipStatus setImage:[UIImage imageNamed:@"star.png"]];
    }
    else if([chatUserDetails count] > 0 ) {
        [[chatUserDetails objectAtIndex:0] setValue:@"0" forKey:@"favouriteUser"];
        relatioShipStatus.hidden = YES;
    }
}

-(void)getParticularUserChatHistory {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setValue:[webServices.dictSelectedUser valueForKey:@"userId"] forKey:@"receiverId"];
    [chatWebServices callAPI:APIGETPARTICULARUSERCHATHISTORY dictionary:dict];
    isGet_ChatHistoryRequestSended = YES;
    isRequestSended = YES;
}
-(void)getLoginedUserDetails {
    
    if ((NSNull *)[webServices.dictSelectedUser valueForKey:@"photo"] != [NSNull null]) {
        
        [chatImageDetails addObject:webServices.imgUser];
    }
    else
        [chatImageDetails addObject:[UIImage imageNamed:@"blank_user.png"]];
    
    [chatUserDetails addObject:webServices.dictSelectedUser];
    
    
    if ( webServices.loggedInUserDetails != nil) {
        
        [chatUserDetails addObject:webServices.loggedInUserDetails];
        if ( webServices.loggedInUserImage != nil) {
            
            [chatImageDetails addObject:webServices.loggedInUserImage];
        }
        else if((NSNull *)[webServices.loggedInUserDetails valueForKey:@"photo"] != [NSNull null]){
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/rest/1/file/%@?pixel=100",BASEURL,[webServices.loggedInUserDetails valueForKey:@"photo"]]];
            webServices.loggedInUserImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            [chatImageDetails addObject: webServices.loggedInUserImage];
        }else {
            [chatImageDetails addObject:[UIImage imageNamed:@"blank_user.png"]];
            webServices.loggedInUserImage = [UIImage imageNamed:@"blank_user.png"];
        }
        
        
        [self getParticularUserChatHistory];
        
    }else {
        [webServices callAPI:APIVIEWPROFILE dictionary:NULL];
        is_viewProfileRequset_send = YES;
    }
}

- (void)processSuccessful:(NSArray *)paraResponse
{
    
    
    int isResponseIsProcessd = NO;
    
    if(is_viewProfileRequset_send == YES && isResponseIsProcessd == NO){
        
        
        if([paraResponse count] > 1 && [[paraResponse objectAtIndex:0] intValue] == 200 ) {
            
            is_viewProfileRequset_send = NO;
            isResponseIsProcessd = YES;
            
            if ((NSNull *)[paraResponse objectAtIndex:1] != [NSNull null]) {
                [chatUserDetails addObject:[paraResponse objectAtIndex:1]];
                webServices.loggedInUserDetails = [paraResponse objectAtIndex:1];
            }
            
            // loginedUserProfilename.text = [[chatUserDetails objectAtIndex:1] valueForKey:@"screenName"];
            
            if ((NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"photo"] != [NSNull null]) {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/rest/1/file/%@?pixel=100",BASEURL,[[paraResponse objectAtIndex:1] valueForKey:@"photo"]]];
                UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                if(image == nil)
                    [chatImageDetails addObject:[UIImage imageNamed:@"blank_user.png"]];
                else
                    [chatImageDetails addObject:image];
                
            }
            else
                [chatImageDetails addObject:[UIImage imageNamed:@"blank_user.png"]];
            
            webServices.loggedInUserImage = [chatImageDetails objectAtIndex:1];
            
            //timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(getReplyMessage) userInfo:nil repeats:YES];
            [self getParticularUserChatHistory];
            
        }
    }
    
    if( isSendMessageRequest_send == YES && isResponseIsProcessd == NO && [[paraResponse objectAtIndex:0] intValue] == 200){
        
        
        // int userId = [[[chatUserDetails objectAtIndex:1] valueForKey:@"userId"] intValue];
        //int senderId= [[[paraResponse objectAtIndex:1] valueForKey:@"senderId"] intValue] ;
        
        if([paraResponse count] >1 && [[paraResponse objectAtIndex:0] intValue] == 200 && (NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"listOfRecentChatDeletedUserIds"] == [NSNull null]) {
            
            isSendMessageRequest_send = NO;
            isResponseIsProcessd = YES;
            
            NSMutableDictionary *dictParam = [NSMutableDictionary new];
            [dictParam setValue:[[paraResponse objectAtIndex:1] valueForKey:@"senderId"] forKey:@"senderId"];
            [dictParam setValue:[[paraResponse objectAtIndex:1] valueForKey:@"receiverId"] forKey:@"receiverId"];
            [dictParam setValue:[[paraResponse objectAtIndex:1] valueForKey:@"messageText"] forKey:@"messageText"];
            
            [dictParam setValue:[[paraResponse objectAtIndex:1] valueForKey:@"creationTime"] forKey:@"creationTime"];
            
            [dictParam setValue:@"sender" forKey:@"isSenderOrReceiver"];
            [chatMessageDetails addObject:dictParam];
            
            // [gridView reloadData];
            // [gridView scrollToItemAtIndex:[chatMessageDetails count]-1 atScrollPosition:([chatMessageDetails count]-1) animated:NO];
            
            messageHint_label.text = @"Enter Message.... ";
            
            
            
        }
        
        [chat_tableview reloadData];
        if([chatMessageDetails count] > 0) {
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([chatMessageDetails count] - 1) inSection:0];
            [chat_tableview scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:(YES)];
        }
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
    
    
    if ([[paraResponse objectAtIndex:0] intValue] >= 400 && [[paraResponse objectAtIndex:0] intValue] < 500) {
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        [webServices callAPI:APILOGOUT dictionary:NULL];
        [webServices stopUpdateLocationThread];
        [webServices writeSessionId:@"null"];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        [self stopChatReplyTimer];
        webServices.isLoginViewControllerCalled = YES;
        // RegistrationViewController *profileVC = [RegistrationViewController new];
        // [self presentViewController:profileVC animated:YES completion:NULL];
        [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
}
-(void)stopChatReplyTimer {
    //NSLog(@">>Stop chat Reply timer<<");
    if(webServices.chatReplyTimer)
    {
        [webServices.chatReplyTimer invalidate];
        webServices.chatReplyTimer = nil;
       // NSLog(@"Timer is invalid");
    }
}
- (void)chatSchdularprocessSuccessful:(NSArray *)paraResponse
{
    //NSLog(@">>Chat schdular process successful method<<");
   // NSLog(@"reply response:%@",[paraResponse objectAtIndex:0]);
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    
    
    if([paraResponse count] > 0 && [[paraResponse objectAtIndex:0] intValue] == 200  && isGet_ChatHistoryRequestSended == YES && isRequestSended == YES ) {
        
        isRequestSended = NO;
        isGet_ChatHistoryRequestSended = NO;
        int isMessageStatusChanged = NO;
        
        
        if([paraResponse count] > 1) {
            
            
            int count = 0;
            for (int i = 0; i<[[paraResponse objectAtIndex:1] count]; i++) {
                count++;
                if( [[[[paraResponse objectAtIndex:1] objectAtIndex:i] valueForKey:@"senderId"] isEqual:[webServices.dictSelectedUser valueForKey:@"userId"]])
                {
                    
                    NSMutableDictionary *dictParam = [NSMutableDictionary new];
                    [dictParam setValue:[[[paraResponse objectAtIndex:1]  objectAtIndex:i] valueForKey:@"senderId"] forKey:@"senderId"];
                    [dictParam setValue:[[[paraResponse objectAtIndex:1]  objectAtIndex:i] valueForKey:@"receiverId"] forKey:@"receiverId"];
                    [dictParam setValue:[[[paraResponse objectAtIndex:1]  objectAtIndex:i] valueForKey:@"messageText"] forKey:@"messageText"];
                    [dictParam setValue:[[[paraResponse objectAtIndex:1]  objectAtIndex:i] valueForKey:@"creationTime"] forKey:@"creationTime"];
                    
                    [dictParam setValue:@"receiver" forKey:@"isSenderOrReceiver"];
                    [chatMessageDetails addObject:dictParam];
                    if(isMessageStatusChanged == NO && [[[[paraResponse objectAtIndex:1] objectAtIndex:i] valueForKey:@"messageStatus"] isEqual:@"UNREAD"]) {
                        
                        NSMutableDictionary *messageStatus = [NSMutableDictionary new];
                        [messageStatus setValue:[[[paraResponse objectAtIndex:1] objectAtIndex:i] valueForKey:@"senderId"] forKey:@"senderId"];
                        [messageStatus setValue:@"READ" forKey:@"messageStatus"];
                        
                        
                        NSString *jsonPostBody = [messageStatus JSONRepresentation];
                        
                        NSURL *url;
                        
                        url = [NSURL URLWithString:[BASEURL stringByAppendingString:@"/rest/1/chat/changeMessageStatus"]];
                        
                        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                           timeoutInterval:180.0];
                        
                        [request setHTTPMethod:@"POST"];
                        
                        [request setHTTPBody:[jsonPostBody dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
                        
                        NSString* postDataLengthString = [[NSString alloc] initWithFormat:@"%d", [[jsonPostBody stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] length]];
                        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                        [request setValue:postDataLengthString forHTTPHeaderField:@"Content-Length"];
                        if([webServices readSessionId] != nil && ![[webServices readSessionId] isEqual: @"null"])
                            [request setValue:[webServices readSessionId] forHTTPHeaderField:@"Cookie"];
                        
                        [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                        // NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                        isMessageStatusChanged = YES;
                        
                    }
                }else{
                    NSMutableDictionary *dictParam = [NSMutableDictionary new];
                    [dictParam setValue:[[[paraResponse objectAtIndex:1]  objectAtIndex:i] valueForKey:@"senderId"] forKey:@"senderId"];
                    [dictParam setValue:[[[paraResponse objectAtIndex:1]  objectAtIndex:i] valueForKey:@"receiverId"] forKey:@"receiverId"];
                    [dictParam setValue:[[[paraResponse objectAtIndex:1]  objectAtIndex:i] valueForKey:@"messageText"] forKey:@"messageText"];
                    [dictParam setValue:[[[paraResponse objectAtIndex:1]  objectAtIndex:i] valueForKey:@"creationTime"] forKey:@"creationTime"];
                    
                    [dictParam setValue:@"sender" forKey:@"isSenderOrReceiver"];
                    [chatMessageDetails addObject:dictParam];
                }
                if(count%5 == 0)
                    [chat_tableview reloadData];
            }
            [chat_tableview reloadData];
            if([chatMessageDetails count] > 0) {
                NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([chatMessageDetails count] - 1) inSection:0];
                [chat_tableview scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:(YES)];
            }
        }
        webServices.chatReplyTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(getReplyMessage) userInfo:nil repeats:YES];
        [self getReplyMessage];
        
    }
    else if([paraResponse count] > 1 && [[paraResponse objectAtIndex:0] intValue] == 200 && isRequestSended == YES && is_GetUnReadMessageRequest_send == YES) {
        isRequestSended = NO;
        is_GetUnReadMessageRequest_send = NO;
        
        int unreadMessagesCount = 0, count = 0;
        BOOL isMessagesIsReceived = NO;
        for (int i = 0; i < [[[paraResponse  objectAtIndex:1] valueForKey:@"listOfUnreadMessageDetails"] count]; i++ ) {
            
            if( [[[[[paraResponse objectAtIndex:1] valueForKey:@"listOfUnreadMessageDetails"] objectAtIndex:i] valueForKey:@"senderId"] isEqual:[webServices.dictSelectedUser valueForKey:@"userId"]]) {
                
                isMessagesIsReceived = YES;
                NSMutableDictionary *dictParam = [NSMutableDictionary new];
                [dictParam setValue:[[[[paraResponse objectAtIndex:1] valueForKey:@"listOfUnreadMessageDetails"] objectAtIndex:i] valueForKey:@"senderId"] forKey:@"senderId"];
                [dictParam setValue:[[[[paraResponse objectAtIndex:1] valueForKey:@"listOfUnreadMessageDetails"] objectAtIndex:i] valueForKey:@"receiverId"] forKey:@"receiverId"];
                [dictParam setValue:[[[[paraResponse objectAtIndex:1] valueForKey:@"listOfUnreadMessageDetails"] objectAtIndex:i] valueForKey:@"messageText"] forKey:@"messageText"];
                [dictParam setValue:[[[[paraResponse objectAtIndex:1] valueForKey:@"listOfUnreadMessageDetails"] objectAtIndex:i] valueForKey:@"creationTime"] forKey:@"creationTime"];
                
                [dictParam setValue:@"receiver" forKey:@"isSenderOrReceiver"];
                [chatMessageDetails addObject:dictParam];
                
                if(count == 0 ) {
                    count = 1;
                    NSMutableDictionary *messageStatus = [NSMutableDictionary new];
                    [messageStatus setValue:[[[[paraResponse objectAtIndex:1] valueForKey:@"listOfUnreadMessageDetails"] objectAtIndex:i] valueForKey:@"senderId"] forKey:@"senderId"];
                    [messageStatus setValue:@"READ" forKey:@"messageStatus"];
                    
                    
                    NSString *jsonPostBody = [messageStatus JSONRepresentation];
                    
                    NSURL *url;
                    
                    url = [NSURL URLWithString:[BASEURL stringByAppendingString:@"/rest/1/chat/changeMessageStatus"]];
                    
                    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                                       timeoutInterval:180.0];
                    
                    [request setHTTPMethod:@"POST"];
                    
                    [request setHTTPBody:[jsonPostBody dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
                    
                    NSString* postDataLengthString = [[NSString alloc] initWithFormat:@"%d", [[jsonPostBody stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding] length]];
                    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    [request setValue:postDataLengthString forHTTPHeaderField:@"Content-Length"];
                    if([webServices readSessionId] != nil && ![[webServices readSessionId] isEqual: @"null"])
                        [request setValue:[webServices readSessionId] forHTTPHeaderField:@"Cookie"];
                    
                    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
                    // NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
                    
                }
            }
            else{
                unreadMessagesCount++;
            }
            
        }
        if( isMessagesIsReceived == YES) {
            
            [chat_tableview reloadData];
            if([chatMessageDetails count] > 0) {
                NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:([chatMessageDetails count] - 1) inSection:0];
                [chat_tableview scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:(YES)];
            }
        }
        
        webServices.totalUnreadMessages = [NSString stringWithFormat:@"%d",unreadMessagesCount];
        
        
        if(unreadMessagesCount > webServices.oldMessageCount) {
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            
            NSDate *now = [NSDate date];
            
            localNotification.fireDate = now;
            localNotification.alertBody = [NSString stringWithFormat:@"New message is received\nInbox count:%d",unreadMessagesCount];
            localNotification.soundName = UILocalNotificationDefaultSoundName;
            localNotification.applicationIconBadgeNumber = unreadMessagesCount; // increment
            localNotification.timeZone = [NSTimeZone defaultTimeZone];
            
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }else if(unreadMessagesCount == 0){
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }
        
        webServices.oldMessageCount = unreadMessagesCount;
        
        if ([paraResponse count] > 1 && (NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"chattingUserDetail"] != [NSNull null] ) {
            
            
            if (((NSNull *)[[[paraResponse objectAtIndex:1] valueForKey:@"chattingUserDetail"] valueForKey:@"onlineStatus"]  != [NSNull null]) && [[[[paraResponse objectAtIndex:1] valueForKey:@"chattingUserDetail"] valueForKey:@"onlineStatus"] intValue] == 1) {
                
                onlineStatus.hidden = NO;
                onlineStatus.image = [UIImage imageNamed:@"online.png"];
                webServices.onlineStatus = YES;
            }
            else {
                onlineStatus.hidden = YES;
                webServices.onlineStatus = NO;
            }
            
            
        }
    }else if (isGet_ChatHistoryRequestSended == YES && isRequestSended == YES) {
        
        webServices.chatReplyTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(getReplyMessage) userInfo:nil repeats:YES];
        [self getReplyMessage];
    }else if ([paraResponse count] > 0 && [[paraResponse objectAtIndex:0] intValue] >= 400 && [[paraResponse objectAtIndex:0] intValue] < 500 && isRequestSended == YES && is_GetUnReadMessageRequest_send == YES) {
        
        [webServices callAPI:APILOGOUT dictionary:NULL];
        [webServices stopUpdateLocationThread];
        [webServices writeSessionId:@"null"];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
        [self stopChatReplyTimer];
        
        webServices.isLoginViewControllerCalled = YES;
        // RegistrationViewController *profileVC = [RegistrationViewController new];
        // [self presentViewController:profileVC animated:YES completion:NULL];
        [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    
}

- (IBAction)back:(id)sender {
    //NSLog(@">>Back method<<");
    [self stopChatReplyTimer];
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    
    webServices.isBackFromChat = YES;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)processFail:(NSString *)paraResponse
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    
    if (isGet_ChatHistoryRequestSended == YES && isRequestSended == YES) {
        isGet_ChatHistoryRequestSended = NO;
        isRequestSended = NO;
        webServices.chatReplyTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(getReplyMessage) userInfo:nil repeats:YES];
        [self getReplyMessage];
    }
    
}

-(void)getReplyMessage {
    
    NSMutableDictionary *dictParam = [NSMutableDictionary new];
    [dictParam setValue:[webServices.dictSelectedUser valueForKey:@"userId"] forKey:@"receiverId"];
    [chatWebServices callAPI:APIGETUNREADMESSAGESANDCHATTINGUSERDETAILS dictionary:dictParam];
    is_GetUnReadMessageRequest_send = YES;
    isRequestSended = YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendMessage:(id)sender {
    
    NSMutableDictionary *dictParam = [NSMutableDictionary new];
    NSString* message;
    
    message = text_message_id.text;
    NSString* textMessage = [message stringByReplacingOccurrencesOfString:@" " withString:@""];
    if( [textMessage isEqualToString:@""]) {
        
        [text_message_id resignFirstResponder];
        [self changeFrameSize];
        messageHint_label.text = @"Enter Message.... ";
        UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Message is empty"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
        [alertview show];
        return;
    }
    
    [dictParam setValue:message forKey:@"messageText"];
    
    [dictParam setValue:[ webServices.dictSelectedUser valueForKey:@"userId"]  forKey:@"receiverId"];
    if( is_viewProfileRequset_send == NO ) {
        [alertView show];
        isSendMessageRequest_send = YES;
        [text_message_id resignFirstResponder];
        [self changeFrameSize];
        [webServices callAPI:APISENDMESSAGE dictionary:dictParam];
        
        text_message_id.text = @"";
        messageHint_label.text = @"Enter Message.... ";
    }
    
    
}
- (void)viewDidUnload {
    //loginedUserProfilename = nil;
    onlineStatus = nil;
    relatioShipStatus = nil;
    [super viewDidUnload];
}
-(BOOL) textFieldShouldReturn:(UITextView *)textField{
    
    [textField resignFirstResponder];
    return YES;
    
}

//#pragma mark - ChatGridViewCell Datasource

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


- (IBAction)deleteChatHistory:(id)sender {
    [chatMessageDetails removeAllObjects];
    NSMutableDictionary *dictParam = [NSMutableDictionary new];
    [dictParam setValue:[webServices.dictSelectedUser valueForKey:@"userId"] forKey:@"toFromUserId"];
    [webServices callAPI:APIDELETECHATHISTORY dictionary:dictParam];
    [chat_tableview reloadData];
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    isKeyBoardHidden = NO;
    messageHint_label.text = @" ";
    static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.5;
    static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
    static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
    static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
    static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
    
    CGRect textFieldRect =
    [self.view convertRect:textView.bounds fromView:textView];
    
    CGRect viewRect =
    [self.view convertRect:self.view.bounds fromView:self.view];
    
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    
    CGFloat heightFraction = numerator / denominator;
    
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    
    original_Xaxis_value = self.view.frame.origin.x;
    original_Yaxis_value = self.view.frame.origin.y;
    CGRect viewFrame = self.view.frame;
    
    
    
    if( orientation == UIDeviceOrientationLandscapeRight) {
        viewFrame.origin.x -= animatedDistance;
        
    }else if ( orientation == UIDeviceOrientationLandscapeLeft) {
        viewFrame.origin.x += animatedDistance;
        
    }else {
        viewFrame.origin.y -= animatedDistance;
        
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(text_message_id.text.length == 0){
        messageHint_label.text = @"Enter Message.... ";
        [text_message_id resignFirstResponder];
        
        [self changeFrameSize];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        if(text_message_id.text.length == 0){
            messageHint_label.text = @"Enter Message.... ";
            [text_message_id resignFirstResponder];
            
        }
        
        [self changeFrameSize];
        return NO;
        
    }
    
    // TODO - find out why the size of the string is smaller than the actual width, so that you get extra, wrapped characters unless you take something off
    
    if(textView.text.length + (text.length - range.length) <= 300) {
        return YES;
    }
    else if (300 < [textView.text length])
    {
        return NO;
    }
    else
        return YES;
    
    
}
-(void)changeFrameSize
{
    
    int isChangeFrameSize = NO, Xvalue = self.view.frame.origin.x, Yvalue = self.view.frame.origin.y;
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if ( orientation == UIDeviceOrientationLandscapeRight && (Xvalue+animatedDistance) == original_Xaxis_value ) {
        isChangeFrameSize = YES;
    }else if (orientation == UIDeviceOrientationLandscapeLeft && (Xvalue-animatedDistance) == original_Xaxis_value )
    {
        isChangeFrameSize = YES;
    }else if( Yvalue+animatedDistance == original_Yaxis_value)
        isChangeFrameSize = YES;
    
    
    if( isChangeFrameSize == YES ) {
        static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
        CGRect viewFrame = self.view.frame;
        
        if( orientation == UIDeviceOrientationLandscapeRight) {
            viewFrame.origin.x += animatedDistance;
            
        }else if ( orientation == UIDeviceOrientationLandscapeLeft) {
            viewFrame.origin.x -= animatedDistance;
            
        }else {
            viewFrame.origin.y += animatedDistance;
            
        }
        
        // animatedDistance = 0;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
        [self.view setFrame:viewFrame];
        [UIView commitAnimations];
    }
}
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    
    
    [chat_tableview reloadData];
    
}

- (IBAction)logout:(id)sender {
    
    [webServices callAPI:APILOGOUT dictionary:NULL];
    [webServices stopUpdateLocationThread];
    [webServices writeSessionId:@"null"];
    
    [self stopChatReplyTimer];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
    webServices.isLoginViewControllerCalled = YES;
    //RegistrationViewController *profileVC = [RegistrationViewController new];
    //[self presentViewController:profileVC animated:YES completion:NULL];
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

-  (NSInteger)tableView:(UITableView *)tableView
  numberOfRowsInSection:(NSInteger)section
{
    return [chatMessageDetails count];
}
-(UITableViewCell *)tableView:(UITableView *)
tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int index = indexPath.row;
    
    //  UIInterfaceOrientation orientation =
    //  [[UIApplication sharedApplication] statusBarOrientation];
    
    if([[[chatMessageDetails objectAtIndex:index] valueForKey:@"isSenderOrReceiver"] isEqual: @"sender"]) {
        
        
        static NSString * CellIdentifier = @"ChatGridViewCell";
        
        ChatGridViewCell * cell = [tableView1 dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil) {
            cell = [[ChatGridViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier] ;
        }
        
        
        if([chatImageDetails count] > 1) {
            if([chatImageDetails objectAtIndex:1] != nil)
                cell.userImage.image = [chatImageDetails objectAtIndex:1];
            else
                cell.userImage.image = [UIImage imageNamed:@"blank_user.png"];
        }else
            cell.userImage.image = [UIImage imageNamed:@"blank_user.png"];
        
        
        cell.messageText.text = [[chatMessageDetails objectAtIndex:index] valueForKey:@"messageText"];
        
        CGRect labelFrame = cell.messageText.frame;
        labelFrame.size = [cell.messageText.text sizeWithFont:cell.messageText.font
                                            constrainedToSize:CGSizeMake(cell.messageText.frame.size.width, 300.00)
                                                lineBreakMode:NSLineBreakByWordWrapping];
        
        labelFrame.size.height = labelFrame.size.height +20;
        
        labelFrame.size.width = cell.messageText.frame.size.width;
        cell.messageText.frame = labelFrame;
        
        CGRect imageFrame = cell.bubble.frame;
        
        
        imageFrame.size.height = cell.messageText.frame.size.height+20;
        
        cell.bubble.frame = imageFrame;
        [cell.messageText setNeedsDisplay];
        
        CGRect cellFrame  = cell.frame;
        if((int)cell.bubble.frame.size.height > 100){
            cellFrame.size.height = cell.bubble.frame.size.height+20;
            
        }else
            cellFrame.size.height = 100.00;
        
        cell.frame = cellFrame;
        
        CGRect timeFrame = cell.timeId.frame;
        timeFrame.origin.y = cell.frame.size.height - 40;
        cell.timeId.frame = timeFrame;
        
        CGRect userImageFrame = cell.userImage.frame;
        userImageFrame.origin.y = cell.timeId.frame.origin.y-50;
        cell.userImage.frame = userImageFrame;
        
        CGRect profileImageBgFrame = cell.profileImage_bg.frame;
        profileImageBgFrame.origin.y = cell.userImage.frame.origin.y-4;
        cell.profileImage_bg.frame = profileImageBgFrame;
        
        
        NSString* timeinString = [[chatMessageDetails objectAtIndex:index] valueForKey:@"creationTime"];
        
        NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
        
        if(((timeInMiliseconds*1000)-86400000) > [timeinString doubleValue]) {
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:([timeinString doubleValue] / 1000)];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MMM dd hh:mm aa"];
            
            cell.timeId.text = [dateFormatter stringFromDate:date];
            
        }else{
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:([timeinString doubleValue] / 1000)];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"hh:mm aa"];
            
            cell.timeId.text = [dateFormatter stringFromDate:date];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    }
    else{
        
        static NSString * CellIdentifier = @"ReplyChatGridViewCell";
        
        ReplyChatGridViewCell * cell = [tableView1 dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil) {
            cell = [[ReplyChatGridViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier] ;
        }
        
        if( [chatImageDetails count] > 0 ) {
            if([chatImageDetails objectAtIndex:0] != nil)
                cell.userImage.image = [chatImageDetails objectAtIndex:0];
            else
                cell.userImage.image = [UIImage imageNamed:@"blank_user.png"];
        }else
            cell.userImage.image = [UIImage imageNamed:@"blank_user.png"];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfileView:)];
        // if labelView is not set userInteractionEnabled, you must do so
        [cell.userImage setUserInteractionEnabled:YES];
        gesture.numberOfTapsRequired = 1;
        gesture.numberOfTouchesRequired = 1;
        cell.userImage.tag = index;
        [cell.userImage addGestureRecognizer:gesture];
        
        cell.messageText.text =[[chatMessageDetails objectAtIndex:index] valueForKey:@"messageText"];
        
        //[cell.messageText sizeToFit];
        CGRect labelFrame = cell.messageText.frame;
        labelFrame.size = [cell.messageText.text sizeWithFont:cell.messageText.font
                                            constrainedToSize:CGSizeMake(cell.messageText.frame.size.width, 300.00)
                                                lineBreakMode:NSLineBreakByWordWrapping];
        
        labelFrame.size.height = labelFrame.size.height +10;
        
        labelFrame.size.width = cell.messageText.frame.size.width;
        cell.messageText.frame = labelFrame;
        CGRect imageFrame = cell.bubble.frame;
        
        
        imageFrame.size.height = cell.messageText.frame.size.height+20;
        
        cell.bubble.frame = imageFrame;
        
        CGRect cellFrame  = cell.frame;
        if((int)cell.bubble.frame.size.height > 100){
            cellFrame.size.height = cell.bubble.frame.size.height+20;
            
        }else
            cellFrame.size.height = 100.00;
        
        cell.frame = cellFrame;
        
        CGRect timeFrame = cell.timeId.frame;
        timeFrame.origin.y = cell.frame.size.height - 40;
        cell.timeId.frame = timeFrame;
        
        CGRect userImageFrame = cell.userImage.frame;
        userImageFrame.origin.y = cell.timeId.frame.origin.y-52;
        cell.userImage.frame = userImageFrame;
        
        CGRect profileImageBgFrame = cell.profileImage_bg.frame;
        profileImageBgFrame.origin.y = cell.userImage.frame.origin.y-4;
        cell.profileImage_bg.frame = profileImageBgFrame;
        
        NSString* timeinString = [[chatMessageDetails objectAtIndex:index] valueForKey:@"creationTime"];
        
        NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
        
        if(((timeInMiliseconds*1000)-86400000) > [timeinString doubleValue]) {
            
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:([timeinString doubleValue] / 1000)];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MMM dd hh:mm aa"];
            
            cell.timeId.text = [dateFormatter stringFromDate:date];
            
        }else{
            
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:([timeinString doubleValue] / 1000)];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"hh:mm aa"];
            
            cell.timeId.text = [dateFormatter stringFromDate:date];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return  cell;
    }
}
-(void)showProfileView: (UIGestureRecognizer*)gestureRecognizer {
    
    //NSLog(@">>Show Profile view method<<");
    webServices.dictSelectedUser = [chatUserDetails objectAtIndex:0];
    
    webServices.imgUser = [chatImageDetails objectAtIndex:0];
    
    if(webServices.onlineStatus == YES)
        [webServices.dictSelectedUser setValue:@"1" forKey:@"onlineStatus"];
    else
        [webServices.dictSelectedUser setValue:@"0" forKey:@"onlineStatus"];
    
    
    webServices.isCallFromChat = YES;
    ProfileViewController *profileVC = [ProfileViewController new];
    
    [self presentViewController:profileVC animated:YES completion:NULL];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize size = [[[chatMessageDetails objectAtIndex:indexPath.row] valueForKey:@"messageText"] sizeWithFont:text_message_id.font
                                                                                            constrainedToSize:CGSizeMake(100.00, 320.00)
                                                                                                lineBreakMode:NSLineBreakByWordWrapping];
    
    if ( (int)size.height < 100) {
        return 100.00;
        
    }else{
        
        return  size.height+20;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
