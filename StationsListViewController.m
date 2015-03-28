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




@property NSDictionary *bikeJSONDictionary;
@property NSArray *bikeJSONArray;
@property NSDictionary *bikeDictionary;

@property NSMutableArray *bikeArray; // for tableview (ALL)
@property NSMutableArray *filteredBikeArray; // for tableview (Filtered)

@property Bike *bike;

@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;
@property BOOL isFiltered;

@end

@implementation StationsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.bikeArray = [NSMutableArray new];
    self.filteredBikeArray = [NSMutableArray new];
    self.isFiltered = NO;
    

    [self performBikeAPI];
}

#pragma mark - helper methods

-(void) performBikeAPI
{
    NSString *string = @"http://www.bayareabikeshare.com/stations/json";
    // NSString *string = @"https://s3.amazonaws.com/mobile-makers-lib/bus.json";

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
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Available bikes: %@",[bike.availableBikes stringValue]];

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





@end
