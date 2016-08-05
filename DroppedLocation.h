//
//  DroppedLocation.h
//  MIDAS
//
//  Created by Susan Rudd on 13/04/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DroppedLocation : NSObject <MKAnnotation>{
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) CLLocationDistance altitude;

- (id)initWithCoordinate:(CLLocationCoordinate2D) newCoordinate;

@end
