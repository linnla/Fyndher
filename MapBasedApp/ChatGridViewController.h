//
//  ChatGridViewController.h
//  MapBasedApp
//
//  Created by Harigharan on 04/04/13.
//  Copyright (c) 2013 jitender.k123@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AQGridViewCell.h"

@interface ChatGridViewController :  AQGridViewCell{
    
    IBOutlet UIImageView * imgUser;
    
    IBOutlet UILabel *textMessage;
    
    IBOutlet UIActivityIndicatorView *indicator;
    
}
@property (nonatomic, retain) UIImageView * imgUser;

@property (nonatomic, retain) IBOutlet UILabel *textMessage;

@end
