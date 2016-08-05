//
//  PinOptionsViewController.m
//  MIDAS
//
//  Created by Susan Rudd on 08/06/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "PinOptionsViewController.h"

@interface PinOptionsViewController ()

@end

@implementation PinOptionsViewController
@synthesize selectedAnnotationView;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andAnnotationView:(MKAnnotationView *)annotationView
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        selectedAnnotationView = annotationView;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [self setContentSizeForViewInPopover:CGSizeMake(320, 400)];
}

- (void)viewWillAppear:(BOOL)animated{
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        self.navigationController.navigationBarHidden = NO;
    }
}

- (void)cancelButtonPressed {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (IBAction)addAsset:(id)sender{
    [delegate addAsset:selectedAnnotationView];
}

- (IBAction)createWorkOrder:(id)sender{
    [delegate createWorkOrder:selectedAnnotationView];
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        [self dismissModalViewControllerAnimated:YES];    
    }
}

- (IBAction)removePin:(id)sender{
    [delegate removePinFromMap:selectedAnnotationView.annotation];
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        [self.navigationController.view removeFromSuperview];
    }
}

- (PointOfInterest *)setUpPOI{
    //need to set up a POI TODO:add altitude variable to SubstationAnnotation
    DroppedLocation *newAssetLocation = (DroppedLocation *)selectedAnnotationView.annotation;
    PointOfInterest *p = [[PointOfInterest alloc] initWithLocation:newAssetLocation.coordinate title:newAssetLocation.title altitude:newAssetLocation.altitude];
    p.name = newAssetLocation.title;
    //p.mrID = newAssetLocation.uuid;

    return p;
}

@end
