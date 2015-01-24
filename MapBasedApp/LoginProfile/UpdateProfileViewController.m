//
//  UpdateProfileViewController.m
//  Fyndher
//
//  Created by Laure Linn on 19/10/12.
//  Copyright (c) 2012 Mobile Analytics   All rights reserved.
//

#import "UpdateProfileViewController.h"
#import "JSON.h"
#import "GlobalConstants.h"
#import "RegistrationViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>
#import "WebAPI.h"

@interface UpdateProfileViewController ()

@end

@implementation UpdateProfileViewController

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
    // Do any additional setup after loading the view from its nib.
    isRequestSended = NO;
    //NSLog(@"View Didload method");
    strPickerValue = [NSString new];
    
    webServices = [WebAPI sharedInstance];
    [webServices setDelegate:self];
    
    tableCellSize = 44;
    
    isUpdateProfileRequestSend = NO;
    [txtPassWord setDelegate:self];
    [txtScreenName setDelegate:self];
    
    loader = [[UIAlertView alloc] initWithTitle:@"Loading Please wait...."
                                        message:@" "
                                       delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:nil, nil];
    UIActivityIndicatorView *spinner1 = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner1.center = CGPointMake(139.5, 75.5); // .5 so it doesn't blur
    [loader addSubview:spinner1];
    [spinner1 startAnimating];
    [loader show];
    
    arrayRelationshipStatus = [[NSMutableArray alloc]
                               initWithObjects:@"Do not display",@"Single",@"Dating",@"Commited Relationship",@"Open Relationship", nil];
    arrayConnectionStatus = [[NSMutableArray alloc]
                             initWithObjects:@"Do not display",@"Friends",@"Dating",@"Commited Relationship",@"Open Relationship",@"Friends with benefits", nil];
    
    arrayEmployeementType = [[NSMutableArray alloc]
                             initWithObjects:@"Do not display",@"Employed",@"Not employed",@"Military",@"Student", nil];
    
    arrayAgeRange = [[NSMutableArray alloc] initWithObjects:@"Do not display",@"18-25",@"26-35",@"36-45",@"46-55",@"56-65", @"65+", nil];
    
    arrayEducation = [[NSMutableArray alloc]
                      initWithObjects:@"Do not display", @"High School",@"College",@"Graduate School",@"Trade School", nil];
    
    arrayRace = [[NSMutableArray alloc]
                 initWithObjects:@"Do not display", @"Asian",@"Black",@"Latino",@"White", @"Other", nil];
    
    arrayOrientation = [[NSMutableArray alloc]
                        initWithObjects:@"Do not display",@"Gay",@"Bisexual",@"Transgender", nil];
    
    arrayPhotoUploadOption = [[NSMutableArray alloc] initWithObjects:@"Gallery",@"Camera", nil];
    
    photoUploadOptionValue = @"Gallery";
    selectedItems = [NSMutableArray new];
    oldSelectedItems = [NSMutableArray new];
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImageUploadOption:)];
    // if labelView is not set userInteractionEnabled, you must do so
    [profile_image_label setUserInteractionEnabled:YES];
    [profile_image_label addGestureRecognizer:gesture];
    
    profile_image.layer.cornerRadius = 12.00;
    profile_image.layer.masksToBounds = YES;
    
    btAgeRange.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentLeft;
    btEducation.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentLeft;
    btEmployment.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentLeft;
    btOrientation.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentLeft;
    btRace.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentLeft;
    btRelationShip.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentLeft;
    btSeekingConnection.contentHorizontalAlignment =  UIControlContentHorizontalAlignmentLeft;
    
    [scrollView setContentSize:[[UIScreen mainScreen] bounds].size];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"page_pg.png"]];
    adminStatus = NO;
    isRequestSended = YES;
    [webServices callAPI:APIVIEWPROFILE dictionary:NULL];
    /*if(webServices.loggedInUserDetails == nil)
     [webServices callAPI:APIVIEWPROFILE dictionary:NULL];
     else{
     NSMutableArray* mutableArray = [NSMutableArray new];
     [mutableArray addObject:[NSString stringWithFormat:@"%d", 200]];
     [mutableArray addObject:webServices.loggedInUserDetails];
     [self processSuccessful:mutableArray];
     }*/
    
    
}


-(void)viewWillAppear:(BOOL)animated
{
    //_bannerView = [[ADBannerView alloc]
    //    initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, 320, 50)];
    
    // _bannerView.delegate = self;
    NSLog(@">>View will appear method<<");
    // CGRect screenRect = [[UIScreen mainScreen] bounds];
    //self.view.frame = screenRect;
}

#pragma mark - GridView Datasource

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    //    _tableView.tableHeaderView = _bannerView;
    // [self.view addSubview:_bannerView];
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


#pragma mark
#pragma mark Manage textField Scrolling

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
    static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
    static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
    static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
    static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
    
    CGRect textFieldRect =
    [self.view convertRect:textField.bounds fromView:textField];
    
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
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self changeFrameSize];
    
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    animatedDistance=0;
    
    return YES;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txtScreenName resignFirstResponder];
    [txtPassWord resignFirstResponder];
    
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

/*- (IBAction)Submit:(id)sender {
 
 }*/
- (IBAction)back:(id)sender
{
    NSLog(@">>Back method<<");
    UIAlertView* alertview;
    NSUserDefaults *preferences = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *dictParam = [NSMutableDictionary new];
    NSMutableDictionary *dictParam1 = [NSMutableDictionary new];
    NSString* screenName = [txtScreenName.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString* passWord = [txtPassWord.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if([screenName length] == 0){
        alertview = [[UIAlertView alloc] initWithTitle:@"Error"
                                               message:@"Setup your screen name"
                                              delegate:self
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil, nil];
        [alertview show];
        return;
    }
    
    
    if([[[preferences valueForKey:KEYEMAIL] lowercaseString]  isEqualToString:[screenName lowercaseString]]) {
        alertview = [[UIAlertView alloc] initWithTitle:@"Error"
                                               message:@"Screen name must be different from login email"
                                              delegate:self
                                     cancelButtonTitle:@"OK"
                                     otherButtonTitles:nil, nil];
        [alertview show];
        return;
        
    }
    
    if([passWord length] > 0) {
        if ([passWord length] < 6) {
            alertview = [[UIAlertView alloc] initWithTitle:@"Error"
                                                   message:@"Password must greater than 6 characters"
                                                  delegate:self
                                         cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil, nil];
            [alertview show];
            return;
        }
        else  {
            [dictParam setValue:[NSString stringWithString:txtPassWord.text] forKey:@"passWord"];
            [dictParam1 setValue:[NSString stringWithString:txtPassWord.text] forKey:@"passWord"];
            txtPassWord.text = @"";
        }
        
    }
    [dictParam setValue:[NSString stringWithString:txtScreenName.text] forKey:@"screenName"];
    [dictParam1 setValue:[NSString stringWithString:txtScreenName.text] forKey:@"screenName"];
    [dictParam setValue:relationshipValue forKey:@"relationshipStatus"];
    [dictParam1 setValue:relationshipValue forKey:@"relationshipStatus"];
    [dictParam setValue:@"Do not display" forKey:@"connectionStatus"];
    [dictParam1 setValue:@"Do not display" forKey:@"connectionStatus"];
    [dictParam setValue:employmentValue forKey:@"employmentType"];
    [dictParam1 setValue:employmentValue forKey:@"employmentType"];
    [dictParam setValue:ageRangeValue forKey:@"ageRange"];
    [dictParam1 setValue:ageRangeValue forKey:@"ageRange"];
    [dictParam setValue:educationValue forKey:@"education"];
    [dictParam1 setValue:educationValue forKey:@"education"];
    [dictParam setValue:raceValue forKey:@"race"];
    [dictParam1 setValue:raceValue forKey:@"race"];
    [dictParam setValue:orientationValue forKey:@"sexualOrientationEnum"];
    [dictParam1 setValue:orientationValue forKey:@"sexualOrientationEnum"];
    
    
    [dictParam setValue:selectedItems forKey:@"seekingConnectionList"];
    [dictParam1 setValue:selectedItems forKey:@"seekingConnectionList"];
    [dictParam1 setValue:[webServices.loggedInUserDetails valueForKey:@"photo"] forKey:@"photo"];
    [dictParam1 setValue:[webServices.loggedInUserDetails valueForKey:@"userId"] forKey:@"userId"];
    webServices.loggedInUserDetails = dictParam1;
    [webServices callAPI:APIUPDATEPROFILE dictionary:dictParam];
    isRequestSended = YES;
    isUpdateProfileRequestSend = YES;
    //[loader show];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)processSuccessful:(NSArray *)paraResponse
{
    NSLog(@">>Process successfull<<");
    [loader dismissWithClickedButtonIndex:0 animated:YES];
    if( isUpdateProfileRequestSend == YES  && isRequestSended == YES && [[paraResponse objectAtIndex:0] intValue] == 200 ) {
        isUpdateProfileRequestSend = NO;
        isRequestSended = NO;
        webServices.loggedInUserDetails = [paraResponse objectAtIndex:1];
        //NSLog(@">>LoggedinUser details are updated:%@",webServices.loggedInUserDetails);
        
    }else if( isRequestSended == YES && [[paraResponse objectAtIndex:0] intValue] == 200 ){
        isRequestSended = NO;
        //NSLog(@"Success Response >> UpdateProfile View >>>>>>>>> ");
        // NSLog(@"Profile Response:%@",[paraResponse objectAtIndex:1]);
        webServices.loggedInUserDetails = [paraResponse objectAtIndex:1];
        
        if ((NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"screenName"] != [NSNull null])
            txtScreenName.text = [[paraResponse objectAtIndex:1] valueForKey:@"screenName"];
        else
            txtScreenName.text = @"Do not display";
        
        if ((NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"relationshipStatus"] != [NSNull null])  {
            
            relationshipValue = [[paraResponse objectAtIndex:1] valueForKey:@"relationshipStatus"];
            [btRelationShip setTitle:[[paraResponse objectAtIndex:1] valueForKey:@"relationshipStatus"] forState:UIControlStateNormal];
            
        }
        else {
            relationshipValue = @"Do not display";
            [btRelationShip setTitle:@"Do not display" forState:UIControlStateNormal];
        }
        
        if ((NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"employmentType"] != [NSNull null]) {
            employmentValue = [[paraResponse objectAtIndex:1] valueForKey:@"employmentType"];
            [btEmployment setTitle:[[paraResponse objectAtIndex:1] valueForKey:@"employmentType"] forState:UIControlStateNormal];
        }else {
            employmentValue = @"Do not display";
            [btEmployment setTitle:@"Do not display" forState:UIControlStateNormal];
        }
        
        if ((NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"ageRange"] != [NSNull null]) {
            
            ageRangeValue = [[paraResponse objectAtIndex:1] valueForKey:@"ageRange"];
            [btAgeRange setTitle:[[paraResponse objectAtIndex:1] valueForKey:@"ageRange"] forState:UIControlStateNormal];
        } else {
            ageRangeValue = @"Do not display";
            [btAgeRange setTitle:@"Do not display" forState:UIControlStateNormal];
        }
        
        if ((NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"education"] != [NSNull null]) {
            educationValue = [[paraResponse objectAtIndex:1] valueForKey:@"education"];
            [btEducation setTitle:[[paraResponse objectAtIndex:1] valueForKey:@"education"] forState:UIControlStateNormal];
        }
        else {
            educationValue = @"Do not display";
            [btEducation setTitle:@"Do not display" forState:UIControlStateNormal];
        }
        
        if ((NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"race"] != [NSNull null]) {
            raceValue = [[paraResponse objectAtIndex:1] valueForKey:@"race"];
            [btRace setTitle:[[paraResponse objectAtIndex:1] valueForKey:@"race"] forState:UIControlStateNormal];
        } else {
            raceValue = @"Do not display";
            [btRace setTitle:@"Do not display" forState:UIControlStateNormal];
        }
        
        if ((NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"sexualOrientationEnum"] != [NSNull null]) {
            orientationValue = [[paraResponse objectAtIndex:1] valueForKey:@"sexualOrientationEnum"];
            [btOrientation setTitle:[[paraResponse objectAtIndex:1] valueForKey:@"sexualOrientationEnum"] forState:UIControlStateNormal];
        } else {
            orientationValue = @"Do not display";
            [btOrientation setTitle:@"Do not display" forState:UIControlStateNormal];
        }
        
        if ((NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"seekingConnectionList"] != [NSNull null]) {
            
            
            NSString* seekingConnectionListValue = @" ";
            for (int i = 0; i< [[[paraResponse objectAtIndex:1] valueForKey:@"seekingConnectionList"] count]; i++) {
                
                [selectedItems addObject:[[[paraResponse objectAtIndex:1] valueForKey:@"seekingConnectionList"] objectAtIndex:i]];
                
                seekingConnectionListValue = [seekingConnectionListValue stringByAppendingString:[[[paraResponse objectAtIndex:1] valueForKey:@"seekingConnectionList"] objectAtIndex:i]];
                if( i < [[[paraResponse objectAtIndex:1] valueForKey:@"seekingConnectionList"] count]-1)
                    seekingConnectionListValue = [seekingConnectionListValue stringByAppendingFormat:@",\t"];
                
            }
            [btSeekingConnection setTitle:seekingConnectionListValue forState:UIControlStateNormal];
            
        }
        else {
            [btSeekingConnection setTitle:@"Do not display" forState:UIControlStateNormal];
            [selectedItems addObject:@"Do not display"];
        }
        
        if ((NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"adminStatus"] != [NSNull null]) {
            adminStatus = [[[paraResponse objectAtIndex:1] valueForKey:@"adminStatus"] intValue];
            
        } else {
            adminStatus = 0;
        }
        
        if ((NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"photo"] != [NSNull null]) {
            UIImage* fileImage = nil ;
            if([webServices isFileExists:[[paraResponse objectAtIndex:1] valueForKey:@"photo"]]){
                fileImage =[webServices readImageValue_ImagePath:[[paraResponse objectAtIndex:1] valueForKey:@"photo"]];
                
            }
            if( fileImage == nil)  {
                NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/rest/1/file/%@?pixel=100",BASEURL,[[paraResponse objectAtIndex:1] valueForKey:@"photo"]]];
                
                UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                if( image!= nil) {
                    
                    webServices.loggedInUserImage = image;
                    profile_image.image = image;
                    [webServices writeImageValue_ImagePath:[[paraResponse objectAtIndex:1] valueForKey:@"photo"] imageForUser:image];
                }else{
                    webServices.loggedInUserImage = [UIImage imageNamed:@"blank_user.png"];
                    profile_image.image = [UIImage imageNamed:@"blank_user.png"];
                }
            }else{
                webServices.loggedInUserImage = fileImage;
                profile_image.image = fileImage;
            }
            
        }else{
            profile_image.image = [UIImage imageNamed:@"blank_user.png"];
            webServices.loggedInUserImage = [UIImage imageNamed:@"blank_user.png"];
        }
        
        UIAlertView *photoStatusalertview;
        
        if((NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"photoStatus"] != [NSNull null] && [[[paraResponse objectAtIndex:1] valueForKey:@"photoStatus"] isEqual:@"Waiting for Approval"])
        {
            photoStatusalertview = [[UIAlertView alloc] initWithTitle:@" "
                                                              message:@"New profile photo has not yet been approved by Fyndher Admin"
                                                             delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil, nil];
            [photoStatusalertview show];
        }else if((NSNull *)[[paraResponse objectAtIndex:1] valueForKey:@"photoStatus"] != [NSNull null] && [[[paraResponse objectAtIndex:1] valueForKey:@"photoStatus"] isEqual:@"Decline"]) {
            
            photoStatusalertview = [[UIAlertView alloc] initWithTitle:@" "
                                                              message:@"Your profile photo does not meet fyndher quidelines.  Please review the photo guidelines on fyndher.com"
                                                             delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil, nil];
            [photoStatusalertview show];
        }
    }else if ([[paraResponse objectAtIndex:0] intValue] >= 400 && [[paraResponse objectAtIndex:0] intValue] < 500 && isRequestSended == YES) {
        
        isRequestSended = NO;
        
        [webServices callAPI:APILOGOUT dictionary:NULL];
        [webServices stopUpdateLocationThread];
        [webServices writeSessionId:@"null"];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        
        webServices.isLoginViewControllerCalled = YES;
        // RegistrationViewController *profileVC = [RegistrationViewController new];
        // [self presentViewController:profileVC animated:YES completion:NULL];
        [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
        
    }
    isRequestSended = NO;
}

-(void)processFail:(NSString *)paraResponse {
    
    [loader dismissWithClickedButtonIndex:0 animated:YES];
    isRequestSended = NO;
    
    if( isUpdateProfileRequestSend == YES) {
        
        
        isUpdateProfileRequestSend = NO;
        
    }
}

- (IBAction)ClosePicker:(id)sender
{
    int tagValue = [sender tag];
    
    if (tagValue == 2) {
        
        switch (intFieldIndex) {
                
                
            case 5:
                if( [selectedItems count] > 0) {
                    NSString* selectedValues = @"";
                    for ( int i=0 ; i< [selectedItems count]; i++) {
                        if(i == [selectedItems count]-1)
                            selectedValues = [selectedValues stringByAppendingFormat:@"%@",[selectedItems objectAtIndex:i]];
                        else
                            selectedValues = [selectedValues stringByAppendingFormat:@"%@,",[selectedItems objectAtIndex:i]];
                    }
                    [btSeekingConnection setTitle:selectedValues forState:UIControlStateNormal];
                    //NSLog(@"Selected values:%@",selectedValues);
                    //seekingConnectionValue = strPickerValue;
                }else {
                    [btSeekingConnection setTitle:@"Do not display" forState:UIControlStateNormal];
                    [selectedItems addObject:@"Do not display"];
                }
                
                strPickerValue = @"";
                break;
                
            default:
                break;
        }
        
        if( intFieldIndex == 5)
            [seekingConnectionPickerView removeFromSuperview];
        
    }
    else if( intFieldIndex == 5){
        [seekingConnectionPickerView removeFromSuperview];
        [selectedItems removeAllObjects];
        [selectedItems addObjectsFromArray:oldSelectedItems];
        [oldSelectedItems removeAllObjects];
        strPickerValue = @"";
    }
    
    // CGRect screenRect = [[UIScreen mainScreen] bounds];
    // self.view.frame = screenRect;
}


- (IBAction)openPicker:(id)sender
{
    [viewDatePicker removeFromSuperview];
    [seekingConnectionPickerView removeFromSuperview];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    
    intFieldIndex = [sender tag];
    if( intFieldIndex == 5) {
        
        seekingConnectionPickerView.frame = screenRect;
        seekingConnectionPickerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        
        CGRect frame = seekingConnectionTableView.frame;
        frame.origin.x = 00.00;
        frame.origin.y =  screenRect.size.height-(tableCellSize*([arrayConnectionStatus count]+1));
        frame.size.height = tableCellSize*([arrayConnectionStatus count]+1);
        seekingConnectionTableView.frame = frame;
        //frame = seekingConnectionBg.frame;
        
        seekingConnectionBg.frame = frame;
        
        frame = seekingConnectionMenuBg.frame;
        frame.origin.x = 0.0;
        frame.origin.y = seekingConnectionTableView.frame.origin.y-43;
        seekingConnectionMenuBg.frame = frame;
        
        frame = seekingConnectionDoneButton.frame;
        frame.origin.x = seekingConnectionMenuBg.frame.size.width-70.00;
        frame.origin.y = seekingConnectionMenuBg.frame.origin.y+5.00;
        seekingConnectionDoneButton.frame = frame;
        
        frame = seekingConnectionBackButton.frame;
        frame.origin.y = seekingConnectionDoneButton.frame.origin.y;
        frame.origin.x = 10.00;
        seekingConnectionBackButton.frame = frame;
        
        [self.view addSubview:seekingConnectionPickerView];
        [oldSelectedItems removeAllObjects];
        [oldSelectedItems addObjectsFromArray:selectedItems];
        [seekingConnectionTableView reloadData];
        
    }else{
        table_View.backgroundColor = [UIColor clearColor];
        viewDatePicker.frame = screenRect;
        viewDatePicker.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
        CGRect frame = table_View.frame;
        frame.origin.x = 00.00;
        
        switch (intFieldIndex) {
                
            case 1:
                frame.size.height = tableCellSize*([arrayAgeRange count]+1);
                frame.origin.y = screenRect.size.height-tableCellSize*([arrayAgeRange count]+1);
                break;
            case 2:
                frame.size.height = tableCellSize*([arrayRace count]+1);
                frame.origin.y = screenRect.size.height-tableCellSize*([arrayRace count]+1);
                break;
            case 3:
                frame.size.height = tableCellSize*([arrayOrientation count]+1);
                frame.origin.y = screenRect.size.height-tableCellSize*([arrayOrientation count]+1);
                break;
            case 4:
                frame.size.height = tableCellSize*([arrayRelationshipStatus count]+1);
                frame.origin.y = screenRect.size.height-tableCellSize*([arrayRelationshipStatus count]+1);
                break;
            case 6:
                frame.size.height = tableCellSize*([arrayEducation count]+1);
                frame.origin.y = screenRect.size.height-tableCellSize*([arrayEducation count]+1);
                break;
            case 7:
                frame.size.height = tableCellSize*([arrayEmployeementType count]+1);
                frame.origin.y = screenRect.size.height-tableCellSize*([arrayEmployeementType count]+1);
                break;
            case 8:
                frame.size.height = tableCellSize*([arrayPhotoUploadOption count]+1);
                frame.origin.y = screenRect.size.height-tableCellSize*([arrayPhotoUploadOption count]+1);
                break;
                
            default:
                frame.size.height = 250.00;
                frame.origin.y = 100.00;
                break;
        }
        table_View.frame = frame;
        picker_bgimage.frame = frame;
        [self.view addSubview:viewDatePicker];
        [table_View reloadData];
        
    }
    
}

-(void)showImageUploadOption:(UIGestureRecognizer*)gestureRecognizer {
    
    intFieldIndex = 8;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    viewDatePicker.frame = screenRect;
    viewDatePicker.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
    
    CGRect frame = table_View.frame;
    frame.origin.x = 0.00;
    frame.origin.y = screenRect.size.height-130.00;
    frame.size.height = 100.00;
    
    table_View.frame = frame;
    picker_bgimage.frame = frame;
    
    //picker_bgimage.frame = viewDatePicker.frame;
    // table_View.frame = viewDatePicker.frame;
    tableTitle.text = @"Photos Upload Options";
    table_View.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
    [self.view addSubview:viewDatePicker];
    [table_View reloadData];
    
    //UpdateProfileOptionViewController *profileVC = [UpdateProfileOptionViewController new];
    
    //  [self presentViewController:profileVC animated:YES completion:NULL];
}

-(void)showGalary {
    [viewDatePicker removeFromSuperview];
    [self startMediaBrowserFromViewController: self
     
                                usingDelegate: self];
}
-(void)showCamera {
    [viewDatePicker removeFromSuperview];
    [self startCameraControllerFromViewController: self
     
                                    usingDelegate: self];
    
    
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller

                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   
                                                   UINavigationControllerDelegate>) delegate {
    
    
    if (([UIImagePickerController isSourceTypeAvailable:
          
          UIImagePickerControllerSourceTypeCamera] == NO)
        
        || (delegate == nil)
        
        || (controller == nil))
        
        return NO;
    
    
    
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    
    
    // Displays a control that allows the user to choose picture or
    
    // movie capture, if both are available:
    
    cameraUI.mediaTypes =
    
    [UIImagePickerController availableMediaTypesForSourceType:
     
     UIImagePickerControllerSourceTypeCamera];
    
    
    
    // Hides the controls for moving & scaling pictures, or for
    
    // trimming movies. To instead show the controls, use YES.
    
    //cameraUI.allowsEditing = NO;
    cameraUI.allowsEditing = YES;
    
    
    cameraUI.delegate = delegate;
    
    
    
    [controller presentViewController:cameraUI animated:YES completion:NULL];
    
    return YES;
    
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller

                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               
                                               UINavigationControllerDelegate>) delegate {
    
    
    
    if (([UIImagePickerController isSourceTypeAvailable:
          
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        
        || (delegate == nil)
        
        || (controller == nil))
        
        return NO;
    
    
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    
    mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    
    
    // Displays saved pictures and movies, if both are available, from the
    
    // Camera Roll album.
    
    mediaUI.mediaTypes =
    
    [UIImagePickerController availableMediaTypesForSourceType:
     
     UIImagePickerControllerSourceTypePhotoLibrary];
    
    
    
    // Hides the controls for moving & scaling pictures, or for
    
    // trimming movies. To instead show the controls, use YES.
    
    //mediaUI.allowsEditing = NO;
    mediaUI.allowsEditing = YES;
    
    
    mediaUI.delegate = delegate;
    
    
    
    [controller presentViewController:mediaUI animated:YES completion:NULL];
    
    return YES;
    
}
- (void) imagePickerController: (UIImagePickerController *) picker1

 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    UIImage *originalImage, *editedImage, *imageToUse;
    
    
    
    // Handle a still image picked from a photo album
    
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        
        == kCFCompareEqualTo) {
        
        
        
        editedImage = (UIImage *) [info objectForKey:
                                   
                                   UIImagePickerControllerEditedImage];
        
        originalImage = (UIImage *) [info objectForKey:
                                     
                                     UIImagePickerControllerOriginalImage];
        
        
        
        if (editedImage) {
            
            imageToUse = editedImage;
            
        } else {
            
            imageToUse = originalImage;
            
        }
        newProfileImage = imageToUse;
        
        // Laure
        //[NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(uploadImage) userInfo:nil repeats:NO];
        
        [NSThread detachNewThreadSelector:@selector(uploadImage) toTarget:self withObject:nil];
        
        //[loader show];
        //[picker1 dismissViewControllerAnimated:YES completion:NULL];
        //[[picker1 parentViewController] dismissViewControllerAnimated:YES completion:NULL];
        
        
        
        
    }
    
    
    
    // Handle a movied picked from a photo album
    
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
        
        == kCFCompareEqualTo) {
        
        
        
        //NSString *moviePath = [[info objectForKey:
        
        //UIImagePickerControllerMediaURL] path];
        
        
        
        // Do something with the picked movie available at moviePath
        
    }
    profile_image.image = newProfileImage;
    if(adminStatus == 1) {
        webServices.loggedInUserImage = nil;
        [webServices.loggedInUserDetails setValue:[NSNull null] forKey:@"photo"];
    }else{
        webServices.loggedInUserImage = newProfileImage;
        [webServices.loggedInUserDetails setValue:[NSNull null] forKey:@"photo"];
    }
    
    [picker1 dismissViewControllerAnimated:YES completion:NULL];
    [[picker1 parentViewController] dismissViewControllerAnimated:YES completion:NULL];
    
}
-(void)uploadImage
{
    //UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    //spinner.center = CGPointMake(139.5, 75.5); // .5 so it doesn't blur
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/rest/1/file/url",BASEURL]];
    NSMutableURLRequest *uniqueUrlRequest = [[NSMutableURLRequest alloc] init];
    [uniqueUrlRequest setURL:url];
    [uniqueUrlRequest setHTTPMethod:@"GET"];
    
    NSData *uniqueUrlReturnData = [NSURLConnection sendSynchronousRequest:uniqueUrlRequest returningResponse:nil error:nil];
    NSString *urlResponse = [[NSString alloc] initWithData:uniqueUrlReturnData encoding:NSUTF8StringEncoding];
    // NSString* urlResponse = [NSString stringWithContentsOfURL:url];
    NSLog(@"unique url:%@",urlResponse);
    NSArray* splittedString = [urlResponse componentsSeparatedByString:@"/"];
    
    // laure.linn 6.16
    //NSData *imageData = UIImageJPEGRepresentation(newProfileImage, 100.00);
    
    NSData *imageData = UIImageJPEGRepresentation(newProfileImage, 1.0);
    
    // setting up the URL to post to
    NSString *urlString = [NSString stringWithFormat:@"%@/_ah/upload/%@/%@/",BASEURL,[splittedString objectAtIndex:5],[splittedString objectAtIndex:6]];
    NSLog(@"Requst url:%@",urlString);
    // setting up the request object now
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    /*
     add some header info now
     we always need a boundary when we post a file
     also we need to set the content type
     
     You might want to generate a random boundary.. this is just the same
     as my output from wireshark on a valid html post
     */
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    if([webServices readSessionId] != nil && ![[webServices readSessionId] isEqual: @"null"])
        [request setValue:[webServices readSessionId] forHTTPHeaderField:@"Cookie"];
    else {
        NSUserDefaults *prefrences = [NSUserDefaults standardUserDefaults];
        [request setValue:[prefrences valueForKey:@"Cookie"] forHTTPHeaderField:@"Cookie"];
    }
    /*
     now lets create the body of the post
     */
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: form-data; name=\"file_to_upload\"; filename=\"new_image.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    // setting the body of the post to the reqeust
    [request setHTTPBody:body];
    
    // now lets make the connection to the web
    // NSData *returnData =
    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    // NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    //[NSURLConnection connectionWithRequest:request delegate:self];
    /* NSArray* splittedResponse = [returnString componentsSeparatedByString:@","];
     
     NSArray* splittedResponse1 = [[splittedResponse objectAtIndex:2] componentsSeparatedByString:@"/"];
     NSString* imageName= [splittedResponse1 objectAtIndex:4];
     imageName = [imageName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
     
     
     [webServices.loggedInUserDetails setValue:imageName forKey:@"photo"];
     NSString* imageString = [NSString stringWithFormat:@"%@/rest/1/file/%@?pixel=100",BASEURL,imageName];
     //NSString* webStringURL = [imageString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
     
     
     NSURL *imageUrl = [NSURL URLWithString:imageString];
     
     
     UIImage* image =[UIImage imageWithData:[NSData dataWithContentsOfURL:imageUrl]];
     
     if( image!= nil) {
     
     webServices.loggedInUserImage = image;
     profile_image.image = image;
     [webServices writeImageValue_ImagePath:[webServices.loggedInUserDetails valueForKey:@"photo"] imageForUser:image];
     }else{
     //[webServices writeImageValue_ImagePath:[webServices.loggedInUserDetails valueForKey:@"photo"] imageForUser:newProfileImage];
     profile_image.image = newProfileImage;
     webServices.loggedInUserImage = newProfileImage;
     }
     if(adminStatus == 1) {
     webServices.loggedInUserImage = nil;
     [webServices.loggedInUserDetails setValue:[NSNull null] forKey:@"photo"];
     }*/
    
    //[loader dismissWithClickedButtonIndex:0 animated:YES];
}


-  (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (intFieldIndex) {
            
        case 1:
            return [arrayAgeRange count];
            break;
        case 2:
            return [arrayRace count];
            break;
        case 3:
            return [arrayOrientation count];
            break;
        case 4:
            return [arrayRelationshipStatus count];
            break;
        case 5:
            return [arrayConnectionStatus count];
            break;
        case 6:
            return [arrayEducation count];
            break;
        case 7:
            return [arrayEmployeementType count];
            break;
        case 8:
            return [arrayPhotoUploadOption count];
            break;
            
        default:
            break;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    NSLog(@">>didSelectRowAtIndexPath method<<");
    
    switch (intFieldIndex) {
            
        case 1:
        {
            strPickerValue = [arrayAgeRange objectAtIndex:row];
            [btAgeRange setTitle:strPickerValue forState:UIControlStateNormal];
            ageRangeValue = strPickerValue;
            strPickerValue = @"";
            
            break;
        }
        case 2:
            strPickerValue = [arrayRace objectAtIndex:row];
            [btRace setTitle:strPickerValue forState:UIControlStateNormal];
            raceValue = strPickerValue;
            strPickerValue = @"";
            
            break;
        case 3:
            strPickerValue = [arrayOrientation objectAtIndex:row];
            [btOrientation setTitle:strPickerValue forState:UIControlStateNormal];
            orientationValue = strPickerValue;
            strPickerValue = @"";
            
            break;
        case 4:
            strPickerValue = [arrayRelationshipStatus objectAtIndex:row];
            [btRelationShip setTitle:strPickerValue forState:UIControlStateNormal];
            relationshipValue = strPickerValue;
            strPickerValue = @"";
            
            break;
        case 5:
        {
            if([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark){
                
                [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
                [selectedItems removeObject:[arrayConnectionStatus objectAtIndex:row]];
                
                
            }else{
                if( row == 0 && [selectedItems count] > 0) {
                    
                    [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].accessoryType = UITableViewCellAccessoryNone;
                    
                }else {
                    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
                    [selectedItems addObject:[arrayConnectionStatus objectAtIndex:row]];
                    if( row != 0) {
                        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].accessoryType = UITableViewCellAccessoryNone;
                        [selectedItems removeObject:@"Do not display"];
                        
                    }
                }
                
            }
            
            break;
        }
        case 6:
            strPickerValue = [arrayEducation objectAtIndex:row];
            [btEducation setTitle:strPickerValue forState:UIControlStateNormal];
            educationValue = strPickerValue;
            strPickerValue = @"";
            
            break;
        case 7:
            strPickerValue = [arrayEmployeementType objectAtIndex:row];
            [btEmployment setTitle:strPickerValue forState:UIControlStateNormal];
            employmentValue = strPickerValue;
            strPickerValue = @"";
            
            break;
        case 8:
            
            strPickerValue = [arrayPhotoUploadOption objectAtIndex:row];
            photoUploadOptionValue = strPickerValue;
            if([photoUploadOptionValue isEqual:@"Gallery"]){
                //gallaryImage.image = [UIImage imageNamed:@"photoupload_button1.png"];
                //gallaryImage.image = nil;
                [self showGalary];
            }
            else {
                //cameraImage.image = [UIImage imageNamed:@"photoupload_button1.png"];
                //cameraImage.image = nil;
                [self showCamera];
            }
            [viewDatePicker removeFromSuperview];
            
            strPickerValue = @"";
            
            break;
            
        default:
            break;
    }
    if( intFieldIndex != 5 )
        [viewDatePicker removeFromSuperview];
    
}
-(UITableViewCell *)tableView:(UITableView *)
tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int index = indexPath.row;
    switch (intFieldIndex) {
            
        case 1:
        {
            static NSString *identifer = @"AgeRangeCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
            
            if(cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: identifer] ;
                
            }
            UIFont *myFont = [ UIFont fontWithName: @"Helvetica Neue Medium" size: 14.0];
            cell.textLabel.font  = myFont;
            cell.textLabel.textColor= [UIColor colorWithRed:(107/255.0) green:(22/255.0) blue:(135/255.0) alpha:1] ;
            cell.textLabel.text = [arrayAgeRange objectAtIndex:index];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            
            
            if([ageRangeValue isEqual:[arrayAgeRange objectAtIndex:index]]) {
                
                [table_View selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
            
            return  cell;
            
            break;
        }
        case 2:
        {
            static NSString *identifer = @"RaceCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
            
            if(cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: identifer] ;
                
            }
            UIFont *myFont = [ UIFont fontWithName: @"Helvetica Neue Medium" size: 14.0];
            cell.textLabel.font  = myFont;
            cell.textLabel.textColor= [UIColor colorWithRed:(107/255.0) green:(22/255.0) blue:(135/255.0) alpha:1] ;
            cell.textLabel.text = [arrayAgeRange objectAtIndex:index];
            
            cell.textLabel.text = [arrayRace objectAtIndex:index];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            
            
            if([raceValue isEqual:[arrayRace objectAtIndex:index]]) {
                
                [table_View selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                
            }
            
            return  cell;
            
            break;
        }
        case 3:
        {
            static NSString *identifer = @"SexualOrientationCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
            
            if(cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: identifer] ;
                
            }
            UIFont *myFont = [ UIFont fontWithName: @"Helvetica Neue Medium" size: 14.0];
            cell.textLabel.font  = myFont;
            cell.textLabel.textColor= [UIColor colorWithRed:(107/255.0) green:(22/255.0) blue:(135/255.0) alpha:1] ;
            cell.textLabel.text = [arrayAgeRange objectAtIndex:index];
            
            cell.textLabel.text = [arrayOrientation objectAtIndex:index];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            
            
            if([orientationValue isEqual:[arrayOrientation objectAtIndex:index]]) {
                
                [table_View selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                
            }
            
            return  cell;
            
            break;
        }
        case 4:
        {
            static NSString *identifer = @"RelationShipStatusCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
            
            if(cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: identifer] ;
                
            }
            
            UIFont *myFont = [ UIFont fontWithName: @"Helvetica Neue Medium" size: 14.0];
            cell.textLabel.font  = myFont;
            cell.textLabel.textColor= [UIColor colorWithRed:(107/255.0) green:(22/255.0) blue:(135/255.0) alpha:1] ;
            cell.textLabel.text = [arrayAgeRange objectAtIndex:index];
            
            cell.textLabel.text = [arrayRelationshipStatus objectAtIndex:index];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            
            
            if([relationshipValue isEqual:[arrayRelationshipStatus objectAtIndex:index]]) {
                
                [table_View selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                
            }
            
            return  cell;
            
            break;
        }
        case 5:
        {
            static NSString *identifer = @"SeekingConnectionListCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
            if(cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: identifer] ;
                
            }
            UIFont *myFont = [ UIFont fontWithName: @"Helvetica Neue Medium" size: 14.0];
            cell.textLabel.font  = myFont;
            cell.textLabel.textColor= [UIColor colorWithRed:(107/255.0) green:(22/255.0) blue:(135/255.0) alpha:1] ;
            cell.textLabel.text = [arrayAgeRange objectAtIndex:index];
            
            cell.textLabel.text = [arrayConnectionStatus objectAtIndex:index];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            
            if([selectedItems containsObject:[arrayConnectionStatus objectAtIndex:indexPath.row]]) {
                
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }else
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            
            
            if( [selectedItems count] > 1 && index == 0)
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            
            return  cell;
            
            break;
        }
        case 6:
        {
            static NSString *identifer = @"EducationCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
            
            if(cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: identifer] ;
                
            }
            UIFont *myFont = [ UIFont fontWithName: @"Helvetica Neue Medium" size: 14.0];
            cell.textLabel.font  = myFont;
            cell.textLabel.textColor= [UIColor colorWithRed:(107/255.0) green:(22/255.0) blue:(135/255.0) alpha:1] ;
            cell.textLabel.text = [arrayAgeRange objectAtIndex:index];
            
            cell.textLabel.text = [arrayEducation objectAtIndex:index];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            
            
            if([educationValue isEqual:[arrayEducation objectAtIndex:index]]) {
                
                [table_View selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                
            }
            
            return  cell;
            
            break;
        }
        case 7:
        {
            static NSString *identifer = @"EmploymentTypeCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
            
            if(cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: identifer] ;
                
            }
            UIFont *myFont = [ UIFont fontWithName: @"Helvetica Neue Medium" size: 14.0];
            cell.textLabel.font  = myFont;
            cell.textLabel.textColor= [UIColor colorWithRed:(107/255.0) green:(22/255.0) blue:(135/255.0) alpha:1] ;
            cell.textLabel.text = [arrayAgeRange objectAtIndex:index];
            
            cell.textLabel.text = [arrayEmployeementType objectAtIndex:index];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            
            
            if([employmentValue isEqual:[arrayEmployeementType objectAtIndex:index]]) {
                
                [table_View selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                
            }
            
            return  cell;
            
            break;
        }
        case 8:
        {
            static NSString *identifer = @"PhotoUploadCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
            
            if(cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: identifer] ;
                
            }
            UIFont *myFont = [ UIFont fontWithName: @"Helvetica Neue Medium" size: 14.0];
            /*cell.textLabel.font  = myFont;
             //cell.textLabel.textColor= [UIColor colorWithRed:(107/255.0) green:(22/255.0) blue:(135/255.0) alpha:1] ;
             cell.textLabel.textColor = [UIColor whiteColor];
             cell.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
             
             cell.textLabel.textAlignment = NSTextAlignmentCenter;
             
             cell.textLabel.text = [arrayPhotoUploadOption objectAtIndex:index];*/
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            // cell.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
            if( indexPath.row == 0) {
                galleryButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 5, cell.frame.size.width-40, cell.frame.size.height-10)];
                // gallaryImage.backgroundColor = [UIColor clearColor];
                //gallaryImage.opaque = NO;
                //gallaryImage.image = [UIImage imageNamed:@"photoupload_button.png"];
                //cell.backgroundView = imageView1;
                [galleryButton setBackgroundImage:[UIImage imageNamed:@"photoupload_button.png"] forState:UIControlStateNormal];
                //[galleryButton setBackgroundImage:[UIImage imageNamed:@"photoupload_button1.png"] forState:UIControlStateHighlighted];
                [galleryButton setBackgroundImage:[UIImage imageNamed:@"photoupload_button1.png"] forState:UIControlStateSelected];
                [galleryButton setTitle:[arrayPhotoUploadOption objectAtIndex:index] forState:UIControlStateNormal];
                [galleryButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [galleryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [galleryButton addTarget:self
                                  action:@selector(showGalary)
                        forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:galleryButton];
            }else{
                cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 5, cell.frame.size.width-40, cell.frame.size.height-10)];
                //cameraImage.backgroundColor = [UIColor clearColor];
                //cameraImage.opaque = NO;
                // cameraImage.image = [UIImage imageNamed:@"photoupload_button.png"];
                [cameraButton setBackgroundImage:[UIImage imageNamed:@"photoupload_button.png"] forState:UIControlStateNormal];
                //[cameraButton setBackgroundImage:[UIImage imageNamed:@"photoupload_button1.png"] forState:UIControlStateHighlighted];
                [cameraButton setBackgroundImage:[UIImage imageNamed:@"photoupload_button1.png"] forState:UIControlStateSelected];

                [cameraButton setTitle:[arrayPhotoUploadOption objectAtIndex:index] forState:UIControlStateNormal];
                [cameraButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [cameraButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [cameraButton addTarget:self
                                 action:@selector(showCamera)
                       forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:cameraButton];
            }
            
            /* UILabel* textLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, cell.frame.size.width-40, cell.frame.size.height-10)];
             
             textLabel.text = [arrayPhotoUploadOption objectAtIndex:index];
             
             textLabel.textAlignment = NSTextAlignmentCenter;
             
             textLabel.backgroundColor = [UIColor clearColor];
             
             textLabel.textColor = [UIColor blackColor];
             textLabel.font = myFont;
             [cell addSubview:textLabel];
             
             
             if([photoUploadOptionValue isEqual:[arrayPhotoUploadOption objectAtIndex:index]]) {
             
             [table_View selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
             
             }*/
            //NSLog(@">>upload option is added>>");
            return  cell;
            
            break;
        }
        default:
            return  NULL;
            break;
    }
    
}
-(void)openCamera{
    
}
-(void)openGallary{
    
}
- (IBAction)logout:(id)sender {
    [webServices callAPI:APILOGOUT dictionary:NULL];
    [webServices stopUpdateLocationThread];
    [webServices writeSessionId:@"null"];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [loader dismissWithClickedButtonIndex:0 animated:YES];
    
    webServices.isLoginViewControllerCalled = YES;
    //RegistrationViewController *profileVC = [RegistrationViewController new];
    //[self presentViewController:profileVC animated:YES completion:NULL];
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}
-(BOOL)shouldAutorotate
{
    return NO;;
}

/*-(NSUInteger)supportedInterfaceOrientations
 {
 
 return UIDeviceOrientationPortrait;
 }*/

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


@end
