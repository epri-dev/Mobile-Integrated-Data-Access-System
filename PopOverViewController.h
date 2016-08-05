//
//  PopOverViewController.h
//  MIDAS
//
//  Created by Susan Rudd on 17/04/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubstationAnnotationClass.h"
#import <QuartzCore/QuartzCore.h>

@protocol AssetInformationDelegate;

@interface PopOverViewController : UIViewController{
    id<AssetInformationDelegate> __weak delegate;
    SubstationAnnotationClass *chosenSub;
    MKAnnotationView *selectedView;
}

@property (nonatomic) IBOutlet UIImageView *image;

@property (nonatomic) IBOutlet UIButton *scheduleMaintenance;
@property (nonatomic) IBOutlet UIButton *viewManual;
@property (nonatomic) IBOutlet UIButton *moveAsset;

@property (nonatomic) SubstationAnnotationClass *chosenSub;
@property (nonatomic) MKAnnotationView *selectedView;

@property (nonatomic, weak) id<AssetInformationDelegate> delegate;

- (IBAction)scheduleMaintenance:(id)sender;
- (IBAction)viewManual:(id)sender;
- (IBAction)moveAsset:(id)sender;
- (IBAction)viewLocationDetails:(id)sender;


- (id)initWithNibName:(NSString *)nibNameOrNil andAnnotation:(SubstationAnnotationClass *)substation bundle:(NSBundle *)nibBundleOrNil;
- (id)initWithNibName:(NSString *)nibNameOrNil andAnnotation:(SubstationAnnotationClass *)substation andAnnotationView:(MKAnnotationView *)view bundle:(NSBundle *)nibBundleOrNil;

@end
