//
//  NetworkTableView.m
//  MIDAS
//
//  Created by Susan Rudd on 18/01/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "NetworkTableView.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "HomeViewController.h"
#import "Asset.h"
#import "PositionPoint.h"
#import "CustomCellBackground.h"

@implementation NetworkTableView

@synthesize networkTableView;
@synthesize listData;
@synthesize networksURL;
@synthesize delegate;
@synthesize username;
@synthesize password;
@synthesize row;
@synthesize managedObjectContext;

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    NSLog(@"hey I rotated");
}

- (id)initWithURL:(NSString *)url
{
    self = [super init];
    
    if (self) {
        self.networksURL = url;
        self.networkTableView.rowHeight = 60;
    }
    return self;
}

- (id)initWithURL:(NSString *)url andUsername:(NSString *)user andPassword:(NSString *)pass
{
    self = [super init];
    
    if (self) {
        self.username = user;
        self.password = pass;
        self.networksURL = url;
        self.networkTableView.rowHeight = 60;
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    mySettings =  [Settings sharedInstance];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Please Choose a Network";
    
    [self performLibraryJSON:networksURL];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [chosenNetworkLoading stopAnimating];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

//deal with the response string to set up the array of networks
- (void)setUpArray:(NSString *)responseString{
    NSDictionary * root = [responseString JSONValue];
    NSArray *networks = [root objectForKey:@"Networks"];
    self.listData = [NSMutableArray arrayWithArray:networks];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//retrieve the JSON of networks
- (void)performLibraryJSON:(NSString *)url{
    
    NSURL *urlForData = [NSURL URLWithString:url];
    
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:urlForData];
    request.requestMethod = @"GET";    
    //[request addRequestHeader:@"Content-Type" value:@"application/json"];
    
    if(self.username != nil && self.password != nil){
        [request setUsername:self.username];
        [request setPassword:self.password];
    }
    
    // [request setDelegate:self];
    [request setCompletionBlock:^{        
        NSString *response = [request responseString];
        int status = [request responseStatusCode];
        if(status >= 200 && status < 400){
            [self setUpArray:response];
        }
    }];
    [request setFailedBlock:^{
        NSError *error = [request error];
        NSLog(@"Error: %@", error.localizedDescription);        
        if([error.localizedDescription isEqualToString:@"Authentication needed"]){
            UIAlertView * alert = [[UIAlertView alloc]
                                   initWithTitle:[NSString stringWithFormat:@"Unreconized Authentication"]
                                   message:@"Please try again."
                                   delegate:self
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
            [alert show];  
            
        }
        else{
           UIAlertView * alert = [[UIAlertView alloc]
                                   initWithTitle:[NSString stringWithFormat:@"%@", error.localizedDescription]
                                   message:@"Please try again."
                                   delegate:self
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
            [alert show];
        }
    }];
    
    //remember that this should be synchronous so that the count is correct for the table rows
    [request startSynchronous];
    
    
}

- (void) deleteAllObjects: (NSString *) entityDescription  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error;
    NSArray *items = [managedObjectContext executeFetchRequest:fetchRequest error:&error];    
    
    for (NSManagedObject *managedObject in items) {
        [managedObjectContext deleteObject:managedObject];
    }
    if (![managedObjectContext save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
    
}


- (void)storeInCoreData:(NSString *)json{
    
    //delete first
    [self deleteAllObjects:@"Asset"];

    
    NSDictionary * root = [json JSONValue];
    NSArray *entries = [root objectForKey:@"Entries"];
    for (NSArray * element in entries){
        NSArray * data = [element valueForKey:@"Elements"];
        
        for (NSArray * item in data) {
            Asset *asset = (Asset *)[NSEntityDescription insertNewObjectForEntityForName:@"Asset" inManagedObjectContext:managedObjectContext];

            [asset setUuid: [item valueForKey:@"py/id"]];
            [asset setName: [item valueForKey:@"name"]];
            NSString *type = [item valueForKey:@"py/object"];
            [asset setType:type];
            
            
            NSArray * location = [item valueForKey:@"Location"];
            [asset setLocationUUID: [location valueForKey:@"UUID"]];
                        
            NSArray * points = [location valueForKey:@"PositionPoints"];

            if ([type isEqualToString:@"Substation"] && [points count]==1){
                
                //deal with the voltage
                NSArray * voltageLevels = [item valueForKey:@"VoltageLevels"];
                NSMutableArray * voltages = [[NSMutableArray alloc] init];
                if (voltageLevels != nil){
                    for (NSArray * vl in voltageLevels){
                        NSArray * bv = [vl valueForKey:@"BaseVoltage"];
                        if (bv != nil){
                            NSNumber * voltage = [bv valueForKey:@"nominalVoltage"];
                            [voltages addObject:voltage];
                        }
                    }
                }
                
                NSString *voltageLevelsString = [[NSString alloc] init];
                for(NSNumber *volts in voltages){
                    if([voltages indexOfObject:volts] == ([voltages count] - 1)){
                        voltageLevelsString = [voltageLevelsString stringByAppendingFormat:@"%f", volts.doubleValue];
                    }else{
                        voltageLevelsString = [voltageLevelsString stringByAppendingFormat:@"%f, ", volts.doubleValue];
                    }
                    
                }
                
                [asset setVoltageLevels:voltageLevelsString];

                NSArray * point = [points objectAtIndex:0];
                PositionPoint *location = (PositionPoint *)[NSEntityDescription insertNewObjectForEntityForName:@"PositionPoint" inManagedObjectContext:managedObjectContext];
                NSString *latitude = [point valueForKey:@"yPosition"];
                NSString *longitude = [point valueForKey:@"xPosition"];
                NSString *altitude = [point valueForKey:@"zPosition"];
                
                [location setLatitude:[NSNumber numberWithDouble:[latitude doubleValue]]];
                [location setLongitude:[NSNumber numberWithDouble:[longitude doubleValue]]];
                [location setAltitude:[NSNumber numberWithDouble:[altitude doubleValue]]];
                
                NSSet *locations = [NSSet setWithObject:location];
                [asset setLocation:locations];

            }else if(([type isEqualToString:@"ACLineSegment"] || [type isEqualToString:@"Line"]) && [points count]>1){
                
                //Deal with voltage
                
                NSNumber * voltage;
                if([type isEqualToString:@"ACLineSegment"]){
                    NSArray * bv = [item valueForKey:@"BaseVoltage"];
                    if (bv != nil){
                        voltage = [bv valueForKey:@"nominalVoltage"];
                    }
                }else{
                    NSArray * equipment = [item valueForKey:@"Equipments"];
                    if (equipment != nil && [equipment count]>0){
                        for (NSArray * eq in equipment){
                            NSArray * bv = [eq valueForKey:@"BaseVoltage"];
                            if (bv != nil){
                                voltage = [bv valueForKey:@"nominalVoltage"];
                            } 
                        }
                    }
                    
                }
                
                if (voltage == nil)
                    voltage = [NSNumber numberWithFloat:0.0];
                
                [asset setVoltageLevels:[NSString stringWithFormat:@"%f", voltage.doubleValue]];
                
                NSSortDescriptor *sortDescriptor;
                sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sequenceNumber"
                                                             ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                NSArray *sortedArray;
                sortedArray = [points sortedArrayUsingDescriptors:sortDescriptors];
                NSMutableArray *locationArray = [[NSMutableArray alloc] init];

                for (NSArray * point in sortedArray){
                    PositionPoint *location = (PositionPoint *)[NSEntityDescription insertNewObjectForEntityForName:@"PositionPoint" inManagedObjectContext:managedObjectContext];
                    
                    NSString *latitude = [point valueForKey:@"yPosition"];
                    NSString *longitude = [point valueForKey:@"xPosition"];
                    NSString *altitude = [point valueForKey:@"zPosition"];
                    NSString *seqNo = [point valueForKey:@"sequenceNumber"];
                    
                    [location setLatitude:[NSNumber numberWithDouble:[latitude doubleValue]]];
                    [location setLongitude:[NSNumber numberWithDouble:[longitude doubleValue]]];
                    [location setAltitude:[NSNumber numberWithDouble:[altitude doubleValue]]];
                    [location setSeqNo:[NSNumber numberWithInt:[seqNo intValue]]];
                    [locationArray addObject:location];
                }
                
                NSSet *locations = [NSSet setWithArray:locationArray];
                [asset setLocation:locations];
            }
            
            
            NSError *error = nil;
            if (![managedObjectContext save:&error]) {
                NSLog(@"%@", error);
            }
        }
    }
    
    [mySettings setDirty:@"New Network"];
    
}

- (void)setUpPointsFromJSON{
    
    NSString *href = [row valueForKey:@"href"];
    
    NSString *serverhref = [row valueForKey:@"workManagerHref"];
    mySettings.server = serverhref;
    
    if(href != nil){
        NSURL *urlForData = [NSURL URLWithString:href];
        
        // 4
        __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:urlForData];
        request.requestMethod = @"GET";    
        //[request addRequestHeader:@"Content-Type" value:@"application/json"];
        
        // 5
        //[request setDelegate:self];
        [request setCompletionBlock:^{        
            mySettings.data = [request responseString];
            [self storeInCoreData:[request responseString]];
            [self.delegate setJSON:[request responseString]];
        }];
        [request setFailedBlock:^{
            NSError *error = [request error];
            NSLog(@"Error: %@", error.localizedDescription);
            NSLog(@"failed here in json part");
            
        }];
        
        // 6
        [request startSynchronous];
    }else{
        mySettings.data = nil;
    }
    
    //go back to home page and pass it the row
    [self.delegate displayNetwork:row];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //think the JSON call to populate the cells should be called from here since this will be called
    //each time the view is opened, to recalculate the row numbers.
    return [self.listData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SimpleTableIdentifier];
        cell.backgroundView = [[CustomCellBackground alloc] init];
        cell.selectedBackgroundView = [[CustomCellBackground alloc] init];
    }
    
    //get the row number and then retrieve the associated JSON entry
    NSUInteger rowNumber = [indexPath row];
    NSArray *rowNo = [listData objectAtIndex:rowNumber];
    
    NSString * name = [rowNo valueForKey:@"name"];
    NSString * description = [rowNo valueForKey:@"description"];
    //image
    NSString * thumbnailHref;
    CGFloat scale = 1.0;
    
    // I think the iPad2 will still work fine with this as the scale attribute will tell it what the "actual" res is
    
    //if([[mySettings device] hasPrefix:@"iPad3"] || [[mySettings device] hasPrefix:@"iPhone4"]){
        thumbnailHref = [rowNo valueForKey:@"retinaThumbnailHref"];
        scale = 2.0;
    /*}else{
        thumbnailHref = [rowNo valueForKey:@"thumbnailHref"];
    }
     */
    //do something with the imageURL
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: thumbnailHref]];
    
    
    //cell.imageView.image = [UIImage imageWithData: imageData];
    cell.imageView.image = [UIImage imageWithCGImage:[[UIImage imageWithData:imageData] CGImage] scale:scale orientation:UIImageOrientationUp];
    
    
    //cell.imageView.image = [UIImage imageNamed:@"POI64.png"];
    cell.textLabel.text = name;
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"])
        cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    cell.detailTextLabel.text = description;
    cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    
    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.detailTextLabel.numberOfLines = 0;
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"])
        cell.detailTextLabel.font = [UIFont systemFontOfSize:11.0f];
    [cell sizeToFit];
    //if we want a radiotype with check mark this is the option
    // cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    return cell;  
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [chosenNetworkLoading startAnimating];
    
    //this is where we deal with the click using the indexPath
    NSUInteger rowNumber = [indexPath row];
    row = [listData objectAtIndex:rowNumber];
    
    [self performSelector:@selector(setUpPointsFromJSON) withObject:nil afterDelay:.06]; 
    
    
}

@end
