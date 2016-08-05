//
//  CurrentLocation.h
//  MIDAS
//
//  Created by Susan Rudd on 11/04/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CurrentLocation : NSObject <MKAnnotation>{
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;

- (id)initWithCoordinate:(CLLocationCoordinate2D) newCoordinate;

@end
