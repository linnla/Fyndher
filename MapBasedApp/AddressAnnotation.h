//
//  AddressAnnotation.h
//  Fyndher
//
//  Created by Laure Linn on 27/07/12.
//  Copyright (c) 2012 Mobile Analytics   All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AddressAnnotation : NSObject<MKAnnotation> {
    
    CLLocationCoordinate2D coordinate; 
    NSString *title; 
    NSString *subtitle;
    
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate; 
@property (nonatomic, copy) NSString *title; 
@property (nonatomic, copy) NSString *subtitle;

-(id)initWithCoordinate:(CLLocationCoordinate2D) c;


@end
