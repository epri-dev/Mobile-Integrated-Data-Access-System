//
//  HomeViewController.h
//  MIDAS
//
//  Created by Susan Rudd on 20/09/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkTableView.h"
#import "CoreDataInfoViewController.h"
#import "CustomButton.h"

@class CustomButton;

@interface HomeViewController : UIViewController <VCDelegate, UITextFieldDelegate, CoreDataDelegate>{
    
    NSString* url;
    NSString *json;

    IBOutlet UIButton *applyServer;
    IBOutlet UIButton *applyServerLand;
    
    IBOutlet CustomButton *selectNetwork;
    
    NetworkTableView *nextView;
    CoreDataInfoViewController *coreDataView;
    
    NSManagedObjectContext *managedObjectContext;
    IBOutlet CustomButton *selectStoredNetwork;
    
    IBOutlet UIView *portraitView;
    IBOutlet UIView *landscapeView;
        
    IBOutlet UIActivityIndicatorView *loadingNetworks;
    IBOutlet UIActivityIndicatorView *loadingNetworksLandscape;
    
    Settings *mySettings;
    
}

@property (nonatomic, strong) NSString* url;
@property (nonatomic) NSString* json;

@property (nonatomic) IBOutlet UILabel *networkTitle;
@property (nonatomic) IBOutlet UILabel *networkDescription;
@property (nonatomic) IBOutlet UIImageView *networkImage;
@property (nonatomic) IBOutlet CustomButton *selectNetwork;

@property (nonatomic, weak) IBOutlet UITextField *serverURL;

@property (nonatomic, strong) IBOutlet UIView *portraitView;
@property (nonatomic, strong) IBOutlet UIView *landscapeView;

@property (nonatomic, weak) IBOutlet UIImageView *networkImageLand;
@property (nonatomic, weak) IBOutlet UITextField *serverURLLand;
@property (nonatomic, weak) IBOutlet UILabel *networkTitleLand;
@property (nonatomic, weak) IBOutlet UILabel *networkDescriptionLand;

@property (nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)setServer:(id)sender;
- (IBAction)selectNetwork:(id)sender;
- (IBAction)selectStoredNetwork:(id)sender;

- (void)displayNetwork:(NSArray *)chosenNetwork;
- (void)setJSON:(NSString *)jsonString;
- (void)displayNetworkInfo:(NetworkDataInfo *)chosenNetwork;

@end
