//
//  IndividualPoint.h
//  StreetView
//
//  Created by Susan Rudd on 06/09/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


@interface IndividualPoint : NSObject {
    CLLocationCoordinate2D _coordinate;
    CLLocationDistance _altitude;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) CLLocationDistance altitude;

- (id) initWithCoord:(CLLocationCoordinate2D)coord andAltitude:(CLLocationDistance)alt;

@end
