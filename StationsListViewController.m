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

@interface StationsListViewController () <UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UITableView *tableview;


@property NSDictionary *bikeJSONDictionary;
@property NSArray *bikeJSONArray;
@property NSDictionary *bikeDictionary;

@property NSArray *bikeArray; // for tableview

@property Bike *bike;


@end

@implementation StationsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    NSString *string = @"";
    [self performBikeAPI:string];
}

#pragma mark - helper methods

-(void) performBikeAPI: (NSString *) text
{
    NSString *string = @"http://www.bayareabikeshare.com/stations/json";
    // NSString *string = @"https://s3.amazonaws.com/mobile-makers-lib/bus.json";

    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:
     ^(NSURLResponse *response, NSData *data, NSError *connectionError) {


         self.bikeJSONDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

         self.bikeArray = [self.bikeJSONDictionary objectForKey:@"stationBeanList"];


//
//         for(NSDictionary *dic in self.bikeArray){
//             Bike *bike = [Bike new];
//             bike.stationName = [dic objectForKey:@"stationName"];
//             bike.availableBikes =[dic objectForKey:@"availableBikes"];
//             bike.latitude = [[dic objectForKey:@"latitude"] doubleValue];
//             bike.longitude = [[dic objectForKey:@"longitude"] doubleValue];
//             bike.stAddress1 = [dic objectForKey:@"stAddress1"];
//             bike.city = [dic objectForKey:@"city"];
//             bike.bikeLocationString =[dic objectForKey:@"location"];
//        
         
         
         
         [self.tableview reloadData];
     }
     ];
    
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    MapViewController *mapVC = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableview indexPathForSelectedRow];

    NSDictionary *dictionary = [self.bikeArray objectAtIndex:indexPath.row];

    self.bike  = [self bikeGetData:dictionary];

    mapVC.selectedBike = self.bike;
    
}

-(Bike *) bikeGetData: (NSDictionary *) dic
{
    Bike *bike = [Bike new];

    bike.stationName = [dic objectForKey:@"stationName"];
    bike.availableBikes =[dic objectForKey:@"availableBikes"];
    bike.latitude = [[dic objectForKey:@"latitude"] doubleValue];
    bike.longitude = [[dic objectForKey:@"longitude"] doubleValue];
    bike.stAddress1 = [dic objectForKey:@"stAddress1"];
    bike.city = [dic objectForKey:@"city"];
    bike.bikeLocationString =[dic objectForKey:@"location"];

    return bike;
}

#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // TODO:
    return self.bikeArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    NSDictionary *dic = [self.bikeArray objectAtIndex:indexPath.row];


    cell.textLabel.text = [dic objectForKey:@"stAddress1"];;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Available bikes: %@",[[dic objectForKey:@"availableBikes"] stringValue]];


    return cell;
}

@end
