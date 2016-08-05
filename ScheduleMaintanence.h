//
//  ScheduleMaintanence.h
//  MIDAS
//
//  Created by Susan Rudd on 22/10/2011.
//  Copyright (c) 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointOfInterest.h"
#import "Settings.h"
#import "Maintenance.h"

@interface ScheduleMaintanence : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate>{
    PointOfInterest *poi;
    Settings *mySettings;
    UINavigationController *navController;

    UITableView *selectOption;

    NSDate *now;
    NSMutableData *receivedData;
    
    NSString *organisation;
    NSString *startString;
    NSString *endString;
    NSString *subjectString;
    NSString *descriptionString;
    NSString *priority;
    NSString *kind;
    
    UITableView *selectOrganisation;
    UITableView *selectKind;
    UILabel *orgURL;

    
    NSArray *optionList;
    NSArray *organisationList;
    NSArray *kindList;
    NSArray *urls;
    NSString *location;
    
    NSArray *datesList;
    UITableView *datePickers;
    
    NSInteger orgIndex;
    NSInteger kindIndex;
    
    UIAlertView *alert;
    BOOL fromMapView;
    NSString *jsonString;
    
    NSManagedObjectContext *managedObjectContext;
    BOOL isEdit;
    NSString *workOrdersMRID;
    Maintenance *storedMan;
}

@property (nonatomic) UIViewController* viewController;
@property (nonatomic) UINavigationController *navController;

@property (nonatomic, strong) NSArray *organisationList;
@property (nonatomic, strong) NSArray *kindList;
@property (nonatomic, strong) NSArray *urls;
@property (nonatomic, strong) NSArray *optionList;
@property (nonatomic, strong) NSArray *datesList;

@property (nonatomic, copy) NSString *organisation;
@property (nonatomic, copy) NSString *startString;
@property (nonatomic, copy) NSString *endString;
@property (nonatomic, copy) NSString *descriptionString;
@property (nonatomic, copy) NSString *subjectString;
@property (nonatomic, copy) NSString *priority;
@property (nonatomic, copy) NSString *kind;
@property (nonatomic, copy) NSString *workOrdersMRID;
@property (nonatomic, copy) NSString *location;


@property (nonatomic, copy) NSDate *now;
@property (nonatomic)  NSMutableData *receivedData;

@property (nonatomic) IBOutlet UITableView *selectOption;
@property (nonatomic) IBOutlet UITableView *selectOrganisation;
@property (nonatomic) IBOutlet UITableView *selectKind;
@property (nonatomic) IBOutlet UITableView *datePickers;
@property (nonatomic) UILabel *orgURL;

@property (nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic) Maintenance *storedMan;

- (NSString*) uuid;

- (IBAction)startDate:(id)sender;
- (IBAction)endDate:(id)sender;
- (IBAction)chosePriority:(id)sender;

- (id)initWithNibName:(NSString *)nibNameOrNil andPoi:(PointOfInterest *)newpoi;
- (id)initWithNibName:(NSString *)nibNameOrNil withStoredMainenance:(Maintenance *)man;
- (id)initWithNibName:(NSString *)nibNameOrNil andLocation:(NSString *)street;

@end
