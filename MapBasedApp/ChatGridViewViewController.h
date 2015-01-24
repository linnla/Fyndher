//
//  ChatGridViewViewController.h
//  MapBasedApp
//
//  Created by Harigharan on 05/04/13.
//  Copyright (c) 2013 jitender.k123@gmail.com. All rights reserved.
//

#import "AQGridViewController.h"

@interface ChatGridViewViewController : AQGridViewController
@property (weak, nonatomic) IBOutlet UILabel *messageText;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIImageView *background_img;

@end
