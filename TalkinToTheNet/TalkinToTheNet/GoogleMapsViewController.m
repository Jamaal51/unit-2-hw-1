//
//  GoogleMapsViewController.m
//  TalkinToTheNet
//
//  Created by Jamaal Sedayao on 9/22/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "GoogleMapsViewController.h"
#import <CoreLocation/CoreLocation.h>
@import GoogleMaps;

@interface GoogleMapsViewController () <GMSMapViewDelegate, CLLocationManagerDelegate>


@property (strong, nonatomic) IBOutlet GMSMapView *googleMapsView;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation GoogleMapsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    //self.googleMapsView = [GMSMapView mapWithFrame:self.googleMapsView.bounds camera:camera];

    
    self.googleMapsView.delegate = self;

    
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    NSLog(@"coordinates: %.2f, %.2f",self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude);
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:40.71//self.locationManager.location.coordinate.latitude
                                                            longitude:-74.00//self.locationManager.location.coordinate.longitude
                                                                 zoom:10];
    NSLog(@"camera: %@",camera);

    [self.googleMapsView animateToCameraPosition:camera];
    
    //self.mapView = googleMapsView;

    self.googleMapsView.myLocationEnabled = YES;
    self.googleMapsView.settings.myLocationButton = YES;
    self.googleMapsView.settings.zoomGestures = YES;
    self.googleMapsView.settings.compassButton = YES;
    
    // Creates a marker in the center of the map.
//    GMSMarker *marker = [[GMSMarker alloc] init];
//    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
//    marker.title = @"Sydney";
//    marker.snippet = @"Australia";
//    marker.map = self.googleMapsView;

}
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
@end
