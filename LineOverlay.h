//
//  LineOverlay.h
//  MapViewer
//
//  Created by Alan McMorran on 11/08/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface LineOverlay : NSObject <MKOverlay> {
    MKPolyline * _line;
    NSString * _name;
    NSNumber * _voltage;
    MKMapRect _bounds;
    CLLocationCoordinate2D _coordinate;
}

@property (nonatomic) MKPolyline * line;
@property (nonatomic) NSString * name;
@property (nonatomic) NSNumber * voltage;

- (id) initWithName: (NSString *) name line: (MKPolyline *) line voltage: (NSNumber *) voltage;

@end
