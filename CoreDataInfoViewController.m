//
//  CoreDataViewController.m
//  MIDAS
//
//  Created by Susan Rudd on 23/04/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "CoreDataInfoViewController.h"

#import "Asset.h"
#import "PositionPoint.h"
#import "SBJson.h"
#import "CustomCellBackground.h"

@interface CoreDataInfoViewController ()

@end

@implementation CoreDataInfoViewController
@synthesize dataInfoArray;
@synthesize managedObjectContext;
@synthesize delegate;
@synthesize networkTableView;

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [chosenNetworkLoading stopAnimating];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Please Choose a Network";
    
    //set up fetch entity request from data store
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"NetworkDataInfo" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    //sort retrieved data
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    //fetch the request
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    if (mutableFetchResults == nil) {
        // Handle the error.
    }
    
    //set tables array to fetched array
    [self setDataInfoArray:mutableFetchResults];
    
}

- (void)viewDidUnload
{
    self.dataInfoArray = nil;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    mySettings =  [Settings sharedInstance];
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [dataInfoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    // Dequeue or create a new cell.
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.backgroundView = [[CustomCellBackground alloc] init];
        cell.selectedBackgroundView = [[CustomCellBackground alloc] init];
        
        NetworkDataInfo *pullNetworkInfo = (NetworkDataInfo *)[dataInfoArray objectAtIndex:indexPath.row];
    
        //if([[mySettings device] hasPrefix:@"iPad3"] || [[mySettings device] hasPrefix:@"iPhone4"]){
            cell.imageView.image = [pullNetworkInfo retinalThumbnail];
/*        }else{
            cell.imageView.image = [pullNetworkInfo thumbnail];
        }*/
        
        cell.textLabel.text = [pullNetworkInfo name];;
        if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"])
            cell.textLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        cell.detailTextLabel.text = [pullNetworkInfo networkDescription];;
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.detailTextLabel.numberOfLines = 0;
        if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"])
            cell.detailTextLabel.font = [UIFont systemFontOfSize:11.0f];
        
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        [cell sizeToFit];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the managed object at the given index path.
        NSManagedObject *infoToDelete = [dataInfoArray objectAtIndex:indexPath.row];
        [managedObjectContext deleteObject:infoToDelete];
        
        // Update the array and table view.
        [dataInfoArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        
        // Commit the change.
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
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

- (void)storeInCoreData{
    
    NSString *json = mySettings.data;
    
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

    //go back to home page and pass it the row
    [self.delegate displayNetworkInfo:networkInfo];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [chosenNetworkLoading startAnimating];
    
    networkInfo = (NetworkDataInfo *)[dataInfoArray objectAtIndex:indexPath.row];
    
    NSString *serverhref = [networkInfo workManagerHref];
    mySettings.server = serverhref;
    mySettings.data = [networkInfo json];
    
    [self performSelector:@selector(storeInCoreData) withObject:nil afterDelay:.06]; 
    

    

}

@end
