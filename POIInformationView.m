//
//  POIInformationView.m
//  MIDAS
//
//  Created by Susan Rudd on 22/09/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "POIInformationView.h"
#import "StreetViewViewController.h"

@implementation POIInformationView
@synthesize listData;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil andPoi:(PointOfInterest *)newpoi
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        poi = newpoi;
    }
    return self;
}

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // [optionsTableView release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.listData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *SimpleTableIdentifier = @"maintenanceTableView";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SimpleTableIdentifier];
        
    }
    
    //get the row number and then retrieve the associated JSON entry
    NSUInteger rowNumber = [indexPath row];
    cell.textLabel.text = [listData objectAtIndex:rowNumber];
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        cell.textLabel.font = [UIFont boldSystemFontOfSize:11.0f];
    }else{
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    }
    
    switch (rowNumber) {
        case 0:
            cell.imageView.image = [UIImage imageNamed:@"WorkOrder.png"];    
            break;
        case 1:
            cell.imageView.image = [UIImage imageNamed:@"pdf.png"];    
            break;
        case 2:
            cell.imageView.image = [UIImage imageNamed:@"pin.png"];    
            break;
    }
    
    return cell;  
    
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	// create the parent view that will hold header Label
    UIView* customView = nil;
    UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.bounds.size.width, 20.0)];
        headerLabel.font = [UIFont boldSystemFontOfSize:12];
        headerLabel.frame = CGRectMake(10.0, 0.0, 300.0, 20.0);
    }else{
        customView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, tableView.bounds.size.width, 35.0)];
        headerLabel.font = [UIFont boldSystemFontOfSize:15.0];
        headerLabel.frame = CGRectMake(10.0, 0.0, 400.0, 35.0);
    }
    customView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.9];
	
	// create the button object
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = NO;
	headerLabel.textColor = [UIColor whiteColor];
	headerLabel.highlightedTextColor = [UIColor whiteColor];
    
	// If you want to align the header text as centered
	// headerLabel.frame = CGRectMake(150.0, 0.0, 300.0, 44.0);
    
	headerLabel.text =  [NSString stringWithFormat:@"Please Choose One of the Following:"]; // i.e. array element
	[customView addSubview:headerLabel];
    
	return customView;
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

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return [NSString stringWithFormat:@"Please Choose One of the Following"];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //this is where we deal with the click using the indexPath
    
    NSUInteger rowNumber = [indexPath row];
    
    switch (rowNumber){
        case 0: {
            [delegate scheduleMaintenance:poi];
            break;
        }case 1: { 
            [delegate viewManual:poi];
            break;
        }case 2: {
            [delegate viewAssetOnMap:poi];
            break;
        }
            
    }
}


- (void)cancelButtonPressed {
    [self.navigationController.view removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"])
        [self setContentSizeForViewInPopover:CGSizeMake(320, 400)];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont boldSystemFontOfSize:12.0];
        // Optional - label.text = @"NavLabel";
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        [label setText:[NSString stringWithFormat:@"Options for: %@" , poi.name]];
        [label sizeToFit];
        self.navigationItem.titleView = label;
    }else{
        self.navigationItem.title =  [NSString stringWithFormat:@"Options for: %@" , poi.name];
    }
    // Do any additional setup after loading the view from its nib.
    self.listData = [[NSMutableArray alloc] initWithObjects:@"Schedule Maintenance", @"View Asset Manual", @"View Asset On Map", nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


//depricated in ios6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    }
	return YES;
}

//for rotation in ios6
-(NSUInteger)supportedInterfaceOrientations{
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
    }
    
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}



@end
