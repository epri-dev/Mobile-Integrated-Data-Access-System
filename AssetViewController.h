//
//  AssetViewController.h
//  MIDAS
//
//  Created by Susan Rudd on 13/04/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DroppedLocation.h"

@protocol AddAssetInfoDelegate;

@interface AssetViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>{
    id<AddAssetInfoDelegate> __weak delegate;
    NSString *__weak passedTitle;
    NSString *__weak passedSubTitle;
    NSString *__weak passedAltitude;
    IBOutlet UITextField *assetTitle;
    IBOutlet UITextField *altitude;

    NSString *assetType;
    IBOutlet UIPickerView *assetTypePicker;
    NSMutableArray *arrayAssetTypes;
    DroppedLocation *selectedAnnotation;
}

- (IBAction)saveAsset:(id)sender;

@property (nonatomic, weak) id<AddAssetInfoDelegate> delegate;
@property (nonatomic) IBOutlet UITextField *assetTitle;
@property (nonatomic) IBOutlet UITextField *altitude;
@property (nonatomic) NSString *assetType;
@property (nonatomic) IBOutlet UIPickerView *assetTypePicker;
@property (nonatomic, weak) NSString *passedTitle;
@property (nonatomic, weak) NSString *passedSubTitle;
@property (nonatomic, weak) NSString *passedAltitude;
@property (nonatomic) DroppedLocation *selectedAnnotation;

- (id)initWithNibName:(NSString *)nibNameOrNil andAnnotation:(DroppedLocation *)annotation bundle:(NSBundle *)nibBundleOrNil;

@end
