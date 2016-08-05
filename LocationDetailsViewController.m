//
//  LocationDetailsViewController.m
//  MIDAS
//
//  Created by Susan Rudd on 31/05/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "LocationDetailsViewController.h"

@interface LocationDetailsViewController ()

@end

@implementation LocationDetailsViewController
@synthesize latitude;
@synthesize longitude;
@synthesize altitude;
@synthesize physicalAddress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil andPOI:(PointOfInterest*)poi{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        pointOfInterest = poi;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [self setContentSizeForViewInPopover:CGSizeMake(320, 400)];
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
        [self.navigationItem setRightBarButtonItem:cancel];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    latitude.text = [NSString stringWithFormat:@"%f", pointOfInterest.coordinate.latitude];
    longitude.text = [NSString stringWithFormat:@"%f", pointOfInterest.coordinate.longitude];
    altitude.text = [NSString stringWithFormat:@"%f", pointOfInterest.altitude];
    
    //Geocoding Block
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc ] initWithLatitude:pointOfInterest.coordinate.latitude longitude:pointOfInterest.coordinate.longitude];
    
    [geocoder reverseGeocodeLocation: location completionHandler:
     
     ^(NSArray *placemarks, NSError *error) {
         //Get nearby address
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         NSDictionary *addressDictionary = [placemark addressDictionary];
         NSArray *address = [addressDictionary valueForKey:@"FormattedAddressLines"];
         NSString *formattedAddress = [[NSString alloc] init];
         
         for(NSString *items in address){
             formattedAddress  = [formattedAddress stringByAppendingFormat:@"%@, \n", items];
         }
         
         physicalAddress.text = formattedAddress;
         
     }];
}

- (void)cancelButtonPressed {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
