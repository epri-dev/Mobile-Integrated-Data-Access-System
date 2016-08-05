//
//  PinOptionsViewController.h
//  MIDAS
//
//  Created by Susan Rudd on 08/06/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewerViewController.h"

@interface PinOptionsViewController : UIViewController{
    id<OptionsForPinDelegate> __weak delegate;
}

@property (nonatomic) MKAnnotationView *selectedAnnotationView;
@property (nonatomic, weak) id<OptionsForPinDelegate> delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andAnnotationView:(MKAnnotationView *)annotationView;

- (IBAction)addAsset:(id)sender;
- (IBAction)createWorkOrder:(id)sender;
- (IBAction)removePin:(id)sender;

@end
