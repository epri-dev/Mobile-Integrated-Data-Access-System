//
//  MapViewerViewController.h
//  MapViewer
//
//  Created by Alan McMorran on 09/08/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PointOfInterest.h"
#import "ScheduleMaintanence.h"
#import "DroppedLocation.h"
#import "TileOverlay.h"
#import "TileOverlayView.h"

//delegate for map settings view
@protocol MapSettingsDelegate

- (void)userWishesToDropPinForLocation;
- (void)userWishesToAddNewAssetLocation;
- (void)userWishesToShowAllAssetNames;
- (void)userWishesToRemoveAllAssetNames;
- (void)changeTiles:(NSString *)type;

@end

//delegate for asset info view
@protocol AddAssetInfoDelegate

- (void)newAssetTitle:(NSString *)title andNewAssetSubTitle:(NSString *)subTitle andAltitude:(NSString *)altitude forAnnotation:(DroppedLocation *)annotation;

@end

//delegate for asset
@protocol AssetInformationDelegate

- (void)scheduleMaintenance:(PointOfInterest *)poi;
- (void)viewManual:(PointOfInterest *)poi withView:(MKAnnotationView *)selectedAnnotationView;
- (void)moveAsset:(PointOfInterest *)poi withView:(MKAnnotationView *)selectedAnnotationView;
- (void)viewLocationDetails:(PointOfInterest *)poi withView:(MKAnnotationView *)selectedAnnotationView;
@end

//delegate for asset info view
@protocol OptionsForPinDelegate

- (void)addAsset:(MKAnnotationView *)view;
- (void)createWorkOrder:(MKAnnotationView *)view;
- (void)removePinFromMap:(DroppedLocation *)annotation;

@end

//delegate for manuals
@protocol ManualsDelegate

- (void) viewManualFromTable:(PointOfInterest *)poi withStringURL:(NSString *)pdfURLstring;

@end

@interface MapViewerViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, MapSettingsDelegate, AddAssetInfoDelegate, AssetInformationDelegate, ManualsDelegate, OptionsForPinDelegate, UIPopoverControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    BOOL firstTime;
    BOOL loadedFromPOI;
    CLLocationCoordinate2D poisLocation;
    UIPopoverController *popoverController;
    BOOL isUserWishingToMoveAsset;
    
    NSManagedObjectContext *managedObjectContext;
    CLLocationCoordinate2D centreNetwork;
    
    double diffLat;
    double diffLong;
    
    UINavigationController *popOverNavigation;
}

@property (nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)setMap:(id)sender;
- (IBAction)settingsButtonPushed:(id)sender;
- (IBAction)moveMapToUsersLocation:(id)sender;
- (IBAction)centreOnNetwork:(id)sender;
- (IBAction)addPin:(id)sender;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL loadedFromPOI;
@property (nonatomic) CLLocationCoordinate2D poisLocation;
@property (nonatomic) UIPopoverController *popoverController;

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) CLLocationCoordinate2D centreNetwork;
@property (nonatomic) IBOutlet UILabel *locationLabel;
@property (nonatomic) IBOutlet UILabel *mapTypeLabel;
@property (nonatomic) NSString *previousMapType;
@property (nonatomic) UINavigationController *popOverNavigation;

@property (nonatomic, strong) TileOverlay *tileOverlay;

//- (void)plotSubstationLocations: (NSString *)responseString;
- (void)plotSubstationLocations;

@end
