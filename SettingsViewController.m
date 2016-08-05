//
//  SettingsViewController.m
//  MIDAS
//
//  Created by Susan Rudd on 19/09/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "SettingsViewController.h"


@implementation SettingsViewController

@synthesize distanceSlider;
@synthesize heightOffGroundInput;
@synthesize highVoltageSwitch;
@synthesize mediumVoltageSwitch;
@synthesize overrideAltitudeSwitch;
@synthesize lowVotlageSwitch;
@synthesize debugSwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == heightOffGroundInput) {
        [textField resignFirstResponder];
    }
    return NO;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated{
    mySettings =  [Settings sharedInstance];
    distanceSlider.minimumValue = 0.5; //cant divide by 0 later
    distanceSlider.maximumValue = 10000.0; //1500000.0; //10km (100km is a bit much!)
    distanceSlider.minimumValueImage = [UIImage imageNamed:@"littlem.png"];
    distanceSlider.maximumValueImage = [UIImage imageNamed:@"bigm.png"];
    distanceSlider.continuous = YES;
    distanceSlider.value = [mySettings maxDistance];
    distance.text = [NSString stringWithFormat:@"%g", distanceSlider.value];
    
    heightOffGroundInput.delegate = self;

}

- (void)viewDidUnload
{
    mediumVoltageSwitch = nil;
    highVoltageSwitch = nil;
    distanceSlider = nil;
    overrideAltitudeSwitch = nil;
    heightOffGroundInput = nil;
    lowVotlageSwitch = nil;
    distance = nil;
    debugSwitch = nil;

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (IBAction)lowVoltageLines:(id)sender {
    [mySettings setLowLinesON:lowVotlageSwitch.on];
}

- (IBAction)mediumVoltageLines:(id)sender {
    [mySettings setMediumLinesON:mediumVoltageSwitch.on];
}

- (IBAction)highVoltageLines:(id)sender {
    [mySettings setHighLinesON:highVoltageSwitch.on];
}

- (IBAction)changeDistance:(id)sender {
    mySettings.maxDistance = distanceSlider.value;
    distance.text = [NSString stringWithFormat:@"%g", distanceSlider.value];
}

- (IBAction)overrideAltitude:(id)sender {
    [mySettings setOverrideAltON:overrideAltitudeSwitch.on];
}

- (IBAction)heightOffGround:(id)sender {
    mySettings.altitude =  heightOffGroundInput.text.doubleValue;
}
- (IBAction)debug:(id)sender {
    [mySettings setDebugON:debugSwitch.on];
}
@end
