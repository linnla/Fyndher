//
//  ChatGridViewViewController.m
//  MapBasedApp
//
//  Created by Harigharan on 05/04/13.
//  Copyright (c) 2013 jitender.k123@gmail.com. All rights reserved.
//

#import "ChatGridViewViewController.h"

@interface ChatGridViewViewController ()

@end

@implementation ChatGridViewViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setUserImage:nil];
    [self setTextMessage:nil];
    [self setMessageText:nil];
    [self setBackground_img:nil];
    [super viewDidUnload];
}
@end
