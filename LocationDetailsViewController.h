//
//  LocationDetailsViewController.h
//  MIDAS
//
//  Created by Susan Rudd on 31/05/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PointOfInterest.h"

@interface LocationDetailsViewController : UIViewController {
    PointOfInterest *pointOfInterest;
}

@property (nonatomic) IBOutlet UILabel *latitude;
@property (nonatomic) IBOutlet UILabel *longitude;
@property (nonatomic) IBOutlet UILabel *altitude;
@property (nonatomic) IBOutlet UILabel *physicalAddress;


- (id)initWithNibName:(NSString *)nibNameOrNil andPOI:(PointOfInterest *)poi;

@end
