//
//  MapViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

#import <CoreLocation/CoreLocation.h>


@interface MapViewController () <MKMapViewDelegate,CLLocationManagerDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;

@property NSString *bikeSteps;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    Has done in Root VC ..no need to set here
//    self.locationManager = [CLLocationManager new];
//    [self.locationManager requestAlwaysAuthorization];
//    self.locationManager.delegate = self;

    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;


    [self addAnnotationWithPoint:self.selectedBike];

}



-(void) addAnnotationWithPoint: (Bike *) bike
{
    double longitude = bike.longitude;
    double latitude = bike.latitude;

    MKPointAnnotation *oneAnnotation = [MKPointAnnotation new];

    oneAnnotation = [MKPointAnnotation new];
    oneAnnotation.title = bike.stationName;
    oneAnnotation.subtitle = [NSString stringWithFormat:@"Available bikes: %@",[bike.availableBikes stringValue]];

    // POINT: using latitude,longitude to ADD
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude,longitude);
    oneAnnotation.coordinate = coordinate;

    //add one annotation
    [self.mapView addAnnotation:oneAnnotation];
}


#pragma mark Mapkit Delegate

//if will be called for each annotation
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{

    if(! [annotation isEqual:self.mapView.userLocation]) {

        // now ZOOM in
        CLLocationCoordinate2D center = annotation.coordinate;
        MKCoordinateSpan span = MKCoordinateSpanMake(0.5, 0.5);
        [mapView setRegion:MKCoordinateRegionMake(center, span) animated:YES];

        MKPinAnnotationView *pinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier: nil];

        pinAnnotation.image = [UIImage imageNamed:@"bikeImage"];


        // show title
        pinAnnotation.canShowCallout = YES;
        pinAnnotation.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        UIImageView *leftImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bikeImage"]];
        pinAnnotation.leftCalloutAccessoryView = leftImage;

        return pinAnnotation;

    } else {

        return nil;
    }

}


-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    //just testing
    NSLog(@"***** annotation: you are selected");
}

//ZOOM in and SPAN out
-(void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    CLLocationCoordinate2D center = view.annotation.coordinate;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.3, 0.3);
    [mapView setRegion:MKCoordinateRegionMake(center, span) animated:YES];

    double latitude = self.selectedBike.latitude;
    double longitude = self.selectedBike.longitude;

    //Creat CLLocation with latitude and logitude
    //put AlertView inside pullDirectionsToMapItem
    // due to async block in pullDirectionsToMapItem
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [self reverseGeocodeLocation:location];

}

//use location to find placemark and then mapItem
//use mapItem to calculate directions/steps from current location to mapItem
-(void) reverseGeocodeLocation:(CLLocation *) location
{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {

        MKPlacemark *placemark = [placemarks objectAtIndex:0];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];

        [self pullDirectionsToMapItem:mapItem];
        
    }];
}




#pragma mark - helper methods
//get directions/steps with mapItem
// alertview inside the block to show steps
-(void) pullDirectionsToMapItem:(MKMapItem *) mapItem
{
    MKDirectionsRequest *request = [MKDirectionsRequest new];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = mapItem;

    MKDirections *direction =[[MKDirections alloc] initWithRequest:request];
    [direction calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {

        NSArray *routes = response.routes;
        MKRoute *theRoute = [routes objectAtIndex:0];
        NSMutableString *stepString =[NSMutableString new];
        int stepCount =1;

        for(MKRouteStep *step in theRoute.steps)
        {
            [stepString appendFormat:@"%i. %@\n", stepCount++ ,step.instructions];

        }

        self.selectedBike.bikeSteps = stepString;
        self.selectedBike.distance = theRoute.distance;

        //NSLog(@"disctance %f travel time %f  %@", theRoute.distance,theRoute.expectedTravelTime, self.selectedBike.bikeSteps);


        //alertview here due to asyc block
        NSString *steps = self.selectedBike.bikeSteps;
        UIAlertView *alertview = [[UIAlertView alloc]
                                    initWithTitle:@"Directions"
                                    message:steps
                                    delegate:self
                                    cancelButtonTitle:@"OK"
                                    otherButtonTitles: nil];

        [alertview show];

    }];
    
}

#pragma mark AlertView
#pragma mark AlertView's UIAlertViewDelegate Protocol
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //no action , just display actionview in this project
}
@end
