/*
 * ImageDemoGridViewCell.m
 * Classes
 * 
 * Created by Jim Dovey on 17/4/2010.
 * 
 * Copyright (c) 2010 Jim Dovey
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * 
 * Neither the name of the project's author nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#import "GridViewCell.h"

@implementation GridViewCell
@synthesize imgUser,imgFavorite,imgOnline,imgChat, lbName,lbDistance,lbMsgCount, indicator,grid_bg, more_Button;

- (id) initWithFrame: (CGRect) frame reuseIdentifier: (NSString *) aReuseIdentifier{
   
    self = [super initWithFrame: frame reuseIdentifier: aReuseIdentifier];
    if ( self == nil )
        return ( nil );
    
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"GridViewCell" owner:nil options:nil];
    
    UIView* mainView = [views objectAtIndex:0];
    grid_bg = (UIImageView*)[mainView viewWithTag:15];

    imgUser = (UIImageView*)[mainView viewWithTag:1];
    
    [self.contentView addSubview:mainView];

    imgFavorite = (UIImageView*)[mainView viewWithTag:2];
    imgOnline = (UIImageView*)[mainView viewWithTag:3];
    imgChat = (UIImageView*)[mainView viewWithTag:4];
    
    [self.contentView addSubview:grid_bg];

    [self.contentView addSubview:imgUser];
    [self.contentView addSubview:imgFavorite];
    [self.contentView addSubview:imgOnline];
    [self.contentView addSubview:imgChat];
    
    lbName = (UILabel *)[mainView viewWithTag:11];
    lbDistance = (UILabel *)[mainView viewWithTag:12];
    lbMsgCount = (UITextField *)[mainView viewWithTag:13];
    
    [self.contentView addSubview:lbName];
    [self.contentView addSubview:lbDistance];
    [self.contentView addSubview:lbMsgCount];
    
    indicator = (UIActivityIndicatorView *)[mainView viewWithTag:14];
    [self.contentView addSubview:indicator];
    more_Button = (UIButton *)[mainView viewWithTag:16];
    [self.contentView addSubview:more_Button];
    return ( self );
}

- (CALayer *) glowSelectionLayer
{
    return ( imgUser.layer );
}

- (UIImage *) image
{
    return ( imgUser.image );
}

- (void) setImage: (UIImage *) anImage
{
    imgUser.image = anImage;
    [self setNeedsLayout];
}


@end
