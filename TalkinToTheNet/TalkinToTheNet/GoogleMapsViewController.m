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

@import GoogleMaps;

@interface GoogleMapsViewController () <GMSMapViewDelegate, CLLocationManagerDelegate>


@property (strong, nonatomic) IBOutlet GMSMapView *googleMapsView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSString *origin;
@property (nonatomic) NSString *destination;

@end

@implementation GoogleMapsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    double latDouble = [self.targetLocation.lat doubleValue];
    double lngDouble = [self.targetLocation.lng doubleValue];
    
    CLLocationDegrees latitude = latDouble;
    CLLocationDegrees longitude = lngDouble;
    
    self.destination = [NSString stringWithFormat:@"%f,%f",latDouble,lngDouble];
    
    //pass data
    //NSLog(@"name:%@ location:%@ lat:%@ lng:%@",self.targetLocation.name, self.targetLocation.location, self.targetLocation.lat, self.targetLocation.lng);

    //call self as delegate
    self.googleMapsView.delegate = self;

    //instantiate CLLocation
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
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
    
//    // Creates a marker in the center of the map.
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

- (void)makeNewBikeDirectionsAPIRequest {
    
    NSLog(@"orgin:%@, destination:%@", self.origin, self.destination);
    
}

- (IBAction)getBikeDirectionsFromApi:(UIButton *)sender {
    
    [self makeNewBikeDirectionsAPIRequest];
    
}
@end
