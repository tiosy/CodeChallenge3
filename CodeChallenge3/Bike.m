//
//  Bike.m
//  CodeChallenge3
//
//  Created by tim on 3/27/15.
//  Copyright (c) 2015 Mobile Makers. All rights reserved.
//

#import "Bike.h"

@implementation Bike

-(instancetype) initWithDictionary:(NSDictionary *)dic
{
    self = [super init];
    self.stationName = [dic objectForKey:@"stationName"];
    self.availableBikes =[dic objectForKey:@"availableBikes"];
    self.latitude = [[dic objectForKey:@"latitude"] doubleValue];
    self.longitude = [[dic objectForKey:@"longitude"] doubleValue];
    self.stAddress1 = [dic objectForKey:@"stAddress1"];
    self.city = [dic objectForKey:@"city"];
    self.bikeLocation =[dic objectForKey:@"location"];

    return self;
}


@end
