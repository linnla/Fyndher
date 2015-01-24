//
//  ChatGridViewController.m
//  MapBasedApp
//
//  Created by Harigharan on 04/04/13.
//  Copyright (c) 2013 jitender.k123@gmail.com. All rights reserved.
//

#import "ChatGridViewController.h"

@interface ChatGridViewController ()

@end

@implementation ChatGridViewController {

-@synthesize imgUser, textMessage;

- (id) initWithFrame: (CGRect) frame reuseIdentifier: (NSString *) aReuseIdentifier{
    
    self = [super initWithFrame: frame reuseIdentifier: aReuseIdentifier];
    if ( self == nil )
        return ( nil );
    
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"GridViewCell" owner:nil options:nil];
    
    UIView* mainView = [views objectAtIndex:0];
    
    imgUser = (UIImageView*)[mainView viewWithTag:1];
    imgFavorite = (UIImageView*)[mainView viewWithTag:2];
    imgOnline = (UIImageView*)[mainView viewWithTag:3];
    imgChat = (UIImageView*)[mainView viewWithTag:4];
    
    [self.contentView addSubview:imgUser];
    [self.contentView addSubview:imgFavorite];
    [self.contentView addSubview:imgOnline];
    [self.contentView addSubview:imgChat];
    
    lbName = (UILabel *)[mainView viewWithTag:11];
    lbDistance = (UILabel *)[mainView viewWithTag:12];
    lbMsgCount = (UILabel *)[mainView viewWithTag:13];
    
    [self.contentView addSubview:lbName];
    [self.contentView addSubview:lbDistance];
    [self.contentView addSubview:lbMsgCount];
    
    indicator = (UIActivityIndicatorView *)[mainView viewWithTag:14];
    [self.contentView addSubview:indicator];
    
    return ( self );
}


@end
