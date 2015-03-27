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


@interface MapViewController () <MKMapViewDelegate,CLLocationManagerDelegate,UIAlertViewDelegate,UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;

@property NSString *bikeSteps;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [CLLocationManager new];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;

    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;

    [self addAnnotationWithPoint:self.selectedBike];

}



-(void) addAnnotationWithPoint: (Bike *) bike
{


    NSString *locationName = bike.bikeLocationString;
    double longitude = bike.longitude;
    double latitude = bike.latitude;


    MKPointAnnotation *oneAnnotation;
    /////POINT: using latitude,longitude to ADD
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude,longitude);
    oneAnnotation = [MKPointAnnotation new];

    oneAnnotation.title = locationName;

   // oneAnnotation.subtitle = ;
    oneAnnotation.coordinate = coordinate;
    [self.mapView addAnnotation:oneAnnotation];
}


#pragma mark Mapkit Delegate

//if will be called for each annotation
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{

    // now ZOOM in
    CLLocationCoordinate2D center = annotation.coordinate;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.2, 0.2);
    [mapView setRegion:MKCoordinateRegionMake(center, span) animated:YES];

    if(! [annotation isEqual:self.mapView.userLocation]) {

        MKPinAnnotationView *pinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier: nil];

        pinAnnotation.image = [UIImage imageNamed:@"bikeImage"];

        // show title
        pinAnnotation.canShowCallout = YES;
        pinAnnotation.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

        return pinAnnotation;

    } else {

        return nil;
    }

}

//ZOOM in and SPAN out
-(void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    CLLocationCoordinate2D center = view.annotation.coordinate;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    [mapView setRegion:MKCoordinateRegionMake(center, span) animated:YES];


    double latitude = self.selectedBike.latitude;
    double longitude = self.selectedBike.longitude;

    NSLog(@"selected latitude %f", latitude);
    NSLog(@"selected longitude %f", longitude);



    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];

    [self reverseGeocodeLocation:location];








    NSString *steps = self.selectedBike.bikeSteps;
    UIAlertView *alertview = [[UIAlertView alloc]
                              initWithTitle:steps
                              message:@""
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles: nil];
    [alertview show];


}

#pragma mark AlertView
#pragma mark AlertView's UIAlertViewDelegate Protocol
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{


    //Example using button index
    if(buttonIndex == 0) // Try Again button
    {
        //...
    }
    if(buttonIndex == 1) // Cancel button
    {
        //...
    }




}

#pragma mark - helper methods
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

        NSLog(@"disctance %f travel time %f", theRoute.distance,theRoute.expectedTravelTime);
        
    }];
    
}


//use location to find placemark
-(void) reverseGeocodeLocation:(CLLocation *) location
{
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {

        MKPlacemark *placemark = [placemarks objectAtIndex:0];

        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];


        NSLog(@"==PM==%@", placemark.name);
        NSLog(@"==MI==%@", mapItem.name);

        [self pullDirectionsToMapItem:mapItem];

    }];
}

#pragma mark - UISearchbarDelegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{

}







@end
