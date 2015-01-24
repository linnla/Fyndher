//
//  UpdateProfileViewController.h
//  Fyndher
//
//  Created by Laure Linn on 19/10/12.
//  Copyright (c) 2012 Mobile Analytics   All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebAPI.h"
#import <iAd/iAd.h>

@interface UpdateProfileViewController : UIViewController <UITextFieldDelegate, ProcessDataDelegate, ADBannerViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UILabel *pickerView_title;
    IBOutlet UITextField *txtScreenName;
    
    IBOutlet UIScrollView *scrollView;
    IBOutlet UITextField *txtPassWord;
    
    int adminStatus;
    IBOutlet UILabel *tableTitle;
    IBOutlet UIButton *btAgeRange;
    
    IBOutlet UIButton *btEmployment;
    IBOutlet UIButton *btEducation;
    IBOutlet UIButton *btSeekingConnection;
    IBOutlet UIButton *btRelationShip;
    IBOutlet UIButton *btOrientation;
    IBOutlet UIButton *btRace;
    IBOutlet UILabel *profile_image_label;
    IBOutlet UIImageView *profile_image;
    CGFloat animatedDistance;
    
    IBOutlet UITableView *table_View;
    NSMutableData *dataResponse;
    
    IBOutlet UIButton *seekingConnectionDoneButton;
    IBOutlet UIButton *seekingConnectionBackButton;
    WebAPI *webServices;
    IBOutlet UIImageView *seekingConnectionMenuBg;
    
    NSMutableArray *arrayRelationshipStatus;
    NSMutableArray *arrayConnectionStatus;
    NSMutableArray *arrayEmployeementType;
    NSMutableArray *arrayAgeRange;
    NSMutableArray *arrayEducation;
    NSMutableArray *arrayRace;
    NSMutableArray *arrayOrientation;
    NSMutableArray *arrayPhotoUploadOption;
    NSMutableArray *selectedItems;
    NSMutableArray *oldSelectedItems;
    
    UIImageView *cameraImage, *gallaryImage;
    UIButton *cameraButton, *galleryButton;
    IBOutlet UIView *seekingConnectionPickerView;
    IBOutlet UIView *viewDatePicker;
    int intFieldIndex, isUpdateProfileRequestSend, original_Yaxis_value, original_Xaxis_value;
    NSString *strPickerValue,*ageRangeValue, *employmentValue, *educationValue, *relationshipValue, *orientationValue, *raceValue, *photoUploadOptionValue;
    UIAlertView* loader;
    int isRequestSended, photoStatusInfoShown, tableCellSize;
    UIImage *newProfileImage;
    IBOutlet UIImageView *seekingConnectionBg;
    IBOutlet UITableView *seekingConnectionTableView;
    IBOutlet UIImageView *picker_bgimage;
}

@property (strong, nonatomic) ADBannerView *bannerView;


- (IBAction)back:(id)sender;
- (IBAction)openPicker:(id)sender;
- (IBAction)ClosePicker:(id)sender;
@end
