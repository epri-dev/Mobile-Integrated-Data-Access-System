//
//  StreetViewViewController.m
//  StreetView
//
//  Created by Susan Rudd on 11/08/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "StreetViewViewController.h"
#import "PointOfInterestView.h"
#import "LineView.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "IconGenerator.h"
#import "Asset.h"
#import "PositionPoint.h"
#import "POIInformationView.h"
#import "MIDASAppDelegate.h"
#import "PDFViewController.h"
#import "ManualTableViewController.h"

static double INVALID_ANGLE = -181 * M_PI/180.0;
static double FOV_HORIZONTAL = 44.5;
static double FOV_VERTICAL = 34.1; //38.0

static double FOV_HORIZONTAL_IPHONE4S = 56.423; // 55.88
static double FOV_VERTICAL_IPHONE4S = 43.903; //43.44

static double FOV_HORIZONTAL_IPAD3_OR_IPHONE4 = 60.8;
static double FOV_VERTICAL_IPAD3_OR_IPHONE4 = 47.5;

static double MIN_POINT_SEPARATION = 5.0; //Metres
static double THRESHOLD_MIN_DISTANCE = 200.0; //Metres

static double WIDTH_IN_PORTRAIT_IPAD = 768.0; //Metres
static double HEIGHT_IN_PORTRAIT_IPAD = 1024.0; //Metres
static double WIDTH_IN_PORTRAIT_IPHONE = 320.0;//Metres
static double HEIGHT_IN_PORTRAIT_IPHONE = 460.0; //Metres
static double WIDTH_IN_LANDSCAPE_IPHONE = 480.0;//Metres
static double HEIGHT_IN_LANDSCAPE_IPHONE = 300.0; //Metres

@implementation StreetViewViewController

@synthesize captureManager, locationController, myLocation;
@synthesize locationLabel, altitudeLabel, headingLabel, gyroLabel, accLabel;
@synthesize compassView;
@synthesize pois = _pois;
@synthesize managedObjectContext;
@synthesize popoverController, popOvernavController;

- (void)plotSubstationLocations{
    
    NSMutableArray *tempLocationArray = [[NSMutableArray alloc] init];
    NSMutableArray *tempLinesArray = [[NSMutableArray alloc] init];
    
    //set up fetch entity request from data store
    NSFetchRequest *requestAsset = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Asset" inManagedObjectContext:managedObjectContext];
    [requestAsset setEntity:entity];
    
    //fetch the request
    NSError *errorAssetFetch = nil;
    NSArray *fetchResults = [managedObjectContext executeFetchRequest:requestAsset error:&errorAssetFetch];
    if (fetchResults == nil) {
        // Handle the error.
    }else{
        for(Asset *asset in fetchResults){
            
            NSString * uuid = asset.uuid;
            NSString * name = asset.name;
            NSString * type = asset.type;
            
            NSArray *points = [[asset location] allObjects];
            
            if ([type isEqualToString:@"Substation"] && [points count]==1){
                
                PositionPoint *location = [points objectAtIndex:0];
                NSNumber * latitude = [location latitude];
                NSNumber * longitude = [location longitude];
                NSNumber *altitude = [location altitude];
                
                NSMutableSet * voltages = [[NSMutableSet alloc] init];
                NSArray *assetVoltages = [[asset voltageLevels] componentsSeparatedByString:@", "];
                
                for(NSString *objects in assetVoltages){
                    NSNumber * voltage = [NSNumber numberWithDouble:objects.doubleValue];
                    [voltages addObject:voltage];
                }
                
                CLLocationCoordinate2D coordinate;
                coordinate.latitude = latitude.doubleValue;
                coordinate.longitude = longitude.doubleValue;
                
                PointOfInterest *temppoi = [[PointOfInterest alloc] initWithLocation:coordinate title:type altitude:altitude.doubleValue voltages:[voltages allObjects]];
                temppoi.icon = @"Icon.png";
                temppoi.name = name;
                temppoi.circuitDiagram = @"CircuitDiagram.png";
                temppoi.uuid = uuid;
                
                [tempLocationArray addObject:temppoi];
                
                
            }else if(([type isEqualToString:@"ACLineSegment"] || [type isEqualToString:@"Line"]) && [points count]>1){
                //now lets add the lines which are a group of points   
                NSMutableArray *groupOfPoints = [[NSMutableArray alloc] init];
                
                NSNumber *voltage = [NSNumber numberWithDouble:[[asset voltageLevels] doubleValue]];
                
                NSSortDescriptor *sortDescriptor;
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"seqNo"
                                                             ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                NSArray *sortedArray;
                sortedArray = [points sortedArrayUsingDescriptors:sortDescriptors];
                
                for (PositionPoint *point in sortedArray){  
                    NSNumber * latitude = [point latitude];
                    NSNumber * longitude = [point longitude];
                    NSNumber *altitude = [point altitude];
                    
                    IndividualPoint *p = [[IndividualPoint alloc] initWithCoord:CLLocationCoordinate2DMake(latitude.doubleValue,longitude.doubleValue) andAltitude:altitude.doubleValue];
                    [groupOfPoints addObject:p];
                }
                
                Line *line = [[Line alloc] initWithPoints:groupOfPoints andVoltage:voltage.doubleValue];
                line.colour = [IconGenerator getVoltageColour:voltage];
                [tempLinesArray addObject:line];  
            }
            
            
        }
    }
    
    
    //add the array of interesting points to the controller for display
    [self addPois:tempLocationArray];
    
    //and the lines
    [self addLines:tempLinesArray];
    
    if([[mySettings dirty] isEqualToString:@"New Network, Map Loaded"]){
        [mySettings setDirty:@"Clean"];
    }else if([[mySettings dirty] isEqualToString:@"New Network"]){
        [mySettings setDirty:@"New Network, AR Loaded"];
    }
    
}

//- (void)plotSubstationLocations: (NSString *)responseString{
//    
//    NSMutableArray *tempLocationArray = [[NSMutableArray alloc] init];
//    NSMutableArray *tempLinesArray = [[NSMutableArray alloc] init];
//    
//    NSDictionary * root = [responseString JSONValue];
//    NSArray *entries = [root objectForKey:@"Entries"];
//    for (NSArray * element in entries){
//        NSArray * data = [element valueForKey:@"Elements"];
//        //NSLog(@"Entry: %@", [element valueForKey:@"type"]);
//        
//        for (NSArray * row in data) {
//            NSString * uuid = [row valueForKey:@"py/id"]; //mrID
//            NSString * name = [row valueForKey:@"name"];
//            NSString * type = [row valueForKey:@"py/object"];
//            NSArray * location = [row valueForKey:@"Location"];
//            
//            NSArray * points = [location valueForKey:@"PositionPoints"];
//            
//            if ([type isEqualToString:@"Substation"] && [points count]==1){
//                
//                NSArray * voltageLevels = [row valueForKey:@"VoltageLevels"];
//                NSMutableSet * voltages = [[NSMutableSet alloc] init];
//                if (voltageLevels != nil){
//                    for (NSArray * vl in voltageLevels){
//                        NSArray * bv = [vl valueForKey:@"BaseVoltage"];
//                        if (bv != nil){
//                            NSNumber * voltage = [bv valueForKey:@"nominalVoltage"];
//                            [voltages addObject:voltage];
//                        }
//                    }
//                }
//                
//                
//                NSArray * point = [points objectAtIndex:0];
//                
//                NSNumber * latitude = [point valueForKey:@"yPosition"];
//                NSNumber * longitude = [point valueForKey:@"xPosition"];
//                CLLocationCoordinate2D coordinate;
//                coordinate.latitude = latitude.doubleValue;
//                coordinate.longitude = longitude.doubleValue;
//                
//                NSNumber *altitude = [point valueForKey:@"zPosition"];
//                
//                PointOfInterest *temppoi = [[PointOfInterest alloc] initWithLocation:coordinate title:type altitude:altitude.doubleValue voltages:[voltages allObjects]];
//                temppoi.icon = @"Icon.png";
//                temppoi.name = name;
//                temppoi.circuitDiagram = @"CircuitDiagram.png";
//                temppoi.uuid = uuid;
//                
//                [tempLocationArray addObject:temppoi];
//            }else if([type isEqualToString:@"ACLineSegment"] && [points count]>1){
//                
//                //now lets add the lines which are a group of points   
//                NSMutableArray *groupOfPoints = [[NSMutableArray alloc] init];
//                
//                NSNumber * voltage;
//                
//                //work out what voltage it is
//                NSArray * bv = [row valueForKey:@"BaseVoltage"];
//                if (bv != nil){
//                    voltage = [bv valueForKey:@"nominalVoltage"];
//                }
//                
//                if (voltage == nil)
//                    voltage = [[NSNumber alloc] initWithFloat:0.0];
//                
//                NSSortDescriptor *sortDescriptor;
//                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sequenceNumber"
//                                                             ascending:YES];
//                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
//                NSArray *sortedArray;
//                sortedArray = [points sortedArrayUsingDescriptors:sortDescriptors];
//                
//                for (NSArray * point in sortedArray){
//                    
//                    NSNumber * latitude = [point valueForKey:@"yPosition"];
//                    NSNumber * longitude = [point valueForKey:@"xPosition"];
//                    NSNumber *altitude = [point valueForKey:@"zPosition"];
//                    
//                    IndividualPoint *p = [[IndividualPoint alloc] initWithCoord:CLLocationCoordinate2DMake(latitude.doubleValue,longitude.doubleValue) andAltitude:altitude.doubleValue];
//                    [groupOfPoints addObject:p];
//                }
//                
//                Line *line = [[Line alloc] initWithPoints:groupOfPoints andVoltage:voltage.doubleValue];
//                line.colour = [IconGenerator getVoltageColour:voltage];
//                [tempLinesArray addObject:line];
//                
//                
//            }
//            
//            
//        }
//        
//    }    
//    
//    //add the array of interesting points to the controller for display
//    [self addPois:tempLocationArray];
//    
//    //and the lines
//    [self addLines:tempLinesArray];
//    
//}

//add an individual point of interest
- (void)addPoi:(PointOfInterest *)poi{
    [_pois addObject:poi];
    [_poiViews addObject:[self viewForPOI:poi]];
    
}

//add an array of points of interest
- (void)addPois:(NSArray *)newPois{
    //go through and add each poi.
	for (PointOfInterest *poi in newPois) {
		[self addPoi:poi];
	}
}

//add an individual line that is made up of individual points
- (void)addLine:(Line *)inputLine{
    [_lines addObject:inputLine];
    //    [_lineViews addObject:[self viewForLine:inputLine]];
}

//add an array of lines
- (void) addLines:(NSArray *)newLines{
    for(Line *line in newLines){
        [self addLine:line];
    }
}

double lat = 0.0;
double lon = 0.0;
double altitude = 0.0;
bool previouslyOveridden = false;

//work out the vertical angle to the point based on the tilt and altitude
- (double)relativeAngleTakingIntoAccountDistance:(double)distance andAltitudeOfPoi:(double)poiAltitude{
    
    //if altitude has been overridden in the settings view
    if([mySettings isOverrideAltON]){
        altitude = [mySettings altitude];
        previouslyOveridden = true;
    }else{
        //if we have changed our position or if we have turned off the altitude override
        if((myLocation.coordinate.latitude != lat && myLocation.coordinate.longitude != lon) || previouslyOveridden){
            
            //check the accuracy of the altitude from the ipad and if it is more than a value then use reversegeocoding
            if(myLocation.verticalAccuracy < 5 && myLocation.verticalAccuracy >= 0){
                altitude =  myLocation.altitude;
            }else{
                
                //use reverse coding
                NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/api/elevation/json?locations=%g,%g&sensor=true", myLocation.coordinate.latitude, myLocation.coordinate.longitude];
                NSURL *url = [NSURL URLWithString: urlString];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                
                NSError *error = nil;
                NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
                if(error != nil){
                    //if we cant get the internet
                    altitude =  myLocation.altitude;
                }else{                
                    NSString *responseString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
                    NSDictionary * root = [responseString JSONValue];
                    NSArray *entries = [root objectForKey:@"results"];
                    for (NSArray * element in entries){
                        NSNumber * data = [element valueForKey:@"elevation"];
                        //assign the elevation of that location and add 1.5m for the persons height
                        altitude = data.doubleValue + 1.5;
                    }
                }
                
                previouslyOveridden = false;
            }
        }
        
    }
    
    //set the global lat and lon to the actual ones
    lat = myLocation.coordinate.latitude;
    lon = myLocation.coordinate.longitude;
    
    //now work out the angle based on tilt and altitude
    double deltaAlt = poiAltitude - altitude;
    double vertAngle = atan2(deltaAlt, distance);
    double relativeAngle = vertAngle - verticleAngle;
    return relativeAngle;
}

//check if the point is in the screen's FOV
- (FOV_VISBILITY)isInFOVwithHeading:(double)headingDeg andAngleToPOI:(double)angleDeg{
    //This is taken as +/- 20 to compensate for icon    
    double fov = 0;
    
    //apparently iphone3 is actually 4 and 4 is 4S
    if([presentPlatform hasPrefix:@"iPhone4"]){
        fov = FOV_VERTICAL_IPHONE4S / 2;
    }else if([presentPlatform hasPrefix:@"iPad2"]){
        fov = FOV_VERTICAL / 2;
    }else if([presentPlatform hasPrefix:@"iPad3"] || [presentPlatform hasPrefix:@"iPhone3"]){
        fov = FOV_VERTICAL_IPAD3_OR_IPHONE4 / 2;
    }
    
    
    if(UIDeviceOrientationIsLandscape([[UIDevice currentDevice]orientation])){
        if([presentPlatform hasPrefix:@"iPhone4"]){
            fov = FOV_HORIZONTAL_IPHONE4S / 2;
        }else if([presentPlatform hasPrefix:@"iPad2"]){
            fov = FOV_HORIZONTAL / 2;
        }else if([presentPlatform hasPrefix:@"iPad3"] || [presentPlatform hasPrefix:@"iPhone3"]){
            fov = FOV_HORIZONTAL_IPAD3_OR_IPHONE4 / 2;
        }
    }
    
    // the left edge side may become negative so take away the fov and add 360 to compensate
    // same with the right (may have -178 and -134) so we add 360 to both
    headingDeg = fmod(headingDeg + 360, 360);
    angleDeg = fmod(angleDeg + 360, 360);
    
    FOV_VISBILITY isOnScreen;
    
    double diff = fmod(headingDeg + 180 - angleDeg, 360) - 180;
    
    if (abs(diff) < fov)
        isOnScreen = IN;
    else if (diff < 0){
        isOnScreen = RIGHT;
    }else{
        isOnScreen = LEFT;
    }
    
    return isOnScreen;
}

//calculate the angle to the point based on it's lat and lon
- (double)angleToPoiInRadiansWithLat:(double)latpoi andLon:(double)lonpoi{
    double lat = myLocation.coordinate.latitude * M_PI/180.0;
    double lon = myLocation.coordinate.longitude * M_PI/180.0;
    double lonDelta = (lonpoi - lon);
    
    double y = sin(lonDelta) * cos(latpoi);
    double x = (cos(lat) * sin(latpoi)) - (sin(lat) * cos(latpoi)* cos(lonDelta));
    double angle = atan2(y, x); 
    return angle;
}

-(double) distanceInMetresBetweenFirstPointLat: (double) latA Lng: (double) lngA SecondPointLat: (double) latB Lng: (double) lngB{
    double latDelta = (latA - latB);
    double lonDelta = (lngA - lngB);
    
    double R = 6378137.0; // metres
    
    double a = (sin(latDelta/2.0) * sin(latDelta/2.0)) + ((sin(lonDelta/2.0) * sin(lonDelta/2.0)) * cos(latB) *cos(latA)); 
    double c = 2.0 * atan2(sqrt(a), sqrt(1-a)); 
    double distance = R * c;
    
    return distance;
}

- (double) distanceInMetresFromPointA: (CLLocationCoordinate2D) pointA toPointB: (CLLocationCoordinate2D) pointB{
    return [self distanceInMetresBetweenFirstPointLat:pointA.latitude * M_PI/180.0 Lng:pointA.longitude * M_PI/180.0 SecondPointLat:pointB.latitude * M_PI/180.0 Lng:pointB.longitude * M_PI/180.0];
    
}

//calculate the distance to the point based on it's lat and lon
- (double)distanceInMetresFromLat:(double)latpoi andLon:(double)lonpoi{
    
    double lat = myLocation.coordinate.latitude * M_PI/180.0;
    double lon = myLocation.coordinate.longitude * M_PI/180.0;
    
    return [self distanceInMetresBetweenFirstPointLat:latpoi Lng:lonpoi SecondPointLat:lat Lng:lon];
}

- (double) distanceInMetresFromPoint: (CLLocationCoordinate2D) point{
    return [self distanceInMetresFromLat:point.latitude * M_PI/180.0 andLon: point.longitude * M_PI/180.0];    
}

//calculate the point on screen in 2d based on the heading, angles and distance
- (CGPoint)calculatePointOnScreenFromHeading:(double)heading 
                                    andAngle:(double)angle
                                withDistance:(CLLocationDistance)distance
                            andRelativeAngle:(double)relativeAngle{
    
    double FOVwidth = 0;
    double FOVheight = 0;
    
    if([presentPlatform hasPrefix:@"iPhone4"]){
        FOVwidth = FOV_VERTICAL_IPHONE4S;    
        FOVheight = FOV_HORIZONTAL_IPHONE4S;     
    }else if([presentPlatform hasPrefix:@"iPad2"]){
        FOVwidth = FOV_VERTICAL;    
        FOVheight = FOV_HORIZONTAL;    
    }else if([presentPlatform hasPrefix:@"iPad3"] || [presentPlatform hasPrefix:@"iPhone3"]){
        FOVwidth = FOV_VERTICAL_IPAD3_OR_IPHONE4;    
        FOVheight = FOV_HORIZONTAL_IPAD3_OR_IPHONE4;    
    }
    
    
    //Change the heading to be -pi to +pi like the angle
    double head = (2.0*M_PI) - heading;
    if(head < M_PI){
        heading = head * -1;
    }
    double offset = angle - heading;
    
    //now there is an exception to this rule if the heading and angle are either side of the 0
    if(angle < 0 && heading > 0){
        if(angle < (heading - M_PI)){
            offset = offset + (2.0 * M_PI);
        }
    }else if(angle > 0 && heading < 0){
        if(heading < (angle - M_PI)){
            offset = offset - (2.0 * M_PI);
        }
    }
    
    if(UIDeviceOrientationIsLandscape([[UIDevice currentDevice]orientation])){
        
        if([presentPlatform hasPrefix:@"iPhone4"]){
            FOVwidth = FOV_HORIZONTAL_IPHONE4S;    
            FOVheight = FOV_VERTICAL_IPHONE4S;     
        }else if([presentPlatform hasPrefix:@"iPad2"]){
            FOVwidth = FOV_HORIZONTAL;    
            FOVheight = FOV_VERTICAL;    
        }else if([presentPlatform hasPrefix:@"iPad3"] || [presentPlatform hasPrefix:@"iPhone3"]){
            FOVwidth = FOV_HORIZONTAL_IPAD3_OR_IPHONE4;    
            FOVheight = FOV_VERTICAL_IPAD3_OR_IPHONE4;    
        }
        
    }
    
    double xplot = ((offset * ((360.0/FOVwidth) * width)/(2.0*M_PI))) + (width/2.0);
    
    //This is kinda working now too : double xplot = (width/2) - ((((360/37.5) * width)/(2*M_PI)) * sin(heading - angle));
    double ypoint = (height/2.0) - ((((360.0/FOVheight) * height)/(2.0*M_PI)) * sin(relativeAngle));
    
    //now lets set up this pois point to this calculated one
    CGPoint pointOnScreen = CGPointMake(xplot, ypoint);
    
    return pointOnScreen;
}

- (BOOL) crossedFOVforHeading: (double) headingDeg
               withFirstAngle: (double) firstAngleDeg 
                  secondAngle: (double) secondAngleDeg 
{    
    
    /* Work out if the first and second angles are within the FOV */
    FOV_VISBILITY first = [self isInFOVwithHeading:headingDeg andAngleToPOI:firstAngleDeg];
    FOV_VISBILITY second = [self isInFOVwithHeading:headingDeg andAngleToPOI:secondAngleDeg];
    
    /* If the two are not the same then we are crossing the FOV (or going from outside into the FOV) */
    if (first != second){
        // Then we've crossed but need to check it's not just flipping the behind view
        // So we'll check if the difference in angles is less than or equal to 90 deg
        // NSLog(@"Checking FOV for %f, %f and heading %f", firstAngleDeg, secondAngleDeg, headingDeg);
        
        double diff1 = abs(fmod(headingDeg + 180 - firstAngleDeg, 360) - 180);
        double diff2 = abs(fmod(headingDeg + 180 - secondAngleDeg, 360) - 180);
        
        // We now want to make sure that at least one of the angles is within 90 degrees so we don't draw lines behind us.
        if (diff1 <= 90 || diff2<=90){
            return TRUE;
        }
    }
    
    return FALSE;
}


- (CLLocationCoordinate2D) closetPointOnLineStarting: (CLLocationCoordinate2D) start andEnding: (CLLocationCoordinate2D) end toPoint: (CLLocationCoordinate2D) point{
    
	double xDelta = end.longitude - start.longitude;
	double yDelta = end.latitude - start.latitude;
    
	if ((xDelta == 0) && (yDelta == 0)) {
	    return point;
    }
	double u = ((point.longitude - start.longitude) * xDelta + (point.latitude - start.latitude) * yDelta) / (xDelta * xDelta + yDelta * yDelta);
    
	CLLocationCoordinate2D closestPoint;
	if (u < 0) {
	    closestPoint = start;
	} else if (u > 1) {
	    closestPoint = end;
	} else {
	    closestPoint = CLLocationCoordinate2DMake(start.longitude + u * xDelta, start.latitude + u * yDelta);
	}
    
	return closestPoint;
}


- (NSArray*) interprolatePointsForLine: (Line *) line withDistanceInMetresBetweenPoints: (double) minDistance withThreshold: (double) threshold{
    NSMutableArray *interprolatedPoints = [[NSMutableArray alloc] init];
    
    
    [interprolatedPoints addObject:[line.points objectAtIndex:0]];
    
    for (int k = 0; k < [line.points count]-1; k++) {
        IndividualPoint *pointA = [line.points objectAtIndex:k];
        IndividualPoint *pointB = [line.points objectAtIndex:k+1];
        
        CLLocationCoordinate2D closestPoint = [self closetPointOnLineStarting:pointA.coordinate andEnding:pointB.coordinate toPoint:myLocation.coordinate];
        double distance = [self distanceInMetresFromPoint:closestPoint];
        BOOL isInThreshold = distance < threshold;
        
        if (isInThreshold){
            double segmentDistance = [self distanceInMetresFromPointA:pointA.coordinate toPointB:pointB.coordinate];
            if (segmentDistance > minDistance){
                int additionalPoints = floor(segmentDistance/minDistance);
                double xDelta = (pointB.coordinate.longitude - pointA.coordinate.longitude) / additionalPoints;
                double yDelta = (pointB.coordinate.latitude - pointA.coordinate.latitude) / additionalPoints;
                double zDelta = (pointB.altitude - pointA.altitude) / additionalPoints;            
                
                for (int i = 0; i<additionalPoints-1; i++){
                    IndividualPoint *pointI = [[IndividualPoint alloc] initWithCoord:CLLocationCoordinate2DMake(pointA.coordinate.latitude + (i+1)*yDelta,pointA.coordinate.longitude + (i+1)*xDelta) andAltitude:pointA.altitude + (i+1)*zDelta];
                    [interprolatedPoints addObject:pointI];
                }
                
            }
        }
        [interprolatedPoints addObject:pointB]; 
    }
    
    return interprolatedPoints;
}

//plot the lines on the screen
- (void)updateLines{
    
    NSMutableArray *linesToPlotLV = [[NSMutableArray alloc] init];
    NSMutableArray *linesToPlotMV = [[NSMutableArray alloc] init];
    NSMutableArray *linesToPlotHV = [[NSMutableArray alloc] init];
    NSMutableArray *linesToPlotnoVoltage = [[NSMutableArray alloc] init];
    
    //check if we already have a view and if so remove it and start again
    if([[self view] viewWithTag:LVtag]){
        [lowVoltage removeFromSuperview];  
    }
    if([[self view] viewWithTag:MV]){
        [mediumVoltage removeFromSuperview];  
    }
    if([[self view] viewWithTag:HV]){
        [highVoltage removeFromSuperview];  
    }
    if([[self view] viewWithTag:noVolt]){
        [noVoltage removeFromSuperview];  
    }
    
    
    lowVoltage = [[LineView alloc] initWithFrame:self.view.frame];
    mediumVoltage = [[LineView alloc] initWithFrame:self.view.frame];
    highVoltage = [[LineView alloc] initWithFrame:self.view.frame];
    noVoltage = [[LineView alloc] initWithFrame:self.view.frame];
    
    //can assign a view a tag
    lowVoltage.tag = LVtag;
    mediumVoltage.tag = MV;
    highVoltage.tag = HV;
    noVoltage.tag = noVolt;
    
    for(Line *lines in _lines){
        
        BOOL plot = NO;
        NSMutableArray *pointsOnScreen = [[NSMutableArray alloc] init];
        NSMutableArray *scaleArray = [[NSMutableArray alloc] init];
        
        NSArray * linePoints = [self interprolatePointsForLine:lines withDistanceInMetresBetweenPoints:MIN_POINT_SEPARATION withThreshold: THRESHOLD_MIN_DISTANCE];
        
        CGFloat scale = 0.0;
        
        // Keep track of all the previous points in case we need to add them
        CGPoint previousPoint = CGPointMake(0, 0);
        double previousAngle = INVALID_ANGLE;
        // We need to know if it was not added; added explicitly; added as the previous was added explicitly; 
        // or added to complete a crossing of the FOV. As such we need multiple states...
        int previousAdded = 0;
        double previousScale = 0;
        bool hadVisible = false;
        
        for(IndividualPoint *point in linePoints){
            double latpoi = point.coordinate.latitude * M_PI/180.0;
            double lonpoi = point.coordinate.longitude * M_PI/180.0;
            
            //get distance
            double distanceToPoiInM  = [self distanceInMetresFromPoint:point.coordinate];
            
            //and the angle
            double angleInRad = [self angleToPoiInRadiansWithLat:latpoi andLon:lonpoi];
            
            //get heading
            double headingDeg = myHeading;
            double heading = headingDeg * M_PI/180.0;
            
            double head = (2.0*M_PI) - heading;
            if(head < M_PI){
                heading = head * -1;
            }
            
            
            int addPoint = 0;
            bool addPrevious = false;
            if ([self isInFOVwithHeading:headingDeg andAngleToPOI: angleInRad * 180/M_PI] == IN){
                addPoint = 1;
                addPrevious = true;
            }else if (previousAngle != INVALID_ANGLE){
                if (previousAdded == 1)
                    addPoint = 2;
                else if ([self crossedFOVforHeading: heading * 180/M_PI withFirstAngle: previousAngle * 180/M_PI secondAngle:angleInRad * 180/M_PI]){
                    //NSLog(@"Crossed");
                    addPoint = 3;
                    addPrevious = true;
                }
            }
            
            // Find the closest scaling for a line point
            double nscale = 1.0 - (distanceToPoiInM/maxDistance);
            //catch those that go negative and set them to 1.0
            if(nscale < 0){ nscale = 0.0;}
            
            if (nscale > scale)
                scale = nscale;
            //only plot if one of the points on the line is closer than max dist
            if(distanceToPoiInM < maxDistance){
                plot = YES;
            }
            
            //calculate angle in Y
            double relativeAngleInY = [self relativeAngleTakingIntoAccountDistance:distanceToPoiInM andAltitudeOfPoi:point.altitude];
            
            //if yes calculate x and y
            CGPoint pointOnScreen =  [self calculatePointOnScreenFromHeading:heading andAngle:angleInRad withDistance:distanceToPoiInM andRelativeAngle:relativeAngleInY];
        
            // SInce we're using a UIImageView now we need to correct for the status bar being there and move the line up 20 pixels
            if([[UIApplication sharedApplication] isStatusBarHidden] == false)
                pointOnScreen.y+=20;
                        
            if (addPrevious && previousAdded == 0 && previousAngle != INVALID_ANGLE){
                // If we never added the previous point and we are adding a point on the
                // screen now then we need to add the previous point
                [pointsOnScreen addObject:[NSValue valueWithCGPoint:previousPoint]];
                [scaleArray addObject:[NSNumber numberWithDouble:previousScale]];
                hadVisible = true;
            }else if (!addPrevious && previousAdded == 0 && previousAngle != INVALID_ANGLE){
                [pointsOnScreen addObject:[NSValue valueWithCGPoint:previousPoint]];
                [scaleArray addObject:[NSNumber numberWithDouble:0]];                  
            }
            if (addPoint > 0){
                //add to the array of plotting values but only if they are on the screen
                // Add the scale as well
                [pointsOnScreen addObject:[NSValue valueWithCGPoint:pointOnScreen]];
                [scaleArray addObject:[NSNumber numberWithDouble:nscale]];
                hadVisible = true;
            }
            
            previousPoint = pointOnScreen;
            previousScale = nscale;
            previousAdded = addPoint;
            previousAngle = angleInRad;
            
        }
        
        if(hadVisible && plot && [pointsOnScreen count] > 0){
            //NSLog(@"ADDED %d", [pointsOnScreen count]);
            lines.scale = scale;
            lines.pointsOnScreen = pointsOnScreen;
            lines.recursiveScale = scaleArray;
            
            //add all lines to the view here
            if(lines.voltage == LV){
                [linesToPlotLV addObject:lines];
            }else if(lines.voltage == MV){
                [linesToPlotMV addObject:lines];
            }else if(lines.voltage == HV){
                [linesToPlotHV addObject:lines];
            }else if(lines.voltage == 0){
                lines.colour = [UIColor blackColor];
                [linesToPlotnoVoltage addObject:lines];
            }
        }
        
    }
    
    //now add the linesToPlot array to the view for plotting
    [lowVoltage addLines:linesToPlotLV];
    [mediumVoltage addLines:linesToPlotMV];
    [highVoltage addLines:linesToPlotHV];
    [noVoltage addLines:linesToPlotnoVoltage];
    

    [lowVoltage setImage : [lowVoltage refresh]];
    [mediumVoltage setImage : [mediumVoltage refresh]];
    [highVoltage setImage : [highVoltage refresh]];
    [noVoltage setImage : [noVoltage refresh]];


    [lowVoltage setNeedsDisplay];
    [mediumVoltage setNeedsDisplay];
    [highVoltage setNeedsDisplay];
    [noVoltage setNeedsDisplay];
    
    //need to add this near the back so that the POIs are touchable
    //here we can check if the user wants to see the view and add/subtract accordingly
    
    if([mySettings isLowLinesON]){
        [[self view] insertSubview:lowVoltage atIndex:1];  
    }
    if([mySettings isMediumLinesON]){
        [[self view] insertSubview:mediumVoltage atIndex:1];  
    }
    if([mySettings isHighLinesON]){
        [[self view] insertSubview:highVoltage atIndex:1];  
    }    
    
    //add no voltage
    [[self view] insertSubview:noVoltage atIndex:1];  
    
    
}


//plot the POIs on screen
- (void)updatePOIs:(NSTimer *)timer{
    
    if (!_poiViews || _poiViews.count == 0) {
        [self updateLines];
		return;
	}
    
    //only go in here if we have updates our heading and location
    if(myLocation != nil && myHeading != -999.0){
        
        int i=0;
        for (PointOfInterest *item in _pois) {
            CGFloat scale = 1.0;            
            double latpoi = item.coordinate.latitude * M_PI/180.0;
            double lonpoi = item.coordinate.longitude * M_PI/180.0;
            
            //get distance
            double distanceToPoiInM  = [self distanceInMetresFromPoint:item.coordinate];
            
            double angleInRad = [self angleToPoiInRadiansWithLat:latpoi andLon:lonpoi];
            double angleDeg = angleInRad * 180.0/M_PI;
            
            //get heading
            double headingDeg = myHeading;
            double heading = headingDeg * M_PI/180.0;
            
            //is it on screen at the moment
            BOOL doPlot = ([self isInFOVwithHeading:headingDeg andAngleToPOI:angleDeg] == IN);
            
            if(doPlot && distanceToPoiInM < maxDistance){
                
                //calculate angle in Y
                double relativeAngleInY = [self relativeAngleTakingIntoAccountDistance:distanceToPoiInM andAltitudeOfPoi:item.altitude];
                
                //if yes calculate x and y and then carry on
                CGPoint pointOnScreen =  [self calculatePointOnScreenFromHeading:heading andAngle:angleInRad withDistance:distanceToPoiInM andRelativeAngle:relativeAngleInY];
                
                //only plot those that are less than a km away
                if(distanceToPoiInM < maxDistance){
                    
                    UIView *poiView = [_poiViews objectAtIndex:i];
                    
                    //here we need to scale view based on distance
                    scale = scale - (distanceToPoiInM/maxDistance);
                    
                    float poiWidth = poiView.bounds.size.width * scale;
                    float poiHeight = poiView.bounds.size.height * scale;
                    
                    //if contains coordinate, draw it
                    //else remove it from view
                    if(distanceToPoiInM >200){
                        CGSize size = [((PointOfInterestView *)poiView) displayImageBasedOnDistancewithPoi:item];
                        [((PointOfInterestView *)poiView) moveTitleandDescriptionForPoi:item andImageSize:size];
                    }
                    poiView.frame = CGRectMake(pointOnScreen.x, pointOnScreen.y - (32 * scale / 2), poiWidth, poiHeight);
                    poiView.transform = CGAffineTransformMakeScale(scale, scale);
                    
                    //want to add this below the information screen if we have one
                    if([[self view] viewWithTag:999]){
                        [[self view] insertSubview:poiView belowSubview:[[self view] viewWithTag:999]];
                    }else{
                        [[self view] addSubview:poiView]; 
                    }
                    // [[self view] bringSubviewToFront:poiView];
                    
                }
                
            }else{
                //remove the view from the superview so we dont have lots going on at once
                UIView *poiView = [_poiViews objectAtIndex:i];
                [poiView removeFromSuperview];
            }
            
            i++;
        }
        
        //also plot the lines        
        [self updateLines];
        
    }
    
}

- (void)addLabelsToView{
    //core location stuff
    locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 772, 30)];
    [locationLabel setTextColor:[UIColor redColor]];
    [locationLabel setBackgroundColor:[UIColor clearColor]];
    
    altitudeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 772, 30)];
    [altitudeLabel setTextColor:[UIColor redColor]];
    [altitudeLabel setBackgroundColor:[UIColor clearColor]];
    
    //core location stuff
    headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 772, 30)];
    [headingLabel setTextColor:[UIColor redColor]];
    [headingLabel setBackgroundColor:[UIColor clearColor]];
    
    gyroLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 772, 30)];
    [gyroLabel setTextColor:[UIColor redColor]];
    [gyroLabel setBackgroundColor:[UIColor clearColor]];
    
    accLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 130, 772, 30)];
    [accLabel setTextColor:[UIColor redColor]];
    [accLabel setBackgroundColor:[UIColor clearColor]];
    
    [[self view] addSubview:locationLabel];
    [[self view] addSubview:altitudeLabel];
    [[self view] addSubview:headingLabel];
    [[self view] addSubview:gyroLabel];
    [[self view] addSubview:accLabel];

}

//set up the motion and location devices
- (void) startOrientation{
    
    //now lets deal with the location stuff
    locationController = [[Orientation alloc] init];
    locationController.delegate = self;
    locationController.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationController.locationManager.distanceFilter = kCLDistanceFilterNone;
    locationController.locationManager.headingFilter = kCLHeadingFilterNone;
    locationController.motionManager.accelerometerUpdateInterval = 1.0/50.0;
    
    [locationController.locationManager startUpdatingLocation];
    [locationController.locationManager startUpdatingHeading];
    [locationController startAccelerometerDetection];
    
    self.locationController.locationManager.headingOrientation = (CLDeviceOrientation)[[UIDevice currentDevice] orientation]; 
    
}

//stop the motion and location devices when the view dissapears to save battery
- (void)viewDidDisappear:(BOOL)animated{
    [_updateTimer invalidate];
    _updateTimer = nil;
    
    //perhaps want to stop the location and motion updating
    [locationController.locationManager stopUpdatingLocation];
    [locationController.locationManager stopUpdatingHeading];
    [locationController.motionManager stopAccelerometerUpdates];
    
    //stop the session
	[[captureManager captureSession] stopRunning];
    
    [locationLabel removeFromSuperview];
    [altitudeLabel removeFromSuperview];
    [headingLabel removeFromSuperview];
    [gyroLabel removeFromSuperview];
    [accLabel removeFromSuperview];

    [super viewDidDisappear:animated];
    
}

- (void)viewDidUnload{
    [super viewDidUnload];
}

- (void)clearUpViewsForPOIsAndLines{
    [_pois removeAllObjects];
    for(PointOfInterestView *views in _poiViews){
        [views removeFromSuperview];
    }
    
    [_poiViews removeAllObjects];
    [_lines removeAllObjects];
    
    if([[self view] viewWithTag:LVtag]){
        [lowVoltage removeFromSuperview];  
    }
    if([[self view] viewWithTag:MV]){
        [mediumVoltage removeFromSuperview];  
    }
    if([[self view] viewWithTag:HV]){
        [highVoltage removeFromSuperview];  
    }
    
    if([[self view] viewWithTag:noVolt]){
        [noVoltage removeFromSuperview];  
    }
}

- (void)updatingHeadingDirection{
    [[locationController locationManager] stopUpdatingHeading];
    [[locationController locationManager] startUpdatingHeading];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    
    mySettings = [Settings sharedInstance];
    maxDistance = [mySettings maxDistance];
    //start updating heading/location
    [self startOrientation];
    
    presentPlatform = [mySettings device];
    
    if([mySettings isOverrideLocationON]){
        CLLocationCoordinate2D cor = [mySettings location];
        myLocation = [[CLLocation alloc]initWithLatitude:cor.latitude longitude:cor.longitude]; 
    }
    
    //run the session
	[[captureManager captureSession] startRunning];
    
    if (!_updateTimer) {
        //first number is the frequency to update in seconds
		_updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.2
                                                        target:self
                                                      selector:@selector(updatePOIs:)
                                                      userInfo:nil
                                                       repeats:YES];
	}
    
    NSString *response = [mySettings data];
    if(response != nil){
        //only want to do this the once so when there are no entries in the pois array
        //meaning that it hasnt been set up
        //or if we change our url/responseString        
        if([[mySettings dirty] isEqualToString:@"New Network"] || [[mySettings dirty] isEqualToString:@"New Network, Map Loaded"]){
            //unoverride the current location incase we overrode it in the last network but not if we come here from map
            if([mySettings isOverrideLocationON] && [[mySettings dirty] isEqualToString:@"New Network"]){
                [mySettings setOverrideLocationON:FALSE];
            }
            //clear the view
            [self clearUpViewsForPOIsAndLines];
            //plot the data
            [self plotSubstationLocations];
        }else if([[mySettings dirty] isEqualToString:@"Map Changed Something"]){
            //work out whether to plot entire thing or fetch particular asset
        }
        
    }else{
        //remove the data as there is none anymore
        [self clearUpViewsForPOIsAndLines];
    }
    
    //add the labels to the view if we are in debug mode
    if([mySettings isDebugON]){
        [self addLabelsToView];
    }
    
}

- (void)viewDidLoad {
    
    //set up the width and height for the device on first load
    //for some reason this has to come from the statusbarorientation as the
    //orientation of the device isnt updated until it is rotated
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"])
    {
        width = WIDTH_IN_PORTRAIT_IPHONE;
        height = HEIGHT_IN_PORTRAIT_IPHONE;
    }else{
        width = WIDTH_IN_PORTRAIT_IPAD;
        height = HEIGHT_IN_PORTRAIT_IPAD;
    }
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(UIDeviceOrientationIsLandscape(orientation)){
        
        if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"])
        {
            height = HEIGHT_IN_LANDSCAPE_IPHONE;
            width = WIDTH_IN_LANDSCAPE_IPHONE;    
            
        }else{
            height = WIDTH_IN_PORTRAIT_IPAD;
            width = HEIGHT_IN_PORTRAIT_IPAD;    
        }
        
    }
	_updateTimer = nil;
    calibrationTimer = nil;
    myHeading = -999.0;
    verticleAngle = 0.0;
    maxDistance = 1000;
    currentHeading = 0;
    
    _pois = [[NSMutableArray alloc] init];
    _poiViews = [[NSMutableArray alloc] init];
    // _lineViews = [[NSMutableArray alloc] init];
    _lines = [[NSMutableArray alloc] init]; 
    
	[self setCaptureManager:[[CaptureSessionManager alloc] init]];
	[[self captureManager] addVideoInput];
	[[self captureManager] addVideoPreviewLayer];
	[[[self view] layer] addSublayer:[[self captureManager] previewLayer]];
    
    self.captureManager.previewLayer.frame = CGRectMake(0, 0, width, height);
    
    if([[[UIDevice currentDevice] systemVersion] isEqualToString: @"6.0"]){
        self.captureManager.previewLayer.connection.videoOrientation =  [UIApplication sharedApplication].statusBarOrientation;
    }else{
        self.captureManager.previewLayer.orientation = [UIApplication sharedApplication].statusBarOrientation;
    }
    
    //self.locationController.locationManager.headingOrientation = (CLDeviceOrientation)[[UIDevice currentDevice] orientation];
    
    UIImage *compass = [UIImage imageNamed:@"compass.png"];
    compassView = [[UIImageView alloc] initWithImage:compass];
    [compassView setFrame:CGRectMake(width - 100, 40, 80, 80)];
    [[self view] addSubview:compassView];
    
    UIButton *updateHeading = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"heading.png"];
    //tabbar is ~50 
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        [updateHeading setFrame:CGRectMake(width - 60, height - 90, 40, 40)];   
    }else{
        [updateHeading setFrame:CGRectMake(width - 60, height - 110, 40, 40)];
    }
    [updateHeading setImage:image forState:UIControlStateNormal];
    [updateHeading addTarget:self action:@selector(updatingHeadingDirection)
            forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:updateHeading];	
    
}

//depricated in ios6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    }
	return YES;
}

//for rotation in ios6
-(NSUInteger)supportedInterfaceOrientations{
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
    }
    
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    self.locationController.locationManager.headingOrientation = (CLDeviceOrientation)[[UIDevice currentDevice] orientation]; ;   
}

//deal with rotation of the device
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    if(UIDeviceOrientationIsPortrait(toInterfaceOrientation)){
        if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"])
        {
            width = WIDTH_IN_PORTRAIT_IPHONE;
            height = HEIGHT_IN_PORTRAIT_IPHONE;
        }else{
            width = WIDTH_IN_PORTRAIT_IPAD;
            height = HEIGHT_IN_PORTRAIT_IPAD;
        }
    }
    else if(UIDeviceOrientationIsLandscape(toInterfaceOrientation)){
        if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"])
        {
            height = HEIGHT_IN_LANDSCAPE_IPHONE;
            width = WIDTH_IN_LANDSCAPE_IPHONE;    
            
        }else{
            height = WIDTH_IN_PORTRAIT_IPAD;
            width = HEIGHT_IN_PORTRAIT_IPAD;    
        }
    }
    
    self.captureManager.previewLayer.frame = CGRectMake(0, 0, width, height);
    self.captureManager.previewLayer.frame = CGRectMake(0, 0, width, height);
    
    if([[[UIDevice currentDevice] systemVersion] isEqualToString: @"6.0"]){
        self.captureManager.previewLayer.connection.videoOrientation =  toInterfaceOrientation;
    }else{
        self.captureManager.previewLayer.orientation = toInterfaceOrientation;
    }
    compassView.center = CGPointMake(width - 80, 80);
    
}

//update the location
- (void)locationUpdate:(CLLocation *)location {
    
    if([mySettings isOverrideLocationON]){
        CLLocationCoordinate2D cor = [mySettings location];
        myLocation = [[CLLocation alloc]initWithLatitude:cor.latitude longitude:cor.longitude]; 
    }else{
        myLocation = [[CLLocation alloc]initWithCoordinate:location.coordinate altitude:location.altitude horizontalAccuracy:location.horizontalAccuracy verticalAccuracy:location.verticalAccuracy timestamp:location.timestamp]; 
    }
    
    //if debug is on
    if([mySettings isDebugON]){
        locationLabel.text = [NSString stringWithFormat:@"lat:%f long:%f", myLocation.coordinate.latitude,  myLocation.coordinate.longitude];
        altitudeLabel.text = [NSString stringWithFormat:@"alt:%f recalculated alt:%f", myLocation.altitude, altitude];
    }
    
}

- (void)locationError:(NSError *)error {
    if([error code] == 0){
        locationLabel.text = @"No location fix: please ensure WIFI is turned on in the device's settings.";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wifi Disabled"
                                                        message:@"To gain a location fix, WIFI must be enabled, please go to device settings and turn on WIFI."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }else if([error code] == 1){
        locationLabel.text = @"No location fix: please ensure location services are enabled for this app.";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service Disabled"
                                                        message:@"To gain a location fix, location services must be enabled, please go to device settings and turn on location service for this app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

//update the heading
- (void)headingUpdate:(CLHeading *)heading{
    //
    //    if(myHeading == currentHeading){
    //        //do the gyroscope smoothing in here
    //        //take into account the yaw
    //        locationController.motionManager.deviceMotionUpdateInterval = 1.0/50.0;
    //        [locationController.motionManager startDeviceMotionUpdates];
    //        CMAttitude *currentAttitude = locationController.motionManager.deviceMotion.attitude;
    //        double yaw = (double)((currentAttitude.yaw)*180/M_PI);
    //        myHeading = myHeading + yaw;
    //        [locationController.motionManager stopDeviceMotionUpdates];
    //    }else{
    //        currentHeading = myHeading;
    //    }
    
    //set up the compass based on the heading
    float headingCompass = -1.0f * M_PI * heading.trueHeading / 180.0f;
    compassView.transform = CGAffineTransformMakeRotation(headingCompass);
    
    //set the heading for use in the rest of the code
    myHeading = heading.trueHeading;
    
    //if debug is on
    if([mySettings isDebugON]){
        headingLabel.text = [NSString stringWithFormat:@"heading: %f", myHeading];
    }
    
}

double tipY, tipZ, tipX;
#define filter 0.05

//work out which way the user is tilting the device
- (void)acceleratedinX:(double)accX andInY:(double)accY andInZ:(double)accZ{  
    //smooth the accelerated data by applying a low pass filter
    tipY = (accY * filter) + (tipY * (1.0 - filter));
    tipZ = (accZ * filter) + (tipZ * (1.0 - filter));
    tipX = (accX * filter) + (tipX * (1.0 - filter));
    
    //lets assume we are starting in normal potrait
    verticleAngle = atan2(tipY, tipZ) + M_PI/2.0;
    
    if([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown){
        verticleAngle = -atan2(tipY, tipZ) + M_PI/2.0;
    }
    
    else if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft){
        verticleAngle = atan2(tipX, tipZ) + M_PI/2.0;
    }
    
    else if([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight){
        verticleAngle = -atan2(tipX, tipZ) + M_PI/2.0;
    }
    
    if([mySettings isDebugON]){
        gyroLabel.text = [NSString stringWithFormat:@"Angle:%f", (verticleAngle * (180/M_PI))];
        accLabel.text = [NSString stringWithFormat:@"Acc X:%f Y:%f Z:%f", accX, accY, accZ];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    captureManager = nil;
    locationLabel = nil;
    altitudeLabel = nil;
    headingLabel = nil;
    gyroLabel = nil;
    accLabel = nil;
    
    locationController = nil;
    presentPlatform = nil;
    myLocation = nil;
}

- (UIView *)viewForPOI:(PointOfInterest *)newpoi{
    PointOfInterestView *cv = [[PointOfInterestView alloc] initForPOI:newpoi];
    cv.delegate = self;
    return cv;
}

- (UIView *)viewForLine:(Line *)inputLine{
    LineView *cv = [[LineView alloc] initWithFrame:self.view.frame forLine:(Line *)inputLine];
    return cv;
}

//OptionsForPOIDelegate
- (void)popUpOtionsForPOI:(PointOfInterest *)poi{
    POIInformationView *controller = [[POIInformationView alloc] initWithNibName:@"POIInformationView" andPoi:poi];
    controller.delegate = self;
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"]){
        popOvernavController = [[UINavigationController alloc] initWithRootViewController:controller];
        UIPopoverController *poc = [[UIPopoverController alloc] initWithContentViewController:popOvernavController];
        poc.delegate = self;
        self.popoverController = poc;
        poc.popoverContentSize = CGSizeMake(320, 400);
        [poc presentPopoverFromRect:CGRectMake(0, 0, 30, 30) inView:self.view                         permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }else{
        [self.navigationController pushViewController:controller animated:YES];
    }

}

//OptionsForPOIDelegate
- (void)scheduleMaintenance:(PointOfInterest *)poi{
    //0 - schedule maintenance
    ScheduleMaintanence *sm = [[ScheduleMaintanence alloc] initWithNibName:@"ScheduleMaintanence" andPoi:poi];
    sm.managedObjectContext = managedObjectContext;
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"]){
        [self.popoverController dismissPopoverAnimated:YES];
    }
    
    [self.navigationController pushViewController:sm animated:YES];
    
}

//View Manual Delegate
- (void) viewManualFromTable:(PointOfInterest *)poi withStringURL:(NSString *)pdfURLstring{
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"]){
        [self.popoverController dismissPopoverAnimated:YES];
    }
    
    //create our pdf viewer
    PDFViewController *controller = [[PDFViewController alloc] initWithNibName:@"PDFViewController" andPoi:poi andTitle:pdfURLstring];
    [self.navigationController pushViewController:controller animated:YES];
}

//OptionsForPOIDelegate
-(void)viewManual:(PointOfInterest *)poi{
    ManualTableViewController *manualView = [[ManualTableViewController alloc] initWithNibName:@"ManualTableViewController" andPoi:poi];
    manualView.delegate = self;
    manualView.title = @"Manuals";
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"]){
        [popOvernavController pushViewController:manualView animated:YES];
    }else{
        [self.navigationController pushViewController:manualView animated:YES];
    }
}



//OptionsForPOIDelegate
- (void)viewAssetOnMap:(PointOfInterest *)poi{
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"]){
        [self.popoverController dismissPopoverAnimated:YES];
    }
    
    //2 - view asset on map
    MIDASAppDelegate *appDel = (MIDASAppDelegate *)[[UIApplication sharedApplication] delegate];
    UITabBarController *tb = appDel.tabBarController;
    MapViewerViewController *map;
    for(UIViewController *control in [tb viewControllers]){
        if([[[(UINavigationController *)control viewControllers] objectAtIndex:0] isKindOfClass:[MapViewerViewController class]]){
            map = (MapViewerViewController *)[[(UINavigationController *)control viewControllers] objectAtIndex:0];
            if(map != nil){
                map.loadedFromPOI = YES;
                map.poisLocation = poi.coordinate;
                tb.selectedViewController = control;
            }
            break;
        }
    }

}

@end


