//
//  SearchLocationViewController.m
//  TalkinToTheNet
///Users/jsedayao/c4q/unit-2/week-2/unit-2-hw-1/TalkinToTheNet/TalkinToTheNet/SearchLocationViewController.m
//  Created by Jamaal Sedayao on 9/20/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "SearchLocationViewController.h"
#import "APIManager.h"
#import "SearchResults.h"
#import <CoreLocation/CoreLocation.h>
#import "GoogleMapsViewController.h"

@interface SearchLocationViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate,
CLLocationManagerDelegate
>

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSMutableArray *searchResults;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSString *ourLocationString;

@end

@implementation SearchLocationViewController

#pragma mark Build Map
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchTextField.delegate = self;
    
    //instantiate CLLocation
    if (self.locationManager == nil){
    self.locationManager = [[CLLocationManager alloc]init];
    }
    self.locationManager.delegate = self;
    
    //mandatory check http://stackoverflow.com/questions/24062509/location-services-not-working-in-ios-8
    
//    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
//        [self.locationManager requestAlwaysAuthorization];
//    }
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    self.ourLocationString = [NSString stringWithFormat:@"ll=%f,%f",self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
    
    NSLog(@"our current location: %@",self.ourLocationString);
    NSLog(@"***if current location shows ll=0,0 then check simulator***");
    
}

#pragma mark API method

- (void) makeNewFourSquareAPIRequestWithSearchTerm:(NSString *)searchTerm
                                     callbackBlock:(void(^)())block{
    
    //1.searchTerm - comes from our parameter
    
    //2. url (media=music, term=searchTerm)
    NSString *urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?client_id=QSKOZ40KOU52BNTD0VMXIXHAKOCN0JPI1L4HUCLJXLCCCJ2X&client_secret=HBVWRR33ZVW44AUW21RYONHBPYR5KVMN000JQVV4F1HEWAMN&v=20150919&%@&query=%@",self.ourLocationString,searchTerm];
    
    // NY lat,lng
    // ll=40.714167,-74.006389
    
    // Foursquare API formula
    //https://api.foursquare.com/v2/venues/search
    //    ?client_id=CLIENT_ID
    //    &client_secret=CLIENT_SECRET
    //    &v=20150919
    //    &ll=40.7,-74
    //    &query=sushi
    
    NSString *encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSLog(@"%@", encodedString);
    
    NSURL *url = [NSURL URLWithString:encodedString];
    
    [APIManager GETRequestWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if  (data!=nil){
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:0
                                                                   error:nil];
            NSLog(@"%@",json);
            
            NSArray *venues = [[json objectForKey:@"response"] objectForKey:@"venues"];
            
            //NSLog(@"%@",venues);
            
            self.searchResults = [[NSMutableArray alloc]init];
            
            for (NSDictionary *venue in venues){
                
                NSString *venueName = [venue objectForKey:@"name"];
                NSString *venueURL = [venue objectForKey:@"url"];
                NSDictionary *venueLoc = [venue objectForKey:@"location"];
                NSString *venueStreetAddress = [venueLoc valueForKey:@"address"];
                NSString *venueCity = [venueLoc valueForKey:@"city"];
                NSArray *venueFullAddress = [venue valueForKey:@"formattedAddress"];
                NSString *venueLat = [venueLoc valueForKey:@"lat"];
                NSString *venueLng = [venueLoc valueForKey:@"lng"];
            
                //NSLog(@"lat: %@ lng; %@",lat,lng);
                
                if (venueStreetAddress == nil){
                    venueStreetAddress = @"";
                }
                if (venueCity == nil){
                    venueCity = @"";
                }
                
                SearchResults *resultsObject = [[SearchResults alloc]init];
                
                resultsObject.name = venueName;
                resultsObject.url = venueURL;
                resultsObject.location = [NSString stringWithFormat:@"%@ %@",venueStreetAddress,venueCity];
                resultsObject.lat = venueLat;
                resultsObject.lng = venueLng;
                resultsObject.fullAddress = venueFullAddress;
                resultsObject.streetAddressSnippet = venueStreetAddress;
                
                [self.searchResults addObject:resultsObject];
                
            }
            block();
        }
    }];
    
}

#pragma mark text field delegate

//processes return button
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    //dismisses the keyboard
    [self.view endEditing:YES];
    
    //make an API request
    [self makeNewFourSquareAPIRequestWithSearchTerm:textField.text
                                      callbackBlock:^{
                                          [self.tableView reloadData];
                                      }];
    
    return YES;
}

#pragma mark tableView datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    SearchResults *currentResult = self.searchResults[indexPath.row];
    
    cell.textLabel.text = currentResult.name;
    cell.detailTextLabel.text = currentResult.location;
    
    return cell;
}

#pragma mark segue methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    SearchResults *selectedTarget = self.searchResults[indexPath.row];
    GoogleMapsViewController *viewController = segue.destinationViewController;
    viewController.targetLocation = selectedTarget;
    
}



@end
