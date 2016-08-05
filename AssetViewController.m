//
//  AssetViewController.m
//  MIDAS
//
//  Created by Susan Rudd on 13/04/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "AssetViewController.h"
#import "MapViewerViewController.h"

@interface AssetViewController ()

@end

@implementation AssetViewController
@synthesize delegate;
@synthesize assetTitle;
@synthesize passedTitle;
@synthesize assetType;
@synthesize passedSubTitle;
@synthesize assetTypePicker;
@synthesize selectedAnnotation;
@synthesize altitude;
@synthesize passedAltitude;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
   
    return self;

}

- (id)initWithNibName:(NSString *)nibNameOrNil andAnnotation:(DroppedLocation *)annotation bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        selectedAnnotation = annotation;
        self.navigationController.navigationBarHidden = YES;
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}


- (void)viewDidAppear:(BOOL)animated{
    [self setContentSizeForViewInPopover:CGSizeMake(320, 400)];
}

- (void)viewDidLoad
{
    //this should be auto populated
    arrayAssetTypes = [[NSMutableArray alloc] init];
    [arrayAssetTypes addObject:@"HV Substation"];
    [arrayAssetTypes addObject:@"MV Substation"];
    [arrayAssetTypes addObject:@"LV Substation"];
    [arrayAssetTypes addObject:@"Transformer"];
    [arrayAssetTypes addObject:@"Switch"];
        
    assetTitle.returnKeyType = UIReturnKeyDone;
    assetTitle.delegate = self;
    
    [super viewDidLoad];
        
    if(![passedTitle isEqualToString:@"New Location"]){
        assetTitle.text = passedTitle;
    }
    if(passedSubTitle != nil){
        [assetTypePicker selectRow:[arrayAssetTypes indexOfObject:passedSubTitle] inComponent:0 animated:YES];
        assetType = [arrayAssetTypes objectAtIndex:[arrayAssetTypes indexOfObject:passedSubTitle]];
    }else{
        assetType = [arrayAssetTypes objectAtIndex:0]; 
    }
    
    if(passedAltitude != nil){
        altitude.text = passedAltitude;
    }
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont boldSystemFontOfSize:11.0];
        // Optional - label.text = @"NavLabel";
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        [label setText:[NSString stringWithFormat:@"Add Asset Info"]];
        [label sizeToFit];
        self.navigationItem.titleView = label;
    }
    
}

- (void) setPassedTitle:(NSString *)pTitle{
    passedTitle = pTitle;    
}

- (void) setPassedSubTitle:(NSString *)pTitle{
    passedSubTitle = pTitle;    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    return [arrayAssetTypes count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [arrayAssetTypes objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {    
   assetType = [arrayAssetTypes objectAtIndex:row];
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

- (void)cancelButtonPressed {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        self.navigationController.navigationBarHidden = NO;
        UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
        [self.navigationItem setRightBarButtonItem:cancel];
                UIBarButtonItem* send = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];
        [self.navigationItem setLeftBarButtonItem:send];
    }
}

- (void)saveButtonPressed{
    [self saveAsset:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}



- (IBAction)saveAsset:(id)sender{
    if([[assetTitle text] isEqualToString:@""]){
        [delegate newAssetTitle:@"New Location" andNewAssetSubTitle:assetType andAltitude:[altitude text] forAnnotation:selectedAnnotation];
    }else{
        [delegate newAssetTitle:[assetTitle text] andNewAssetSubTitle:assetType andAltitude:[altitude text] forAnnotation:selectedAnnotation];
    }    
}



@end
