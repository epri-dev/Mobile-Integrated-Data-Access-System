//
//  SettingsViewController.h
//  MIDAS
//
//  Created by Susan Rudd on 19/09/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"


@interface SettingsViewController : UIViewController <UITextFieldDelegate>{
    
    IBOutlet UISwitch *lowVotlageSwitch;
    IBOutlet UISwitch *mediumVoltageSwitch;
    IBOutlet UISwitch *highVoltageSwitch;
    IBOutlet UISlider *distanceSlider;
    IBOutlet UISwitch *overrideAltitudeSwitch;
    IBOutlet UITextField *heightOffGroundInput;
    IBOutlet UILabel *distance;
    IBOutlet UISwitch *debugSwitch;
    
    Settings *mySettings;
}

- (IBAction)lowVoltageLines:(id)sender;
- (IBAction)mediumVoltageLines:(id)sender;
- (IBAction)highVoltageLines:(id)sender;
- (IBAction)changeDistance:(id)sender;
- (IBAction)overrideAltitude:(id)sender;
- (IBAction)heightOffGround:(id)sender;
- (IBAction)debug:(id)sender;

@property (nonatomic) IBOutlet UISwitch *lowVotlageSwitch;
@property (nonatomic) IBOutlet UISwitch *mediumVoltageSwitch;
@property (nonatomic) IBOutlet UISwitch *highVoltageSwitch;
@property (nonatomic) IBOutlet UISlider *distanceSlider;
@property (nonatomic) IBOutlet UISwitch *overrideAltitudeSwitch;
@property (nonatomic) IBOutlet UISwitch *debugSwitch;

@property (nonatomic) IBOutlet UITextField *heightOffGroundInput;




@end
