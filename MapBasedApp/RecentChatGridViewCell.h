//
//  RecentChatGridViewCell.h
//  Fyndher
//
//  Created by Harigharan on 10/04/13.
//  Copyright (c) 2013 Mobile Analytics   All rights reserved.
//

#import "AQGridViewCell.h"
#import <Foundation/Foundation.h>

@interface RecentChatGridViewCell : UITableViewCell {
    
    IBOutlet UIImageView *recentchat_bg;
    
    IBOutlet UILabel *screenName;
    IBOutlet UIImageView *userimage;
    
    IBOutlet UITextField *messageCount;
    IBOutlet UITextView *recentChatMessage;
    IBOutlet UIButton *gotoChat;
    IBOutlet UIImageView *onlineStatus;
    IBOutlet UIImageView *relationshipStats;
}
@property (nonatomic, retain) UIImageView * userimage;
@property (nonatomic, retain) UIImageView * recentchat_bg;
@property (nonatomic, retain) UIImageView * relationshipStats;
@property (nonatomic, retain) UIImageView * onlineStatus;

@property (nonatomic, retain) UILabel * screenName;

@property (nonatomic, retain) UITextField * messageCount;

@property (nonatomic, retain) UITextView * recentChatMessage;

@property (nonatomic, retain) UIButton * gotoChat;
@end
