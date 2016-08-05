//
//  ManualTableViewController.m
//  MIDAS
//
//  Created by Susan Rudd on 30/05/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "ManualTableViewController.h"
#import "PDFViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ManualTableViewController ()

@end

@implementation ManualTableViewController
@synthesize manualTableView;
@synthesize delegate;
@synthesize listManuals;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil andPoi:(PointOfInterest *)newpoi{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        poi = newpoi;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated{
    [self setContentSizeForViewInPopover:CGSizeMake(320, 400)];
}

- (void)cancelButtonPressed {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
        [self.navigationItem setRightBarButtonItem:cancel];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPad"]){
        manualTableView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
        manualTableView.layer.borderWidth = 1.0;
        manualTableView.layer.cornerRadius = 10.0;
    }
    
    self.listManuals = [[NSMutableArray alloc] initWithObjects:@"Manual_Open_REC_N_CAPM.pdf", @"In_and_Out_of_Service_REC_N_CAPM5.pdf", @"Control_Open_or_Close_REC_N_CAPM.pdf", @"Alernative_Settings_REC_N_CAPM5.pdf", nil];
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return  YES;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.listManuals count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float value =  44.0;
	return value;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSUInteger rowNumber = [indexPath row];
    cell.textLabel.text = [self.listManuals objectAtIndex:rowNumber];
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        cell.textLabel.font = [UIFont boldSystemFontOfSize:11.0f];
    }else{
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    }
    
    cell.imageView.image = [UIImage imageNamed:@"pdf.png"];    
    
    switch (rowNumber) {
        case 0:
            cell.detailTextLabel.text = @"(654KB)";
            break;
        case 1:
            cell.detailTextLabel.text = @"(927KB)";
            break;
        case 2:
            cell.detailTextLabel.text = @"(933KB)";
            break;
        case 3:
            cell.detailTextLabel.text = @"(21MB)";
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger rowNumber = [indexPath row];
    NSString *name = [listManuals objectAtIndex:rowNumber];
    [delegate viewManualFromTable:poi withStringURL:name];
}

@end
