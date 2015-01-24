//
//  RecentChatGridViewCell.m
//  Fyndher
//
//  Created by Harigharan on 10/04/13.
//  Copyright (c) 2013 Mobile Analytics   All rights reserved.
//

#import "RecentChatGridViewCell.h"

@implementation RecentChatGridViewCell

@synthesize userimage,recentchat_bg,recentChatMessage,relationshipStats,onlineStatus,screenName,messageCount,gotoChat;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"RecentChatGridViewCell" owner:nil options:nil];
    
    UIView* mainView = [views objectAtIndex:0];
    
    recentchat_bg = (UIImageView*)[mainView viewWithTag:1];
    
    userimage = (UIImageView*)[mainView viewWithTag:2];
    screenName = (UILabel*)[mainView viewWithTag:3];
    relationshipStats = (UIImageView*)[mainView viewWithTag:4];
    onlineStatus = (UIImageView*)[mainView viewWithTag:5];
    
    
    
    messageCount = (UITextField *)[mainView viewWithTag:6];
    recentChatMessage = (UITextView *)[mainView viewWithTag:7];
    gotoChat = (UIButton *)[mainView viewWithTag:8];
    
    [self.contentView addSubview:recentchat_bg];
    [self.contentView addSubview:userimage];
    [self.contentView addSubview:screenName];
    [self.contentView addSubview:onlineStatus];
    
    [self.contentView addSubview:relationshipStats];
    [self.contentView addSubview:messageCount];
    [self.contentView addSubview:recentChatMessage];
    [self.contentView addSubview:gotoChat];
    
    return ( self );
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


@end
