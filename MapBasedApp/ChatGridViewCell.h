//
//  ChatGridViewCell.h
//  Fyndher
//
//  Created by Harigharan on 05/04/13.
//  Copyright (c) 2013 Mobile Analytics   All rights reserved.
//

#import "AQGridViewCell.h"
#import <Foundation/Foundation.h>

@interface ChatGridViewCell : UITableViewCell {
    IBOutlet UIImageView *userImage;
    IBOutlet UILabel *messageText;
    IBOutlet UIImageView *image_bg;
    IBOutlet UIImageView *bubble;
    IBOutlet UILabel *timeId;
    IBOutlet UIImageView *profileImage_bg;
}
@property (nonatomic, retain) IBOutlet UIImageView *bubble;
@property (nonatomic, retain) UIImageView * userImage;
@property (nonatomic, retain) UIImageView * image_bg;
@property (nonatomic, retain) UIImageView * profileImage_bg;

@property (nonatomic, retain) IBOutlet UILabel *timeId;
@property (nonatomic, retain) IBOutlet UILabel *messageText;

@end
