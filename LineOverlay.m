//
//  LineOverlay.m
//  MapViewer
//
//  Created by Alan McMorran on 11/08/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "LineOverlay.h"


@implementation LineOverlay

@synthesize line = _line;
@synthesize name = _name;
@synthesize voltage = _voltage;

@synthesize boundingMapRect = _bounds;
@synthesize coordinate = _coordinate;

- (id) initWithName: (NSString *) overlayName line: (MKPolyline *) pLine voltage:(NSNumber *)voltage{
    self=[super init];
    _name = overlayName;
    _line = pLine;
    _voltage = voltage;
    
    _bounds = [pLine boundingMapRect];
    _coordinate = [pLine coordinate];
    return self;
}


@end
