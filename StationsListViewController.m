//
//  StationsListViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "StationsListViewController.h"
#import "MapViewController.h"
#import "Bike.h"

#import <CoreLocation/CoreLocation.h>


@interface StationsListViewController () <UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property CLLocationManager *locationManager;
@property CLLocation *userLocation;

@property NSDictionary *bikeJSONDictionary;
@property NSArray *bikeJSONArray;
@property NSDictionary *bikeDictionary;

@property NSMutableArray *bikeArray; // for tableview (ALL)
@property NSMutableArray *filteredBikeArray; // for tableview (Filtered)


@property Bike *bike;

@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;
@property BOOL isFiltered;
@property BOOL isAscending;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sortButton;

@end

@implementation StationsListViewController



- (void)viewDidLoad {
    [super viewDidLoad];


    //locationManager: request Auth, update location to get User Location (aka Current Location)
    self.locationManager = [CLLocationManager new];
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.delegate = self;


    self.bikeArray = [NSMutableArray new];
    self.filteredBikeArray = [NSMutableArray new];
    self.isFiltered = NO;
    self.isAscending=YES;
}


#pragma mark - CLLocationManagerDelegate>
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"status %d", status);

    if(status == kCLAuthorizationStatusNotDetermined){
        NSLog(@"status %d", status);
    }else{
        NSLog(@"status %d", status);
        [self.locationManager startUpdatingLocation];
        [self performBikeAPI];
    }



}
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"^^^^^^^%@^^^^%ld",locations, locations.count);

    for (CLLocation *location in locations) {
        if(location.verticalAccuracy < 50 && location.horizontalAccuracy < 50)
        {
            self.userLocation = location;
            [self.locationManager stopUpdatingLocation];
        }

    }
    
}






#pragma mark - helper methods

-(void) performBikeAPI
{
    NSString *string = @"http://www.bayareabikeshare.com/stations/json";

    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {


         self.bikeJSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

         //this JSON data is { time , -[-{},-{}...]}

         NSArray *arrayJSON = [NSArray new];
         arrayJSON = [self.bikeJSONDictionary objectForKey:@"stationBeanList"];
         for (NSDictionary *dic in arrayJSON) { //each of arrayJSON is a dictionary this case

             Bike *bike = [[Bike alloc] initWithDictionary:dic];
             [self.bikeArray addObject: bike ];
              //each of bikeArray is now a Bike object
         }



         //Now calculate distance for each bike station
         for (Bike *bike in self.bikeArray) {
             CLLocationDistance dis = [self getDistanceFromUserLocationToBikeStation:bike.latitude longitude:bike.longitude];
             bike.distance = dis;
         }


         //ok now dump the array
         for (Bike *bike in self.bikeArray) {

             NSLog(@"%@ ==%f\n",bike.stationName,bike.distance);
        }
             
         //since this Block, a async process, needs to reload tableview
         [self.tableView reloadData];
     }
     ];
    
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    MapViewController *mapVC = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

    Bike *bike = [Bike new];
    bike = [self.bikeArray objectAtIndex:indexPath.row];

    mapVC.selectedBike = bike;
    
}



#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if(self.isFiltered)
        return self.filteredBikeArray.count;
    else
        return self.bikeArray.count;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    //if user uses search bar to filter result
    Bike *bike = [Bike new];
    if(self.isFiltered)
         bike = [self.filteredBikeArray  objectAtIndex:indexPath.row];

    else
         bike = [self.bikeArray objectAtIndex:indexPath.row];


    cell.textLabel.text = bike.stationName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Distance: %.2f, Available bikes: %@ ",bike.distance,[bike.availableBikes stringValue]];

    return cell;
}


#pragma mark - UISearchbarDelegate
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if(self.searchBar.text.length == 0)
    {
        self.isFiltered = NO;
    }
    else
    {
        self.isFiltered = YES;

        self.filteredBikeArray = [NSMutableArray new];

        for (Bike *bike in self.bikeArray)
        {

            NSRange nameRange = [bike.stationName rangeOfString:self.searchBar.text options:NSCaseInsensitiveSearch];

            if(nameRange.location != NSNotFound )
            {
                [self.filteredBikeArray  addObject:bike];
            }
        }

    }

    [self.tableView reloadData];
}



#pragma mark - helper methods
-(CLLocationDistance) getDistanceFromUserLocationToBikeStation:(double) latitude longitude:(double) longitude
{
   // CLLocation *
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    CLLocationDistance distance = [self.userLocation distanceFromLocation:location];

    NSLog(@"latitude %f ====longitude %f",self.userLocation.coordinate.latitude,self.userLocation.coordinate.longitude);

    return  distance;

}

#pragma mark - sort tableview  with distance
- (IBAction)sortTableByDistance:(id)sender {

    if(self.isAscending)
    { self.sortButton.title = @"Sort Descending";}
    else
    { self.sortButton.title =@"Sort Ascending";}

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"distance" ascending:self.isAscending];
    NSArray *sortDescriptors = @[sortDescriptor];
    NSArray *sortedArray = [self.bikeArray sortedArrayUsingDescriptors:sortDescriptors];

    //allow user to sort with ascending or descending distance
    self.isAscending = !self.isAscending;



    if(self.isFiltered){
        sortedArray = [self.filteredBikeArray sortedArrayUsingDescriptors:sortDescriptors];
        self.filteredBikeArray = [NSMutableArray new];
        self.filteredBikeArray = [NSMutableArray arrayWithArray:sortedArray];
    }
    else{
        sortedArray = [self.bikeArray sortedArrayUsingDescriptors:sortDescriptors];
        self.bikeArray = [NSMutableArray new];
        self.bikeArray = [NSMutableArray arrayWithArray:sortedArray];
    }


    [self.tableView reloadData];


}


@end
