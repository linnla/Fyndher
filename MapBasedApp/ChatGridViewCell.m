//
//  ChatGridViewCell.m
//  Fyndher
//
//  Created by Harigharan on 05/04/13.
//  Copyright (c) 2013 Mobile Analytics   All rights reserved.
//

#import "ChatGridViewCell.h"

@implementation ChatGridViewCell
@synthesize userImage, messageText, image_bg, timeId,bubble,profileImage_bg ;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"ChatGridViewCell" owner:nil options:nil];
    
    UIView* mainView = [views objectAtIndex:0];
    
    userImage = (UIImageView*)[mainView viewWithTag:2];
    image_bg = (UIImageView*)[mainView viewWithTag:1];
    bubble = (UIImageView*)[mainView viewWithTag:5];
    profileImage_bg = (UIImageView*)[mainView viewWithTag:6];
    //[self.contentView addSubview:image_bg];
    [self.contentView addSubview:profileImage_bg];
    [self.contentView addSubview:userImage];
    [self.contentView addSubview:bubble];
    
    messageText = (UILabel *)[mainView viewWithTag:3];
    timeId = (UILabel *) [mainView viewWithTag:4];
    [self.contentView addSubview:messageText];
    [self.contentView addSubview:timeId];
    
    
    return ( self );
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
