//
//  StreetViewViewController.h
//  StreetView
//
//  Created by Susan Rudd on 11/08/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaptureSessionManager.h"
#import "Orientation.h"
#import "PointOfInterest.h"
#import "Line.h"
#import "LineView.h"
#import "Settings.h"
#import "MapViewerViewController.h"

#define LV 0.4
#define MV 11
#define HV 33
#define noVolt 99

#define LVtag 5

typedef enum FOV_VISBILITY {LEFT, IN, RIGHT} FOV_VISBILITY;


@protocol OptionsForPOIDelegate
- (void)popUpOtionsForPOI:(PointOfInterest *)poi;
- (void)scheduleMaintenance:(PointOfInterest *)poi;
- (void)viewManual:(PointOfInterest *)poi;
- (void)viewAssetOnMap:(PointOfInterest *)poi;
@end

@interface StreetViewViewController : UIViewController <OrientationDelegate, OptionsForPOIDelegate, ManualsDelegate, UIPopoverControllerDelegate>{
    double myHeading;
    double currentHeading;
    double verticleAngle;
    double maxDistance;
    
    LineView *highVoltage;
    LineView *mediumVoltage;
    LineView *lowVoltage;
    LineView *noVoltage;
    
    Settings *mySettings;
    
    NSString *presentPlatform;
    UIImageView *compassView;
        
    NSManagedObjectContext *managedObjectContext;
    UIPopoverController *popoverController;
    UINavigationController *popOvernavController;
    
@private
    NSTimer *_updateTimer;
    NSTimer *calibrationTimer;
    NSMutableArray *_pois;
    NSMutableArray *_poiViews;
    
    //NSMutableArray *_lineViews;
    NSMutableArray *_lines;
    double width;
    double height;
    
}

@property (readonly) NSArray *pois;

@property  CaptureSessionManager *captureManager;
@property  Orientation *locationController;
@property (nonatomic) UILabel *locationLabel;
@property (nonatomic) UILabel *altitudeLabel;
@property (nonatomic) UILabel *headingLabel;
@property (nonatomic) UILabel *gyroLabel;
@property (nonatomic) UILabel *accLabel;

@property (nonatomic) CLLocation *myLocation;
@property (nonatomic) UIImageView *compassView;

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) UIPopoverController *popoverController;
@property (nonatomic) UINavigationController *popOvernavController;


//- (void)plotSubstationLocations: (NSString *)responseString;
- (void)plotSubstationLocations;

- (void)clearUpViewsForPOIsAndLines;

- (UIView *)viewForPOI:(PointOfInterest *)newpoi;
- (UIView *)viewForLine:(Line *)inputLine;

- (void)startOrientation;
- (void)updatePOIs:(NSTimer *)timer;
- (void)updateLines;

- (CGPoint)calculatePointOnScreenFromHeading:(double)heading 
                                    andAngle:(double)angle
                                withDistance:(CLLocationDistance)distance
                            andRelativeAngle:(double)relativeAngle;

- (double)distanceInMetresFromLat:(double)latpoi andLon:(double)lonpoi;
- (double)angleToPoiInRadiansWithLat:(double)latpoi andLon:(double)lonpoi;
- (FOV_VISBILITY)isInFOVwithHeading:(double)headingDeg andAngleToPOI:(double)angleDeg;
- (double)relativeAngleTakingIntoAccountDistance:(double)distance andAltitudeOfPoi:(double)poiAltitude;


- (void)addLabelsToView;
- (void)addPoi:(PointOfInterest *)poi;
- (void)addPois:(NSArray *)newPois;
- (void)addLine:(Line *)newLine;
- (void) addLines:(NSArray *)newLines;

@end
