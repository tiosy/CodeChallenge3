//
//  Bike.h
//  CodeChallenge3
//
//  Created by tim on 3/27/15.
//  Copyright (c) 2015 Mobile Makers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bike : NSObject

@property NSString *stationName;
@property NSNumber *availableBikes;
@property double latitude;
@property double longitude;
@property NSString *stAddress1;
@property NSString *city;
@property NSString *bikeSteps;
@property NSString *bikeLocation;
@property double distance;

-(instancetype)initWithDictionary:(NSDictionary *) dic;

@end
