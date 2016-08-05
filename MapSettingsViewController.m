//
//  MapSettingsViewController.m
//  MIDAS
//
//  Created by Susan Rudd on 12/04/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "MapSettingsViewController.h"
#import "MapViewerViewController.h"

@implementation MapSettingsViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (IBAction)setMapTypeApple:(id)sender{
    [delegate changeTiles:@"Apple"];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)setMapTypeOSM:(id)sender{
    [delegate changeTiles:@"OpenStreetMap"];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)dismissView:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)dropLocationPin:(id)sender{
    [delegate userWishesToDropPinForLocation];
    [self dismissModalViewControllerAnimated:YES];
}
- (IBAction)dropAssetPin:(id)sender{
    [delegate userWishesToAddNewAssetLocation];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)showAllAssetNames:(id)sender{
    [delegate userWishesToShowAllAssetNames];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)removeAllAssetNames:(id)sender{
    [delegate userWishesToRemoveAllAssetNames];
    [self dismissModalViewControllerAnimated:YES];
}




@end
