//
//  MapSettingsViewController.h
//  MIDAS
//
//  Created by Susan Rudd on 12/04/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MapSettingsDelegate;

@interface MapSettingsViewController : UIViewController{
    id<MapSettingsDelegate> __weak delegate;
}

- (IBAction)dismissView:(id)sender;
- (IBAction)dropLocationPin:(id)sender;
- (IBAction)dropAssetPin:(id)sender;
- (IBAction)showAllAssetNames:(id)sender;
- (IBAction)removeAllAssetNames:(id)sender;
- (IBAction)setMapTypeApple:(id)sender;
- (IBAction)setMapTypeOSM:(id)sender;

@property (nonatomic, weak) id<MapSettingsDelegate> delegate;


@end
