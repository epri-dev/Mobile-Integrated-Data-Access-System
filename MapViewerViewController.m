//
//  MapViewerViewController.m
//  MapViewer
//
//  Created by Alan McMorran on 09/08/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "MapViewerViewController.h"
#import "ASIHTTPRequest.h"
#import "SubstationAnnotationClass.h"
#import "SBJson.h"
#import "IconGenerator.h"
#import "LineOverlay.h"
#import <objc/runtime.h>
#import "Settings.h"
#import "Orientation.h"
#import "CurrentLocation.h"
#import "MapSettingsViewController.h"
#import "AssetViewController.h"
#import "PopOverViewController.h"
#import "PDFViewController.h"
#import "NamedAssets.h"
#import "Task.h"
#import "ManualTableViewController.h"
#import "LocationDetailsViewController.h"
#import "PinOptionsViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "Asset.h"
#import "PositionPoint.h"

@implementation MapViewerViewController
@synthesize mapView, locationManager, loadedFromPOI,  poisLocation;
@synthesize popoverController, managedObjectContext;
@synthesize centreNetwork, locationLabel, popOverNavigation;
@synthesize tileOverlay, mapTypeLabel, previousMapType;

static char LINE_VOLTAGE;
Settings *mySettings;

- (IBAction)setMap:(id)sender
{
    //strip off the overlays otherwise you cant see the satilite view
    for (id<MKOverlay> overlay in mapView.overlays){
        if([overlay isKindOfClass:[TileOverlay class]]){
            [mapView removeOverlay:overlay];
        }
    }
    
    mapTypeLabel.text = nil;
    
    switch (((UISegmentedControl *)sender).selectedSegmentIndex){
        case 0: {
            mapView.mapType = MKMapTypeStandard;
            //create tile if not apple
            if(previousMapType != nil){
                if(![previousMapType isEqualToString:@"Apple"]){
                    tileOverlay = [[TileOverlay alloc] initOverlay];
                    tileOverlay.mapType = previousMapType;
                    [mapView insertOverlay:tileOverlay atIndex:0];
                    mapTypeLabel.text = previousMapType;
                }
            }
            break;
        }
        case 1: {
            mapView.mapType = MKMapTypeSatellite;
            break;
        }
        case 2: {
            mapView.mapType = MKMapTypeHybrid;
            break;
        }
            
    }
}

- (void)userWishesToDropPinForLocation{
    
    [locationManager stopUpdatingLocation];
    [mapView setShowsUserLocation:NO];
    
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if([annotation isKindOfClass:[CurrentLocation class]]){
            [mapView removeAnnotation:annotation];
            // NSLog(@"removed current location");
        }else if([annotation isKindOfClass:[MKUserLocation class]]){
            [mapView removeAnnotation:annotation];
            // NSLog(@"removed user location");
        }
    }
    
    [mySettings setOverrideLocationON:TRUE];
    mySettings.location = mapView.centerCoordinate;
    
    CurrentLocation *annotation = [[CurrentLocation alloc] initWithCoordinate:mapView.centerCoordinate];
    annotation.title = [NSString stringWithFormat:@"Dropped Location"];
    locationLabel.text = [NSString stringWithFormat:@"%f, %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
    [mapView addAnnotation:annotation];
    
}

- (void)userWishesToAddNewAssetLocation{
    DroppedLocation *annotation = [[DroppedLocation alloc] initWithCoordinate:mapView.centerCoordinate];
    annotation.title = [NSString stringWithFormat:@"New Location"];
    locationLabel.text = [NSString stringWithFormat:@"%f, %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
    [mapView addAnnotation:annotation];
}

- (void)userWishesToShowAllAssetNames{
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if([annotation isKindOfClass:[SubstationAnnotationClass class]]){
            NamedAssets *namedAnnotation = [[NamedAssets alloc] initWithCoordinate:[annotation coordinate]];
            namedAnnotation.title = annotation.title;
            [mapView addAnnotation:namedAnnotation];
        }
    }
}

- (void)userWishesToRemoveAllAssetNames{
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if([annotation isKindOfClass:[NamedAssets class]]){
            [mapView removeAnnotation:annotation];
            //NSLog(@"removed asset names");
        }
    }
}

- (void)changeTiles:(NSString *)type{
    for (id<MKOverlay> overlay in mapView.overlays){
        if([overlay isKindOfClass:[TileOverlay class]]){
            [mapView removeOverlay:overlay];
        }
    }
    
    mapTypeLabel.text = nil;
    
    //create tile if not apple
    if(![type isEqualToString:@"Apple"]){
        MIDASAppDelegate *appDel = (MIDASAppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appDel.netStatus == NotReachable){
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:[NSString stringWithFormat:@"Connection Error"]
                                  message:@"You are not connected to the internet, the Open Street Map tiles cannot be loaded."
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
            alert.delegate = self;
            [alert show];
            mapTypeLabel.text = nil;
        }else{
            tileOverlay = [[TileOverlay alloc] initOverlay];
            tileOverlay.mapType = type;
            [mapView insertOverlay:tileOverlay atIndex:0];
            mapTypeLabel.text = type;
        }
    }
    
    previousMapType = type;
    
}

- (IBAction)moveMapToUsersLocation:(id)sender{
    //now zoom back into actual location
    MKCoordinateSpan span;
    span.latitudeDelta = .01;
    span.longitudeDelta = .01;
    
    MKCoordinateRegion region;
    region.span = span;
    
    region.center = [[locationManager location] coordinate];
    if (region.center.latitude > 90 || region.center.latitude < -90)
        region.center.latitude = 0;
    if (region.center.longitude > 180|| region.center.longitude < -180)
        region.center.longitude = 0;
    
    [mapView setRegion:region animated:YES];
    [mapView regionThatFits:region];
    locationLabel.text = nil;
}

- (void)centreOnNetwork:(id)sender{
    //now zoom back into centre of network
    MKCoordinateSpan span;
    span.latitudeDelta = diffLat;
    span.longitudeDelta = diffLong;
    
    MKCoordinateRegion region;
    region.span = span;
    
    region.center = centreNetwork;
    if (region.center.latitude > 90 || region.center.latitude < -90)
        region.center.latitude = 0;
    if (region.center.longitude > 180|| region.center.longitude < -180)
        region.center.longitude = 0;
    
    [mapView setRegion:region animated:YES];
    [mapView regionThatFits:region];
    locationLabel.text = nil;
}

- (void)scheduleMaintenance:(PointOfInterest *)poi{
    ScheduleMaintanence *wo = [[ScheduleMaintanence alloc] initWithNibName:@"ScheduleMaintanence" andPoi:poi];
    wo.managedObjectContext = managedObjectContext;

    if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"]){
        [self.popoverController dismissPopoverAnimated:YES];
    }

    [self.navigationController pushViewController:wo animated:YES];
}

- (void)viewManual:(PointOfInterest *)poi withView:(MKAnnotationView *)selectedAnnotationView{
    ManualTableViewController *manualView = [[ManualTableViewController alloc] initWithNibName:@"ManualTableViewController" andPoi:poi];
    manualView.delegate = self;
    manualView.title = @"Manuals";
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"]){
        [popOverNavigation pushViewController:manualView animated:YES];
    }else{
        [self.navigationController pushViewController:manualView animated:YES];
    }
}

- (void) viewManualFromTable:(PointOfInterest *)poi withStringURL:(NSString *)pdfURLstring{
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"]){
        [self.popoverController dismissPopoverAnimated:YES];
    }
    
    //create our pdf viewer
    PDFViewController *controller = [[PDFViewController alloc] initWithNibName:@"PDFViewController" andPoi:poi andTitle:pdfURLstring];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)moveAsset:(PointOfInterest *)poi withView:(MKAnnotationView *)selectedAnnotationView{
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"]){
        [self.popoverController dismissPopoverAnimated:YES];
    }
    
    // NSLog(@"moving %@",  ((SubstationAnnotationClass *)(selectedAnnotationView.annotation)).title);
    
    isUserWishingToMoveAsset = YES;
    
    selectedAnnotationView.draggable = YES;
    selectedAnnotationView.canShowCallout = YES;
    selectedAnnotationView.rightCalloutAccessoryView = nil;
    selectedAnnotationView.leftCalloutAccessoryView = nil;
        
    // Add a detail disclosure button to the callout.
    UIButton* rightButton = [UIButton buttonWithType:
                             UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:@"saveLocation.png"];
    [rightButton setFrame:CGRectMake(0, 0, 20, 20)];
    [rightButton setImage:image forState:UIControlStateNormal];
    
    UIButton* leftButton = [UIButton buttonWithType:
                            UIButtonTypeCustom];
    UIImage *discardImage = [UIImage imageNamed:@"discardLocation.png"];
    [leftButton setFrame:CGRectMake(0, 0, 20, 20)];
    [leftButton setImage:discardImage forState:UIControlStateNormal];
    
    
    selectedAnnotationView.rightCalloutAccessoryView = rightButton;
    selectedAnnotationView.rightCalloutAccessoryView.tag = 1;
    selectedAnnotationView.leftCalloutAccessoryView = leftButton;
    selectedAnnotationView.leftCalloutAccessoryView.tag = 2;
    
    // Create and configure a new instance of the Event entity.
    Task *task = (Task *)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:managedObjectContext];
    
    [task setTaskName:@"Moved an existing asset on the map"];
    [task setCreationDate:[NSDate date]];
    [task setAssetName:poi.name];
    [task setStatus:[UIImage imageNamed:@"pending.png"]];
    
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        NSLog(@"%@", error);
    }
    
    [mapView selectAnnotation:selectedAnnotationView.annotation animated:YES];
}

- (void)viewLocationDetails:(PointOfInterest *)poi withView:(MKAnnotationView *)selectedAnnotationView{
    
    LocationDetailsViewController *locationView = [[LocationDetailsViewController alloc] initWithNibName:@"LocationDetailsViewController" andPOI:poi];
    locationView.title = @"Location";
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"]){
        [popOverNavigation pushViewController:locationView animated:YES];
    }else{
        [self.navigationController pushViewController:locationView animated:YES];
    }
}

- (void)newAssetTitle:(NSString *)title andNewAssetSubTitle:(NSString *)subTitle andAltitude:(NSString *)altitude forAnnotation:(DroppedLocation *)annotation{
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"]){
        [self.popoverController dismissPopoverAnimated:YES];
    }
    
    annotation.title = title;
    annotation.subtitle = subTitle;
    annotation.altitude = altitude.doubleValue;
    
    // Create and configure a new instance of the Event entity.
    Task *task = (Task *)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:managedObjectContext];
    
    [task setTaskName:@"Added a new asset to the map"];
    [task setAssetName:title];
    [task setCreationDate:[NSDate date]];
    [task setStatus:[UIImage imageNamed:@"pending.png"]];
    
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        NSLog(@"%@", error);
    }
    
    
}

- (IBAction)settingsButtonPushed:(id)sender{
    MapSettingsViewController *sampleView = [[MapSettingsViewController alloc] init];
    sampleView.delegate = self;
    [sampleView setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    [self presentModalViewController:sampleView animated:YES];
}

- (IBAction)addPin:(id)sender{
    [self userWishesToAddNewAssetLocation];
}

- (void)dealloc
{
    for(SubstationAnnotationClass *annotation in mapView.annotations){
        [mapView removeAnnotation:annotation];
    }
    locationLabel.text = nil;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark MapKit

- (MKOverlayView *)mapView:(MKMapView *)mapViewIn viewForOverlay:(id <MKOverlay>)overlay{
    
    if([overlay isKindOfClass:[TileOverlay class]]){
        TileOverlayView *tileView = [[TileOverlayView alloc] initWithOverlay:overlay];
        tileView.mapType = ((TileOverlay *)overlay).mapType;
        tileView.tileAlpha = 1.0; // e.g. 0.6 alpha for semi-transparent overlay
        return tileView;
    }
    
    if ([overlay isKindOfClass:[MKPolyline class]]){
        
        NSNumber * voltage = objc_getAssociatedObject(overlay, &LINE_VOLTAGE);
        UIColor * color = [IconGenerator getVoltageColour:voltage];
        MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        polylineView.strokeColor = color;//[UIColor blueColor];
        polylineView.lineWidth = 1.5;
        return polylineView;
    }
    
    return [[MKOverlayView alloc] initWithOverlay:overlay];
    
}

- (void) showOptionsToOverride{
    //need to add annotation to show pin
    
    [mySettings setOverrideLocationON:TRUE];
    
    CurrentLocation *annotation = [[CurrentLocation alloc] initWithCoordinate:[[mapView userLocation] coordinate]];
    annotation.title = [NSString stringWithFormat:@"Overridden Location"];
    locationLabel.text = [NSString stringWithFormat:@"%f, %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
    [mapView addAnnotation:annotation];
    
    mySettings.location = [[mapView userLocation] coordinate];
    
    [locationManager stopUpdatingLocation];
    [mapView setShowsUserLocation:NO];
}


- (void) showOptionsToUnOverride{
    [mySettings setOverrideLocationON:FALSE];
    
    [locationManager startUpdatingLocation];
    
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if([annotation isKindOfClass:[CurrentLocation class]]){
            [mapView removeAnnotation:annotation];
            // NSLog(@"removed current location");
        }
    }
    
    [[mapView userLocation] coordinate];
    [mapView setShowsUserLocation:YES];
    
    //now zoom back into actual location
    MKCoordinateSpan span;
    span.latitudeDelta = .01;
    span.longitudeDelta = .01;
    
    MKCoordinateRegion region;
    region.span = span;
    
    region.center = [[locationManager location] coordinate];
    if (region.center.latitude > 90 || region.center.latitude < -90)
        region.center.latitude = 0;
    if (region.center.longitude > 180|| region.center.longitude < -180)
        region.center.longitude = 0;
    
    [mapView setRegion:region animated:YES];
    [mapView regionThatFits:region];
    locationLabel.text = nil;
    
}

- (void)mapView:(MKMapView *)mapViewIn annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    if([view.annotation isKindOfClass:[SubstationAnnotationClass class]] && !isUserWishingToMoveAsset){
        
        [mapViewIn deselectAnnotation:view.annotation animated:YES];
        PopOverViewController *popView = [[PopOverViewController alloc] initWithNibName:@"PopOverViewController" andAnnotation:((SubstationAnnotationClass *)view.annotation) andAnnotationView:view bundle:nil];
        popView.title = ((SubstationAnnotationClass *)view.annotation).title;
        popView.delegate = self;
        
        if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"]){
                        
            popOverNavigation = [[UINavigationController alloc] initWithRootViewController:popView];
            
            UIPopoverController *poc = [[UIPopoverController alloc] initWithContentViewController:popOverNavigation];
            //hold ref to popover in an ivar
            self.popoverController = poc;
            
            //size as needed
            poc.popoverContentSize = CGSizeMake(320, 400);
            
            //show the popover next to the annotation view (pin)
            [poc presentPopoverFromRect:view.bounds inView:view
               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            
        }else{
            [self.navigationController pushViewController:popView animated:YES];
        }
        
    }else if([view.annotation isKindOfClass: [DroppedLocation class]]){
        
        [mapViewIn deselectAnnotation:view.annotation animated:YES];
        
        if([control tag] == 1){
            
            PinOptionsViewController *pinOptions = [[PinOptionsViewController alloc] initWithNibName:@"PinOptionsViewController" bundle:nil andAnnotationView:view];
            pinOptions.delegate = self;
            pinOptions.title = @"At This Location";
            
            if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"]){
                popOverNavigation = [[UINavigationController alloc] initWithRootViewController:pinOptions];
                UIPopoverController *poc = [[UIPopoverController alloc] initWithContentViewController:popOverNavigation];
                self.popoverController = poc;
                poc.popoverContentSize = CGSizeMake(320, 400);
                
                //show the popover next to the annotation view (pin)
                [poc presentPopoverFromRect:view.bounds inView:view
                   permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }else{
                [self.navigationController pushViewController:pinOptions animated:YES];
            }
        }else if([control tag] == 2){
            [self removePinFromMap:view.annotation];
        }
        
        
    }
    
    //this will be reached if we chose the tick or cross
    else if([view.annotation isKindOfClass:[SubstationAnnotationClass class]] && isUserWishingToMoveAsset){
        view.draggable = NO;
        view.canShowCallout = YES;
        view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];
        view.leftCalloutAccessoryView = nil;
        isUserWishingToMoveAsset = NO;
        locationLabel.text = nil;
        
        if([control tag] ==2){
            ((SubstationAnnotationClass *)view.annotation).coordinate = ((SubstationAnnotationClass *)view.annotation).originalCoordinate;
        }
        
        [mapViewIn deselectAnnotation:view.annotation animated:YES];
    }
}

//OptionsForPinDelegate
- (void)addAsset:(MKAnnotationView *)view{
    AssetViewController *assetInfoView = [[AssetViewController alloc] initWithNibName:@"AssetViewController" andAnnotation:(DroppedLocation *)view.annotation bundle:nil];
    
    assetInfoView.delegate = self;
    assetInfoView.passedTitle = [NSString stringWithString:((DroppedLocation *)view.annotation).title];
    
    CLLocationDistance altitude = ((DroppedLocation *)view.annotation).altitude;
    NSString *distanceString = [[NSString alloc] initWithFormat: @"%f", altitude];
    if(distanceString != nil)
        assetInfoView.passedAltitude = distanceString;
    
    if((((DroppedLocation *)view.annotation).subtitle) != nil)
        assetInfoView.passedSubTitle = [NSString stringWithString:((DroppedLocation *)view.annotation).subtitle];
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"]){
        assetInfoView.title = @"Add Asset Info";
        [popOverNavigation pushViewController:assetInfoView animated:YES];
        
    }else{
        [self.navigationController pushViewController:assetInfoView animated:YES];
    }
}

//OptionsForPinDelegate
- (void)createWorkOrder:(MKAnnotationView *)view{
    
    DroppedLocation *annotation = (DroppedLocation *)view.annotation;
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"]){
        [self.popoverController dismissPopoverAnimated:YES];
    }
    
    NSString *streetLocation = [NSString stringWithFormat:@"%f %f", annotation.coordinate.latitude, annotation.coordinate.longitude];
    
    //ScheduleMaintanence *wo;
    ScheduleMaintanence *wo;
    if(annotation.subtitle != nil){
        CLLocationCoordinate2D cood = CLLocationCoordinate2DMake(annotation.coordinate.latitude, annotation.coordinate.longitude);
        PointOfInterest *poi = [[PointOfInterest alloc] initWithLocation:cood title:annotation.subtitle altitude:annotation.altitude];
        poi.name = annotation.title;
        wo = [[ScheduleMaintanence alloc] initWithNibName:@"ScheduleMaintanence" andPoi:poi];

    }else{
       wo = [[ScheduleMaintanence alloc] initWithNibName:@"ScheduleMaintanence" andLocation:streetLocation];

    }
    
    wo.managedObjectContext = managedObjectContext;
    [self.navigationController pushViewController:wo animated:YES];
}

//OptionsForPinDelegate
- (void)removePinFromMap:(DroppedLocation *)annotation{
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"]){
        [self.popoverController dismissPopoverAnimated:YES];
    }
    
    // Create and configure a new instance of the Event entity.
    Task *task = (Task *)[NSEntityDescription insertNewObjectForEntityForName:@"Task" inManagedObjectContext:managedObjectContext];
    
    [task setTaskName:@"Deleted a new asset from the map"];
    [task setCreationDate:[NSDate date]];
    [task setAssetName:annotation.title];
    [task setStatus:[UIImage imageNamed:@"pending.png"]];
    
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        NSLog(@"%@", error);
    }
    
    [mapView removeAnnotation:annotation];
    locationLabel.text = nil;
}

//OptionsForPinDelegate
-(MKAnnotationView *)mapView:(MKMapView *)mapViewIn viewForAnnotation:(id)annotation{
    
    // If it's the user location
    if ([annotation isKindOfClass:[MKUserLocation class]]){
        
        ((MKUserLocation *)annotation).title = @"GPS's Current Location";
        
        return nil;
    }
    
    if([annotation isKindOfClass:[SubstationAnnotationClass class]]){
        
        static NSString *subIdentifier=@"SubIdentifier";
        
        MKAnnotationView *annotationView = [mapViewIn dequeueReusableAnnotationViewWithIdentifier:subIdentifier];
        
        if(!annotationView){
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        }else{
            annotationView.annotation = annotation;
        }
        
        NSArray * voltages = [(SubstationAnnotationClass *)annotation voltages];
        int size = 16;
        if ([voltages count] > 1)
            size = 24;
        annotationView.image=[IconGenerator getIconOfWidth:size height:size voltages:voltages];
        annotationView.canShowCallout = YES;
        
        if(!isUserWishingToMoveAsset){
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeInfoLight];
        }
        
        return annotationView;
    }
    
    if([annotation isKindOfClass: [DroppedLocation class]]){
        
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView*    asset = (MKPinAnnotationView*)[mapViewIn
                                                               dequeueReusableAnnotationViewWithIdentifier:@"assetPin"];
        if (!asset)
        {
            
            
            // If an existing pin view was not available, create one.
            asset = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                    reuseIdentifier:@"assetPin"];
        }
        else{
            asset.annotation = annotation;
        }
        
        asset.canShowCallout = YES;
        asset.draggable = YES;
        asset.pinColor = MKPinAnnotationColorPurple;
        
        UIButton* leftButton = [UIButton buttonWithType:
                                UIButtonTypeCustom];
        UIImage *discardImage = [UIImage imageNamed:@"rubbish.png"];
        [leftButton setFrame:CGRectMake(0, 0, 20, 20)];
        [leftButton setImage:discardImage forState:UIControlStateNormal];
        
        asset.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        asset.rightCalloutAccessoryView.tag = 1;
        asset.leftCalloutAccessoryView = leftButton;
        asset.leftCalloutAccessoryView.tag = 2;
        
        return asset;
    }
    
    if([annotation isKindOfClass: [CurrentLocation class]]){
        
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView*    pinView = (MKPinAnnotationView*)[mapViewIn
                                                                 dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:@"CustomPinAnnotationView"];
        }
        else{
            pinView.annotation = annotation;
        }
        
        pinView.canShowCallout = YES;
        pinView.draggable = YES;
        
        // Add a detail disclosure button to the callout.
        UIButton* rightButton = [UIButton buttonWithType:
                                 UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"Refresh.png"];
        [rightButton setFrame:CGRectMake(0, 0, 20, 20)];
        [rightButton setImage:image forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(showOptionsToUnOverride)
              forControlEvents:UIControlEventTouchUpInside];
        pinView.rightCalloutAccessoryView = rightButton;
        
        return pinView;
    }
    
    if([annotation isKindOfClass: [NamedAssets class]]){
        static NSString *namedAssetsIdentifier = @"namedAssetLabel";
        MKAnnotationView *av = [mapViewIn dequeueReusableAnnotationViewWithIdentifier:namedAssetsIdentifier];
        if (av == nil)
        {
            av = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:namedAssetsIdentifier];
            
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, -20, 100, 15)];
            lbl.backgroundColor = [UIColor clearColor];
            lbl.textColor = [UIColor blackColor];
            lbl.font = [UIFont boldSystemFontOfSize:13.0f];
            lbl.tag = 42;
            [av addSubview:lbl];
            
            //Following lets the callout still work if you tap on the label...
            // av.canShowCallout = YES;
            av.frame = lbl.frame;
        }
        else
        {
            av.annotation = annotation;
        }
        
        UILabel *lbl = (UILabel *)[av viewWithTag:42];
        lbl.text = ((NamedAssets *)annotation).title;
        
        return av;
    }
    
    return nil;
    
}

- (void)mapView:(MKMapView *)mapViewIn annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState{
    
    if (newState == MKAnnotationViewDragStateStarting) {
        locationLabel.text = [NSString stringWithFormat:@"%f, %f", view.annotation.coordinate.latitude, view.annotation.coordinate.longitude];

        if([view.annotation isKindOfClass:[SubstationAnnotationClass class]]){
            [UIView beginAnimations:nil context:NULL];
            view.frame = CGRectOffset(view.frame, 0, -40);
            [UIView commitAnimations];
        }
    }
    
    if(oldState == MKAnnotationViewDragStateDragging){
        
    }
    
    if (newState == MKAnnotationViewDragStateCanceling) {
        locationLabel.text = [NSString stringWithFormat:@"%f, %f", view.annotation.coordinate.latitude, view.annotation.coordinate.longitude];

        if([view.annotation isKindOfClass:[SubstationAnnotationClass class]]){
            [UIView beginAnimations:nil context:NULL];
            view.frame = CGRectOffset(view.frame, 0, 40);
            [UIView commitAnimations];
        }
        [view setDragState:MKAnnotationViewDragStateNone];
    }
    
    if (newState == MKAnnotationViewDragStateEnding) {
        locationLabel.text = [NSString stringWithFormat:@"%f, %f", view.annotation.coordinate.latitude, view.annotation.coordinate.longitude];

        if([view.annotation isKindOfClass:[CurrentLocation class]]){
            CLLocationCoordinate2D cor = (CLLocationCoordinate2D)view.annotation.coordinate;
            mySettings.location = cor;
        } else if([view.annotation isKindOfClass:[SubstationAnnotationClass class]]){
            [UIView beginAnimations:nil context:NULL];
            view.frame = CGRectOffset(view.frame, 0, 40);
            [UIView commitAnimations];
            
            CLLocationCoordinate2D droppedAt = view.annotation.coordinate;
            NSLog(@"dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
            //this is where we will send to GIS or store for sending
            
        }
        
        [view setDragState:MKAnnotationViewDragStateNone];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    locationLabel.text = [NSString stringWithFormat:@"%f, %f", view.annotation.coordinate.latitude, view.annotation.coordinate.longitude];
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view{
    locationLabel.text = nil;
}

-(void)handleLongPressGesture:(UIGestureRecognizer*)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateChanged)
        return;
    
    // Here we get the CGPoint for the touch and convert it to latitude and longitude coordinates to display on the map
    CGPoint point = [sender locationInView:mapView];
    CLLocationCoordinate2D locCoord = [mapView convertPoint:point toCoordinateFromView:mapView];
    // Then all you have to do is create the annotation and add it to the map
    DroppedLocation *dropPin = [[DroppedLocation alloc] init];
    dropPin.coordinate = locCoord;
    dropPin.title = @"New Location";
    [mapView addAnnotation:dropPin];
    
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mapView.delegate = self;
    previousMapType = [[NSString alloc] init];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [mapView addGestureRecognizer:longPressGesture];
    
    isUserWishingToMoveAsset = NO;
}

- (void)clearAnnotationsAndOverlays{
    //remove annotations
    for (id<MKAnnotation> annotation in mapView.annotations) {
        [mapView removeAnnotation:annotation];
    }
    //remove overlays
    for (id<MKOverlay> overlay in mapView.overlays){
        if(![overlay isKindOfClass:[TileOverlay class]]){
            [mapView removeOverlay:overlay];
        }
    }
}

- (void) loadData{
    //load the data if it hasnt already been loaded or if our data has changed
    mySettings = [Settings sharedInstance];
    NSString *response = [mySettings data];
    if(response != nil){
        //only want to do this the once so when there are no entries in the pois array
        //meaning that it hasnt been set up
        //or if we change our url/responseString
        if([[mySettings dirty] isEqualToString:@"New Network"] || [[mySettings dirty] isEqualToString:@"New Network, AR Loaded"]){
            //since it is a new network we should unoverride user location incase it was overriden for the last network
            if([mySettings isOverrideLocationON]){
                [mySettings setOverrideLocationON:FALSE];
                [locationManager startUpdatingLocation];
                for (id<MKAnnotation> annotation in mapView.annotations) {
                    if([annotation isKindOfClass:[CurrentLocation class]]){
                        [mapView removeAnnotation:annotation];
                    }
                }
                [mapView setShowsUserLocation:YES];
            }
            
            //clear the screen if we have already loaded another file
            [self clearAnnotationsAndOverlays];
            //plot the data
            [self plotSubstationLocations];
            //zoom in on our network
            if(!loadedFromPOI)
                [self centreOnNetwork:nil];
        }
        
    }else{
        //if we are showing no network
        [self clearAnnotationsAndOverlays];
    }
    
    //if we reached here from a POI then we should zoom in further to that location
    if(loadedFromPOI){
        MKCoordinateSpan span;
        span.latitudeDelta = .0001;
        span.longitudeDelta = .0001;
        
        MKCoordinateRegion region;
        region.span = span;
        
        region.center =  poisLocation;
        if (region.center.latitude > 90 || region.center.latitude < -90)
            region.center.latitude = 0;
        if (region.center.longitude > 180|| region.center.longitude < -180)
            region.center.longitude = 0;
        
        [mapView setRegion:region animated:YES];
        [mapView regionThatFits:region];
        
        firstTime = NO;
        
        for (id<MKAnnotation> annotation in mapView.annotations) {
            if([annotation isKindOfClass:[SubstationAnnotationClass class]]){
                if((((SubstationAnnotationClass *)annotation).coordinate.latitude ==  poisLocation.latitude) && (((SubstationAnnotationClass *)annotation).coordinate.longitude ==  poisLocation.longitude)){
                    [mapView selectAnnotation:annotation animated:YES];
                }
            }
        }
        
    }
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
}

- (void) viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:YES];

    //set up the location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    
    [self loadData];
    
    if(![mySettings isOverrideLocationON]){
        [locationManager startUpdatingLocation];
        [mapView setShowsUserLocation:NO];
        [mapView setShowsUserLocation:YES];
    }
}


- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
}

//stop the location devices when the view dissapears to save battery
- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    //perhaps want to stop the location and motion updating
    if(![mySettings isOverrideLocationON]){
        [locationManager stopUpdatingLocation];
    }
    
    loadedFromPOI = NO;
    
}

- (void)plotSubstationLocations{
    
    double maxLat = 0;
    double minLat = 0;
    double maxLong = 0;
    double minLong = 0;
    BOOL first = true;
    
    NSMutableArray *overlays = [[NSMutableArray alloc] init];
    
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
                //for some reason if we use the initWithUUID it then crashes upon reaccess later....
                SubstationAnnotationClass *annotation = [[SubstationAnnotationClass alloc] initWithCoordinate:coordinate];
                annotation.originalCoordinate = coordinate;
                annotation.uuid = uuid;
                annotation.voltages = [voltages allObjects];
                annotation.title = name;
                annotation.name = name;
                annotation.subtitle = type;
                annotation.altitude = altitude.doubleValue;
                [mapView addAnnotation:annotation];
                
                if(first){
                    maxLat = coordinate.latitude;
                    minLat = coordinate.latitude;
                    maxLong = coordinate.longitude;
                    minLong = coordinate.longitude;
                    first = false;
                }else{
                    if(coordinate.latitude < minLat){
                        minLat = coordinate.latitude;
                    }
                    if(coordinate.latitude > maxLat){
                        maxLat = coordinate.latitude;
                    }
                    if(coordinate.longitude < minLong){
                        minLong = coordinate.longitude;
                    }
                    if(coordinate.longitude > maxLong){
                        maxLong = coordinate.longitude;
                    }
                }
                
            }else if(([type isEqualToString:@"ACLineSegment"] || [type isEqualToString:@"Line"]) && [points count]>1){
                
                
                NSNumber *voltage = [NSNumber numberWithDouble:[[asset voltageLevels] doubleValue]];
                
                NSSortDescriptor *sortDescriptor;
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"seqNo"
                                                             ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                NSArray *sortedArray;
                sortedArray = [points sortedArrayUsingDescriptors:sortDescriptors];
                
                int counter = 0;
                NSInteger count = [sortedArray count];
                CLLocationCoordinate2D coordinates[count];
                for (PositionPoint *point in sortedArray){
                    NSNumber * latitude = [point latitude];
                    NSNumber * longitude = [point longitude];
                    coordinates[counter] = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
                    counter++;
                }
                MKPolyline * line = [MKPolyline polylineWithCoordinates:coordinates count:count];
                objc_setAssociatedObject(line, &LINE_VOLTAGE, voltage, OBJC_ASSOCIATION_RETAIN);
                [overlays addObject:line];
            }
            
            
        }
    }
    
    
    for (MKPolyline * overlay in overlays){
        [mapView addOverlay:overlay];
        
    }
    
    double centreLat = (maxLat + minLat) / 2;
    double centreLong = (maxLong + minLong) /2;
    
    centreNetwork = CLLocationCoordinate2DMake(centreLat, centreLong);
    if(maxLat !=0 && maxLong != 0 && minLat !=0 && minLong != 0){
        diffLat = maxLat - minLat;
        diffLong = maxLong - minLong;
    }else{
        diffLat = 180.0f;
        diffLong = 360.0f;
    }
    
    if([[mySettings dirty] isEqualToString:@"New Network, AR Loaded"]){
        [mySettings setDirty:@"Clean"];
    }else if([[mySettings dirty] isEqualToString:@"New Network"]){
        [mySettings setDirty:@"New Network, Map Loaded"];
    }
    
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

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end
