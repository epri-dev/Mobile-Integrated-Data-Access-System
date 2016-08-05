//
//  MyClass.h
//  MapViewer
//
//  Created by Alan McMorran on 10/08/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface SubstationAnnotationClass : NSObject <MKAnnotation> {

}

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic) CLLocationCoordinate2D originalCoordinate;
@property (nonatomic, copy) NSArray * voltages;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic) CLLocationDistance altitude;

-(id) initWithUUID: (NSString*) uuid
              name: (NSString*) name
        coordinate:(CLLocationCoordinate2D) coordinate
          voltages: (NSArray*) voltages;

-(id) initWithCoordinate:(CLLocationCoordinate2D) newcoordinate;

@end
