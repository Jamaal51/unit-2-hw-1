//
//  GoogleMapsViewController.m
//  TalkinToTheNet
//
//  Created by Jamaal Sedayao on 9/22/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "GoogleMapsViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "APIManager.h"
#import "NSString+NSString_Sanitize.h"

@import GoogleMaps;

@interface GoogleMapsViewController ()
<
GMSMapViewDelegate,
CLLocationManagerDelegate,
UITableViewDataSource,
UITableViewDelegate
>

@property (strong, nonatomic) IBOutlet GMSMapView *googleMapsView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSString *origin;
@property (nonatomic) NSString *destination;
@property (nonatomic) NSArray *steps;
@property (nonatomic) GMSPolyline *polyline;
@property (nonatomic) NSMutableArray *directionsArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GoogleMapsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    double latDouble = [self.targetLocation.lat doubleValue];
    double lngDouble = [self.targetLocation.lng doubleValue];
    
    CLLocationDegrees latitude = latDouble;
    CLLocationDegrees longitude = lngDouble;
    
    self.destination = [NSString stringWithFormat:@"%f,%f",latDouble,lngDouble];
    
    //call self as delegate
    self.googleMapsView.delegate = self;
    
    //instantiate CLLocation
    
    if (self.locationManager == nil){
        self.locationManager = [[CLLocationManager alloc]init];
    }
    self.locationManager.delegate = self;
    //[self.locationManager requestLocation];
    
    //mandatory check
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
        [self.locationManager requestAlwaysAuthorization];
    }
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    //get origin
    
    double latOrigin = self.locationManager.location.coordinate.latitude;
    double lngOrigin = self.locationManager.location.coordinate.longitude;
    
    self.origin = [NSString stringWithFormat:@"%f,%f", latOrigin, lngOrigin];
    
    NSLog(@"coordinates: %.2f, %.2f",self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude);
    
    //self.origin = [NSString stringWithFormat:@"%f,%f",self.locationManager.location.coordinat]
    
    //creates camera that points to location on map
    //    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.71//self.locationManager.location.coordinate.latitude
    //                                                            longitude:-74.00//self.locationManager.location.coordinate.longitude
    //                                                                 zoom:10];
    //NSLog(@"camera: %@",camera);
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude
                                                            longitude:longitude
                                                                 zoom:12];
    

    [self.googleMapsView animateToCameraPosition:camera];
    
    //self.mapView = googleMapsView;
    
    [self.view addSubview:self.googleMapsView];
    
    //self.googleMapsView.padding = UIEdgeInsets
    
    self.googleMapsView.settings.compassButton = YES;
    self.googleMapsView.myLocationEnabled = YES;
    self.googleMapsView.settings.myLocationButton = YES;
    self.googleMapsView.settings.zoomGestures = YES;
    [self.googleMapsView setMinZoom:8 maxZoom:16];
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude);
    marker.title = @"You are here";
    marker.map = self.googleMapsView;
    
    GMSMarker *targetMarker = [[GMSMarker alloc]init];
    targetMarker.position = CLLocationCoordinate2DMake(latitude, longitude);
    targetMarker.title = self.targetLocation.name;
    targetMarker.snippet = self.targetLocation.streetAddressSnippet;
    targetMarker.appearAnimation = kGMSMarkerAnimationPop;
    targetMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    targetMarker.map = self.googleMapsView;
}
//- (void)viewWillLayoutSubviews{
//    
//    self.googleMapsView.padding = UIEdgeInsetsMake(self.viewlength + 50,
//                                                   0,
//                                                   self.view.length + 5,
//                                                   0);
//}

// changes map styles
- (IBAction)setMapType:(id)sender {
    
    switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
        case 0:
            self.googleMapsView.mapType = kGMSTypeNormal;
            break;
        case 1:
            self.googleMapsView.mapType = kGMSTypeSatellite;
            break;
        case 2:
            self.googleMapsView.mapType = kGMSTypeTerrain;
            break;
        default:
            break;
    }
}

- (void)makeNewBikeDirectionsAPIRequest:(void(^)())block {
    
    NSLog(@"orgin:%@, destination:%@", self.origin, self.destination);
    
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&mode=bicycling&sensor=true&key=AIzaSyAd1r6-rsY8RMiF4iXNjoF9quj999DSiaQ",self.origin,self.destination];
    
    NSString *encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSLog(@"%@", encodedString);
    
    NSURL *url = [NSURL URLWithString:encodedString];
    
    //// STREET VIEW ////
    
//    NSString *streetViewString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/streetview?size=600x300&location=%@&heading=151.78&pitch=-0.76&key=AIzaSyAd1r6-rsY8RMiF4iXNjoF9quj999DSiaQ",self.destination];
//
//    NSString *encodedStreetViewString = [streetViewString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//    
//    NSURL *streetViewURL = [NSURL URLWithString:encodedStreetViewString];
//    
//    [APIManager GETRequestWithURL:streetViewURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        
//    }];
    
    [APIManager GETRequestWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if  (data!=nil){
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:0
                                                                   error:nil];
            //NSLog(@"%@",json);
            
            if (!error){
                self.steps = json[@"routes"][0][@"legs"][0][@"steps"];
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    //NSLog(@"Path Steps: %@",self.steps);
                    
                    self.directionsArray = [[NSMutableArray alloc]init];
                    
                    //get directions in array to present in tableview
                    
                    for (NSDictionary *step in self.steps){
                        NSString *htmlInstructions = [step objectForKey:@"html_instructions"];
                        [self.directionsArray addObject:[htmlInstructions stringByStrippingHTML]];
                    }
                    
                    //NSLog(@"directions array: %@", self.directionsArray);
                    
                    
                    GMSPath *path =[GMSPath pathFromEncodedPath:
                                    json[@"routes"][0][@"overview_polyline"][@"points"]];
                    self.polyline = [GMSPolyline polylineWithPath:path];
                    self.polyline.strokeWidth = 7;
                    self.polyline.strokeColor = [UIColor greenColor];
                    self.polyline.map = self.googleMapsView;
                    
                    block ();
                    
                }];
            }
            
        }}];
}

- (IBAction)getBikeDirectionsFromApi:(UIButton *)sender {
    
    
    
    [self makeNewBikeDirectionsAPIRequest:^{
        
        //// STREET VIEW ////
        
            NSString *streetViewString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/streetview?size=600x300&location=%@&heading=151.78&pitch=-0.76&key=AIzaSyAd1r6-rsY8RMiF4iXNjoF9quj999DSiaQ",self.destination];
        
            NSLog(@"Street View String: %@",streetViewString);
        
            NSString *encodedStreetViewString = [streetViewString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        
            NSURL *streetViewURL = [NSURL URLWithString:encodedStreetViewString];
        
            [APIManager GETRequestWithURL:streetViewURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                NSDictionary *svJson = [NSJSONSerialization JSONObjectWithData:data
                                                                       options:0
                                                                         error:nil];
                
                //NSLog(@"Street View json: %@",svJson);
            }];
        
        [self.tableView reloadData];
        NSLog(@"block works");
    }];
    
    
    
}

# pragma mark tableview delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.directionsArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    //cell.textLabel.text = @"working";
    
    //NSString *firstString = [self.directionsArray firstObject];
    
    cell.textLabel.text = [self.directionsArray objectAtIndex:indexPath.row];
    
    return cell;
}

@end
