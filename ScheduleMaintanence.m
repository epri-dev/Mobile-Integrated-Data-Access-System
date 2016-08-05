//
//  ScheduleMaintanence.m
//  MIDAS
//
//  Created by Susan Rudd on 22/10/2011.
//  Copyright (c) 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "ScheduleMaintanence.h"
#import "POIInformationView.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJson.h"
#import <QuartzCore/QuartzCore.h>
#import "MIDASAppDelegate.h"
#import "MessagesViewController.h"
#import "GlobalFunctions.h"

@implementation ScheduleMaintanence
@synthesize viewController;
@synthesize navController;

@synthesize organisation;
@synthesize startString;
@synthesize endString;
@synthesize descriptionString;
@synthesize subjectString;
@synthesize priority;
@synthesize kind;
@synthesize workOrdersMRID;

@synthesize location;

@synthesize now;
@synthesize receivedData;

@synthesize selectOrganisation;
@synthesize orgURL;
@synthesize selectKind;

@synthesize optionList;
@synthesize selectOption;
@synthesize organisationList;
@synthesize kindList;
@synthesize urls;

@synthesize datesList;
@synthesize datePickers;

@synthesize managedObjectContext;
@synthesize storedMan;

- (void)initStrings{
    endString = [[NSString alloc] init];
    startString = [[NSString alloc] init];
    descriptionString = [[NSString alloc] init];
    subjectString = [[NSString alloc] init];
    priority = [[NSString alloc] init];
    kind = [[NSString alloc] init];
    organisation = [[NSString alloc] init];
    
    self.now = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSString* str = [formatter stringFromDate:self.now];
    
    //need to do this to get now into the same time format as end/start date for validity check
    self.now = [formatter dateFromString:str];
    
    //just in case they dont touch the rollers
    self.startString = str;
    self.endString = str;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        fromMapView = YES;
        isEdit = NO;
        orgIndex = -1;
        kindIndex = -1;
        [self initStrings];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil andLocation:(NSString *)street
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        // Custom initialization
        fromMapView = YES;
        isEdit = NO;
        orgIndex = -1;
        kindIndex = -1;
        location = street;
        [self initStrings];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil andPoi:(PointOfInterest *)newpoi
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        poi = newpoi;
        fromMapView = YES;
        //set these to -1 so that the tick doesnt appear when first loaded
        orgIndex = -1;
        kindIndex = -1;
        isEdit = NO;
        [self initStrings];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil withStoredMainenance:(Maintenance *)man
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        isEdit = YES;
        organisation = man.organisation;
        endString = man.endDate;
        startString = man.startDate;
        descriptionString = man.descriptionString;
        subjectString = man.subject;
        priority = man.priority;
        kind = man.kind;
        workOrdersMRID = man.workOrderMRID;
        storedMan = man;
        fromMapView = YES;
    }
    
    return self;
}

- (void)exitView {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)displayAlertWithMessage:(NSString *)message andChooseCorrectRowInOptionTableAtIndex:(NSUInteger)row{
    UIAlertView *alertMissing = [[UIAlertView alloc]
                                 initWithTitle:@"Missing Information"
                                 message:message
                                 delegate:self
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
    [alertMissing show];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection: 0];
    [selectOption selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [selectOption.delegate tableView:selectOption didSelectRowAtIndexPath:indexPath];
}

- (NSString *)urlEncodeValue:(NSString *)str
{
    NSString *result = (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
    return result;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    
    // release the connection, and the data object
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    // receivedData is declared as a method instance elsewhere
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (NSString*) uuid{
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (__bridge_transfer NSString *)CFStringCreateCopy( NULL, uuidString);
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

- (void)removeAlert{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

- (BOOL)validation{
    //do validity checks
    
    BOOL valid = YES;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *startingDate= [dateFormat dateFromString:startString]; 
    NSDate *endingDate= [dateFormat dateFromString:endString];
    
    if([self.organisation length] == 0){
        [self displayAlertWithMessage:@"You have not entered an ORGANISATION for this work request, please do so now." andChooseCorrectRowInOptionTableAtIndex:0];
        valid = NO;
    }else if([startingDate compare:endingDate] == NSOrderedDescending){
        [self displayAlertWithMessage:@"The END date you entered is before the START date, please choose a new date." andChooseCorrectRowInOptionTableAtIndex:1];
        valid = NO;
    }else if([self.now compare:startingDate] == NSOrderedDescending){
        [self displayAlertWithMessage:@"The START date you entered is before the present date, please choose a new start date." andChooseCorrectRowInOptionTableAtIndex:1];
        valid = NO;
    }else if([self.now compare:endingDate] == NSOrderedDescending){
        [self displayAlertWithMessage:@"The END date you entered is before the present date, please choose a new end date." andChooseCorrectRowInOptionTableAtIndex:1];
        valid = NO;
    }else if([self.subjectString length] == 0){
        [self displayAlertWithMessage:@"You have not entered a SUBJECT for this work request, please do so now." andChooseCorrectRowInOptionTableAtIndex:2];
        valid = NO;
    }else if([self.descriptionString length] == 0){
        [self displayAlertWithMessage:@"You have not entered a DESCRIPTION for this work request, please do so now." andChooseCorrectRowInOptionTableAtIndex:2];
        valid = NO;
    }else if([self.priority length] == 0){
        [self displayAlertWithMessage:@"You have not entered a PRIORITY for this work request, please do so now." andChooseCorrectRowInOptionTableAtIndex:3];
        valid = NO;
    }else if([self.kind length] == 0){
        [self displayAlertWithMessage:@"You have not entered the KIND of work for this work request, please do so now." andChooseCorrectRowInOptionTableAtIndex:4];
        valid = NO;
    }
    
    return valid;
}

- (void)makeJSON{
    NSDateFormatter *requestDateFormat = [[NSDateFormatter alloc] init];
    [requestDateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSString *requestString = [requestDateFormat stringFromDate:[NSDate date]];
    
    if(isEdit){
        workOrdersMRID = storedMan.workOrderMRID;
    }else{
        workOrdersMRID = [self uuid];
    }
    
    jsonString =[NSString stringWithFormat: @"{\"Organisation\":{\"mRID\":\"%@\",\"py/object\":\"Organisation\"},\"Device\":{\"token\":\"%@\",\"py/object\":\"Device\"},\"Work\":[{\"TimeSchedules\":[{\"py/object\":\"TimeSchedule\",\"scheduleInterval\":{\"end\":\"%@\",\"py/object\":\"DateTimeInterval\",\"start\":\"%@\"}}],\"WorkTasks\":[{\"Names\":{\"NameType\":{\"name\":\"description\",\"py/object\":\"NameType\"},\"name\":\"%@\",\"py/object\":\"Name\"},\"priority\":\"%@\",\"py/object\":\"WorkTask\",\"subject\":\"%@\",\"type\":\"%@\"}],\"kind\":\"%@\",\"lastModifiedDateTime\":\"2011-03-28T12:00:00.000+0100\",\"mRID\":\"%@\",\"priority\":\"%@\",\"py/object\":\"Work\",\"requestDateTime\":\"%@\",\"type\":\"%@\"}],\"py/object\":\"WorkRequest\"}", organisation, mySettings.deviceToken, endString, startString, descriptionString, priority, subjectString, kind, kind, workOrdersMRID, priority, requestString, kind];
    
    // NSLog(@"{\"Organisation\":{\"mRID\":\"%@\",\"py/object\":\"Organisation\"},\"Device\":{\"token\":\"%@\",\"py/object\":\"Device\"},\"Work\":[{\"TimeSchedules\":[{\"py/object\":\"TimeSchedule\",\"scheduleInterval\":{\"end\":\"%@\",\"py/object\":\"DateTimeInterval\",\"start\":\"%@\"}}],\"WorkTasks\":[{\"Names\":{\"NameType\":{\"name\":\"description\",\"py/object\":\"NameType\"},\"name\":\"%@\",\"py/object\":\"Name\"},\"priority\":\"%@\",\"py/object\":\"WorkTask\",\"subject\":\"%@\",\"type\":\"%@\"}],\"kind\":\"%@\",\"lastModifiedDateTime\":\"2011-03-28T12:00:00.000+0100\",\"mRID\":\"%@\",\"priority\":\"%@\",\"py/object\":\"Work\",\"requestDateTime\":\"%@\",\"type\":\"%@\"}],\"py/object\":\"WorkRequest\"}", organisation, deviceToken, endString, startString, descriptionString, priority, subjectString, kind, kind, workOrdersMRID, priority, requestString, kind);
}
- (void)storeCoreData{
    if(isEdit){
        [self updateCoreData:storedMan andSent:NO];
    }else{
        // Create and configure a new instance of the Event entity.
        Maintenance *man = (Maintenance *)[NSEntityDescription insertNewObjectForEntityForName:@"Maintenance" inManagedObjectContext:managedObjectContext];
        [man setCreationDate:[NSDate date]];
        [man setOrganisation:organisation];
        [man setDeviceToken:mySettings.deviceToken];
        [man setEndDate:endString];
        [man setStartDate:startString];
        [man setDescriptionString:descriptionString];
        [man setSubject:subjectString];
        [man setKind:kind];
        [man setWorkOrderMRID:workOrdersMRID];
        [man setPriority:priority];
        if(poi.name != nil){
            [man setPoiName:poi.name];
        }else {
            [man setPoiName:[NSString stringWithFormat:@"From Location: %@", location]];
        }
        [man setStatus:[UIImage imageNamed:@"pending.png"]];
        [man setJson:jsonString];
        
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"%@", error);
        }
    }
    
    countPendingMaintenanceRequests(managedObjectContext);
    
}

- (void)saveButtonPressed{
    
    BOOL valid = [self validation];
    
    if(valid){
        [self makeJSON];
        [self storeCoreData];
        [self exitView];
    }
    
}

- (void)sendButtonPressed {
    //this is where we will post to JSON
    //and then return to options
    
    BOOL valid = [self validation];
    
    if(valid){
        
        [self makeJSON];
        
        NSString * url = mySettings.server;
        NSURL *urlForData = [NSURL URLWithString:url];
        
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:urlForData];
        [request addPostValue:jsonString forKey:@"json"];
        
        [request startAsynchronous];
        NSError *error = [request error];
        
        
        MIDASAppDelegate *appDel = (MIDASAppDelegate *)[[UIApplication sharedApplication] delegate];
        if(appDel.netStatus == NotReachable){
            alert = [[UIAlertView alloc]
                     initWithTitle:[NSString stringWithFormat:@"Connection Error"]
                     message:@"You are not connected to the internet, your request will be saved in Maintenance tab for manual sending."
                     delegate:self
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
            [alert show];
            
            [self storeCoreData];
            
        }else if (!error) {
            //NSString *response = [request responseString];
            if(isEdit){
                [self updateCoreData:storedMan andSent:YES];
            }
            
            alert = [[UIAlertView alloc]
                     initWithTitle:[NSString stringWithFormat:@"\n\nYour Request Is Being Processed."]
                     message:nil
                     delegate:self
                     cancelButtonTitle:nil
                     otherButtonTitles:nil];
            [alert show];
            
            [self storeCoreData];
            [self performSelector:@selector(removeAlert) withObject:nil afterDelay:3];
        }else if(error){
            alert = [[UIAlertView alloc]
                     initWithTitle:[NSString stringWithFormat:@"Error"]
                     message:@"There was an error in performing the send, your request will be saved in the Maintenance tab for manual sending."
                     delegate:self
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
            [alert show];
            
            [self storeCoreData];
        }
        
        [self exitView];
    }
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = NO;

    UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(exitView)];
    UIBarButtonItem* send = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sendButtonPressed)];
    UIBarButtonItem* save = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed)];    
    [self.navigationItem setRightBarButtonItem:cancel];
    [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:save, send, nil ]];
    
    NSString *poiName;
    
    if(poi.name != NULL){
        poiName = poi.name;
    }else if(storedMan != NULL){
        poiName = storedMan.poiName;
    }
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        CGRect frame = CGRectMake(0, 0, 120, 25);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.font = [UIFont boldSystemFontOfSize:11.0];
        // Optional - label.text = @"NavLabel";
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        
        if(poiName != NULL){
            [label setText:[NSString stringWithFormat:@"%@" , poiName]];
        }else{
            [label setText:[NSString stringWithFormat:@"Schedule Maintenance"]];
        }
        [self.navigationItem setTitleView:label];
    }
    else{
        if(poiName != NULL){
            self.navigationItem.title =  [NSString stringWithFormat:@"Schedule Maintenance for: %@" , poiName];
        }else{
            self.navigationItem.title =  [NSString stringWithFormat:@"Schedule Maintenance"];
        }
    }

    self.organisationList = [[NSMutableArray alloc] initWithObjects:@"EPRI", @"Your Company", nil];
    self.urls = [[NSMutableArray alloc] initWithObjects:@"com.epri.research", @"com.example.company", nil];
    self.kindList = [[NSMutableArray alloc] initWithObjects:@"construction", @"disconnect", @"inspection", @"maintenance", @"meter", @"other", @"reconnect", @"repair", @"service", @"test", nil];
    self.optionList = [[NSMutableArray alloc] initWithObjects:@"Organisation", @"Work Period", @"Description", @"Priority", @"Type", nil];
    self.datesList = [[NSMutableArray alloc] initWithObjects:@"Starts", @"Ends", nil];

    selectOption.tag = -1;
    
    mySettings =  [Settings sharedInstance];
    
    orgIndex = [urls indexOfObject:organisation];
    kindIndex = [kindList indexOfObject:kind];
    
}

- (void)viewDidAppear:(BOOL)animated{
    
}


- (IBAction)startDate:(id)sender{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    self.startString = [formatter stringFromDate: ((UIDatePicker *)sender).date];
    
    [datePickers reloadData];
}

- (IBAction)endDate:(id)sender{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    self.endString = [formatter stringFromDate: ((UIDatePicker *)sender).date];
    
    [datePickers reloadData];
    
}

- (IBAction)chosePriority:(id)sender{
    priority = [sender titleForSegmentAtIndex:[sender selectedSegmentIndex]];
}


- (void)updateDescription:(id)sender{
    UITextField *textfield = (UITextField *)sender;
    self.subjectString = textfield.text;
}

- (void)textViewDidChange:(UITextView *)textView{
    self.descriptionString = textView.text;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* customView = nil;
    if(tableView != selectOption){
        
        // create the parent view that will hold header Label
        UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
            customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.bounds.size.width, 20.0)];
            headerLabel.font = [UIFont boldSystemFontOfSize:11];
            headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 20.0);
        }else{
            customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.bounds.size.width, 35.0)];
            headerLabel.font = [UIFont boldSystemFontOfSize:20.0];
            headerLabel.frame = CGRectMake(10.0, 0.0, 700.0, 35.0);
        }
        customView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.9];
        
        // create the button object
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.opaque = NO;
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.highlightedTextColor = [UIColor whiteColor];
        
        // If you want to align the header text as centered
        // headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
        
        if(tableView == selectOrganisation){
            headerLabel.text =  [NSString stringWithFormat:@"Please Choose An Organisation"];
        }else if(tableView == selectKind){
            headerLabel.text =  [NSString stringWithFormat:@"Please Choose the Kind of Work"];
        }else if(tableView == datePickers){
            headerLabel.text =  [NSString stringWithFormat:@"Please Enter the Work Dates"];
        }
        
        [customView addSubview:headerLabel];
    }
    
	return customView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float value = 0.0f;
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        value = 25.0;
    }else{
        value = 44.0;
    }
	return value;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    float value = 0.0f;
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        value = 20.0;
    }else{
        value = 35.0;
    }
	return value;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(tableView == selectOrganisation){
        return [organisationList count];
    }else if(tableView == selectKind){
        return [kindList count];
    }else if(tableView == selectOption){
        return [optionList count];
    }else if(tableView == datePickers){
        return [datesList count];
    }
    
    return 0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //this is where we deal with the click using the indexPath
    
    if(tableView == selectOrganisation){
        
        UITableViewCell *oldcell = [selectOrganisation cellForRowAtIndexPath:[NSIndexPath indexPathForRow:orgIndex inSection:0]];
        oldcell.accessoryType = UITableViewCellAccessoryNone;
        
        
        UITableViewCell *newcell = [selectOrganisation cellForRowAtIndexPath:indexPath];
        newcell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        orgIndex = [indexPath row];
        
        //set the organisation URL label to this organisation
        orgURL.text  = [urls objectAtIndex:[indexPath row]];
        self.organisation = orgURL.text;
        
        
    }else if(tableView == selectKind){
        
        UITableViewCell *oldcell = [selectKind cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kindIndex inSection:0]];
        oldcell.accessoryType = UITableViewCellAccessoryNone;
        
        UITableViewCell *newcell = [selectKind cellForRowAtIndexPath:indexPath];
        newcell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        kindIndex = [indexPath row];
        //or should this just be the index number?
        kind = [kindList objectAtIndex:kindIndex];
        
    }else if(tableView == datePickers){
        
        for (UIView *view in [self.view subviews]) { 
            if(view.tag == -2){
                [view removeFromSuperview]; 
            }
        }
        
        UIDatePicker *datePickerView = nil;
        
        if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
            datePickerView = [[UIDatePicker alloc] init ];
            datePickerView.frame = CGRectMake(110, 80, 200, 162);
        }else{
            datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(258, 150, 500, 216)];
        }        
        
        datePickerView.datePickerMode = UIDatePickerModeDateAndTime;
        datePickerView.hidden = NO;
        datePickerView.tag = -2;
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setFormatterBehavior:NSDateFormatterBehavior10_4];
        [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        
        if([indexPath row] == 0){
            NSDate *starting = [df dateFromString:self.startString];
            datePickerView.date = starting;
            [datePickerView addTarget:self action:@selector(startDate:) forControlEvents:UIControlEventValueChanged];
        }else{
            NSDate *ending = [df dateFromString:self.endString];
            datePickerView.date = ending;
            [datePickerView addTarget:self action:@selector(endDate:) forControlEvents:UIControlEventValueChanged];
        }
        
        
        [self.view addSubview:datePickerView];
        
        
    }else if(tableView == selectOption){
        
        //wipe the right view
        
        for (UIView *view in [self.view subviews]) { 
            
            //keep the option table
            if(view.tag != -1){
                [view removeFromSuperview]; 
            }
            
        }
        
        
        NSUInteger rowNumber = [indexPath row];
        
        switch (rowNumber){
            case 0: {
                
                UILabel *orgLabel = nil;
                
                if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
                    selectOrganisation = [[UITableView alloc] initWithFrame:CGRectMake(110, 10 ,200, 150) style:UITableViewStylePlain];
                    orgLabel = [[UILabel alloc] initWithFrame:CGRectMake(110,165,200, 20)];
                    orgURL = [[UILabel alloc] initWithFrame:CGRectMake(110,185, 200, 20)];
                    orgURL.font = [UIFont systemFontOfSize:11.0];
                    orgLabel.font = [UIFont systemFontOfSize:11.0];
                }else{
                    orgURL = [[UILabel alloc] initWithFrame:CGRectMake(258,570, 500, 30)];
                    selectOrganisation = [[UITableView alloc] initWithFrame:CGRectMake(258, 10 ,500, 500) style:UITableViewStylePlain];
                    orgLabel = [[UILabel alloc] initWithFrame:CGRectMake(258,530,500, 40)];
                }
                
                orgURL.text = self.organisation;
                
                selectOrganisation.dataSource = self;
                selectOrganisation.delegate = self;
                
                orgLabel.text = @"The ID for this organisation is:";
                
                [self.view addSubview:orgLabel];
                [self.view addSubview:orgURL];
                [self.view addSubview:selectOrganisation];
                
                break;
            }case 1: { 
                
                if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
                    datePickers = [[UITableView alloc] initWithFrame:CGRectMake(110, 10 ,200, 70) style:UITableViewStylePlain];
                }else{
                    datePickers = [[UITableView alloc] initWithFrame:CGRectMake(258, 10 ,500, 150) style:UITableViewStylePlain];
                    
                }
                datePickers.dataSource = self;
                datePickers.delegate = self;
                
                [self.view addSubview:datePickers];
                //                [datePickers release];
                
                break;
                
            }case 2:{
                UILabel *subLabel = nil;
                UITextField *enteredSubject = nil;
                UILabel *descLabel = nil;
                UITextView *enteredDescription = nil;
                
                
                if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
                    subLabel = [[UILabel alloc] initWithFrame:CGRectMake(110,10,200, 20)];
                    enteredSubject = [[UITextField alloc] initWithFrame:CGRectMake(110, 35, 200, 20)];
                    descLabel = [[UILabel alloc] initWithFrame:CGRectMake(110,60, 200, 20)];
                    enteredDescription = [[UITextView alloc] initWithFrame:CGRectMake(110, 85, 200, 100)];
                    subLabel.font = [UIFont systemFontOfSize:10.0];
                    enteredSubject.font = [UIFont systemFontOfSize:10.0];
                    descLabel.font = [UIFont systemFontOfSize:10.0];
                    enteredDescription.font = [UIFont systemFontOfSize:10.0];
                }else{
                    subLabel = [[UILabel alloc] initWithFrame:CGRectMake(258,10,500, 40)];
                    enteredSubject = [[UITextField alloc] initWithFrame:CGRectMake(258, 55, 500, 40)];
                    descLabel = [[UILabel alloc] initWithFrame:CGRectMake(258,100, 500, 40)];
                    enteredDescription = [[UITextView alloc] initWithFrame:CGRectMake(258, 145, 500, 200)];
                    enteredDescription.font = [UIFont systemFontOfSize:16.0];
                    enteredSubject.font = [UIFont systemFontOfSize:16.0];
                }
                
                enteredSubject.delegate = self;
                enteredSubject.returnKeyType = UIReturnKeyDone;
                
                subLabel.text = @"Please Enter a Subject for this Work:";
                
                [enteredSubject setBorderStyle:UITextBorderStyleRoundedRect]; 
                [enteredSubject addTarget:self action:@selector(updateDescription:) forControlEvents:UIControlEventEditingChanged];
                enteredSubject.text = self.subjectString;
                
                descLabel.text = @"Please Enter a Description for this Work:";
                enteredDescription.delegate = self;
                enteredDescription.editable = YES;
                enteredDescription.layer.borderWidth = 1;
                enteredDescription.layer.borderColor = [[UIColor grayColor] CGColor];
                enteredDescription.layer.cornerRadius = 8;
                enteredDescription.returnKeyType = UIReturnKeyDone;
                enteredDescription.text = self.descriptionString;
                
                [self.view addSubview:subLabel];
                [self.view addSubview:descLabel];
                [self.view addSubview:enteredDescription];
                [self.view addSubview:enteredSubject];
                
                
                break;
            }case 3:{
                
                UILabel *priorityLabel = nil;
                
                NSArray *items = [[NSMutableArray alloc] initWithObjects:@"low", @"normal", @"high", nil];
                UISegmentedControl *controlPriority = [[UISegmentedControl alloc] initWithItems:items];
                
                if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
                    priorityLabel = [[UILabel alloc] initWithFrame:CGRectMake(110,10,200, 20)];
                    controlPriority.frame = CGRectMake(110,35,200, 25);
                    priorityLabel.font = [UIFont systemFontOfSize:10.0];
                    UIFont *font = [UIFont boldSystemFontOfSize:10.0f];
                    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                                           forKey:UITextAttributeFont];
                    [controlPriority setTitleTextAttributes:attributes 
                                                   forState:UIControlStateNormal];
                    
                }else{
                    priorityLabel = [[UILabel alloc] initWithFrame:CGRectMake(258,10,500, 40)];
                    controlPriority.frame = CGRectMake(258,55,500, 40);
                    
                }
                priorityLabel.text = @"Please Choose a Priority for the Works:";
                
                [controlPriority addTarget:self action:@selector(chosePriority:) forControlEvents:UIControlEventValueChanged];
                controlPriority.selectedSegmentIndex = [items indexOfObject:priority] ;
                
                [self.view addSubview:priorityLabel];
                [self.view addSubview:controlPriority];
                
                
                break;
            }case 4:{
                
                if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
                    selectKind = [[UITableView alloc] initWithFrame:CGRectMake(110, 10 ,200, 200) style:UITableViewStylePlain];
                }else{
                    selectKind = [[UITableView alloc] initWithFrame:CGRectMake(258, 10 ,500, 500) style:UITableViewStylePlain];
                    
                }
                selectKind.dataSource = self;
                selectKind.delegate = self;
                
                [self.view addSubview:selectKind];
                //                [selectKind release];         
                break;
            }
        }
    }
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        cell.textLabel.font = [UIFont boldSystemFontOfSize:10.0f];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10.0f];
    }else{
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:18.0f];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    // Configure the cell...
	if(tableView == selectOrganisation){ 
        cell.textLabel.text = [organisationList objectAtIndex:indexPath.row];
        if(orgIndex >= 0 && indexPath.row == orgIndex){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
	else if(tableView == selectKind){ 
        cell.textLabel.text = [kindList objectAtIndex:indexPath.row];
        if(kindIndex >= 0 && indexPath.row == kindIndex){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }else if(tableView == selectOption){
        cell.textLabel.text = [optionList objectAtIndex:indexPath.row];
    }else if(tableView == datePickers){
        cell.textLabel.text = [self.datesList objectAtIndex:indexPath.row];
        if(indexPath.row == 0){
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
            NSDate *startingDate= [dateFormat dateFromString:startString]; 
            
            [dateFormat setDateFormat:@"dd-MM-yyy HH:mm:ss"];
            NSString *output = [dateFormat stringFromDate:startingDate];
            
            cell.detailTextLabel.text = output;
            
            
        }else{
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
            NSDate *endingDate= [dateFormat dateFromString:endString];
            
            [dateFormat setDateFormat:@"dd-MM-yyy HH:mm:ss"];
            NSString *output = [dateFormat stringFromDate:endingDate];
            
            cell.detailTextLabel.text = output;
            
        }
    }
    
    return cell;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if(UIDeviceOrientationIsPortrait(toInterfaceOrientation)){
        if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
            self.view.frame = CGRectMake(0, 0, 320, 460);
            self.navigationController.view.frame = CGRectMake(0, (self.view.frame.origin.y - 12), 320, 460);
        }else{
            self.view.frame = CGRectMake(0, 0, 768, 1024);
        }
    }
    else if(UIDeviceOrientationIsLandscape(toInterfaceOrientation)){
        if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
            self.navigationController.view.frame = CGRectMake(0, 0, 480, 300);
            self.view.frame = CGRectMake(0, 0, 480, 300);
        }else{
            self.view.frame = CGRectMake(0, 0, 1024, 768);
        }
    }
}

- (void) updateCoreData:(Maintenance *)man andSent:(BOOL)successfullySent{
    //now update the status of the entry
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Maintenance" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set predicate and sort orderings...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(workOrderMRID == %@)", man.workOrderMRID];
    [request setPredicate:predicate];
    
    NSError *errorFetch = nil;
    NSArray *entry = [managedObjectContext executeFetchRequest:request error:&errorFetch];
    if(!errorFetch){
        Maintenance *entryTask = [entry objectAtIndex:0];
        [entryTask setOrganisation:organisation];
        [entryTask setCreationDate:[NSDate date]];
        // [entryTask setDeviceToken:mySettings.deviceToken];
        [entryTask setEndDate:endString];
        [entryTask setStartDate:startString];
        [entryTask setDescriptionString:descriptionString];
        [entryTask setSubject:subjectString];
        [entryTask setKind:kind];
        [entryTask setPriority:priority];
        if(successfullySent){
            [entryTask  setStatus:[UIImage imageNamed:@"complete.png"]];
        }else{
            [entryTask setStatus:[UIImage imageNamed:@"pending.png"]];
        }
        [entryTask setJson:jsonString];
        
        // Commit the change.
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
            NSLog(@"error: %@", error);
        }
    }
    
}

@end
