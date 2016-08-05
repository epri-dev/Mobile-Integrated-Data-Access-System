//
//  PopOverViewController.m
//  MIDAS
//
//  Created by Susan Rudd on 17/04/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "PopOverViewController.h"
#import "PointOfInterest.h"
#import "MapViewerViewController.h"
#import "ManualTableViewController.h"

@interface PopOverViewController ()

@end

@implementation PopOverViewController
@synthesize image;
@synthesize chosenSub;
@synthesize scheduleMaintenance;
@synthesize delegate;
@synthesize viewManual;
@synthesize moveAsset;
@synthesize selectedView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil andAnnotation:(SubstationAnnotationClass *)substation bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        chosenSub = substation;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        self.navigationController.navigationBarHidden = NO;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil andAnnotation:(SubstationAnnotationClass *)substation andAnnotationView:(MKAnnotationView *)view bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        chosenSub = substation;
        selectedView = view;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [self setContentSizeForViewInPopover:CGSizeMake(320, 400)];
}

- (PointOfInterest *)setUpPOI{
    //need to set up a POI TODO:add altitude variable to SubstationAnnotation
    PointOfInterest *p = [[PointOfInterest alloc] initWithLocation:chosenSub.coordinate title:chosenSub.title altitude:chosenSub.altitude voltages:chosenSub.voltages];
    p.name = chosenSub.title;
    p.uuid = chosenSub.uuid;
    
    return p;
    
}

- (IBAction)scheduleMaintenance:(id)sender{
    [delegate scheduleMaintenance:[self setUpPOI]];
}

- (IBAction)viewManual:(id)sender{        
    [delegate viewManual:[self setUpPOI] withView:selectedView];
}

- (IBAction)moveAsset:(id)sender{
    [delegate moveAsset:[self setUpPOI] withView:selectedView];
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
            [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (IBAction)viewLocationDetails:(id)sender{
    [delegate viewLocationDetails:[self setUpPOI] withView:selectedView];
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


@end
