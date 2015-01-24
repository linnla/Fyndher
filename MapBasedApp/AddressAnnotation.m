//
//  AddressAnnotation.m
//  Fyndher
//
//  Created by Laure Linn on 27/07/12.
//  Copyright (c) 2012 Mobile Analytics   All rights reserved.
//

#import "AddressAnnotation.h"

@implementation AddressAnnotation
@synthesize coordinate,title,subtitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
    coordinate=c;
    NSLog(@"%f,%f",c.latitude,c.longitude);
    return self;

}


@end
