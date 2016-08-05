//
//  MessagesViewController.m
//  MIDAS
//
//  Created by Susan Rudd on 19/04/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "MessagesViewController.h"
#import "CustomCellBackground.h"
#import "CustomHeader.h"
#import "TaskTableCell.h"
#import "ScheduleMaintanence.h"
#import "GlobalFunctions.h"

@interface MessagesViewController ()

@end

@implementation MessagesViewController
@synthesize messageTable;
@synthesize managedObjectContext;
@synthesize selectedItems;
@synthesize sendSelection;

@synthesize fetchedResultsController = _fetchedResultsController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedItems = [[NSMutableArray alloc] init];
    messageTable.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    messageTable.layer.borderWidth = 3.0;
    messageTable.layer.cornerRadius = 10.0;
    
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewDidAppear:(BOOL)animated{
    setButtonFromConnectionStatus(sendSelection);
}

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Maintenance" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"poiName" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.fetchedResultsController = nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    id  sectionInfo =
    [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CustomHeader *header = [[CustomHeader alloc] init];
    header.titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    return header;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Stored Maintenance Tasks";
}

- (void)configureCell:(TaskTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Maintenance *man = (Maintenance *)[_fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.nameLabel.text = [man poiName];
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"])
        cell.nameLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    cell.subNameLabel.text = [man subject];
    cell.subNameLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.subNameLabel.textColor = [UIColor darkGrayColor];
    cell.subNameLabel.numberOfLines = 0;
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"])
        cell.subNameLabel.font = [UIFont systemFontOfSize:11.0f];
    cell.statusImageView.image = [man status];
    [[cell checkedImageView] setImage:[UIImage imageNamed:@"checkMark"]];
    
    
    if([selectedItems containsObject:man]){
        [[cell checkedImageView]setHidden:NO];
    }else{
        [[cell checkedImageView]setHidden:YES];
    }
    
    if([man serverResponse] != nil){
        cell.approvedOrDenied.text = [man serverResponse];
        if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"])
            cell.approvedOrDenied.font = [UIFont systemFontOfSize:7.0f];
    }
    
    cell.nameLabel.backgroundColor = [UIColor clearColor];
    cell.subNameLabel.backgroundColor = [UIColor clearColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    
    static NSString *CellIdentifier = @"TaskTableCell";
    
    // Dequeue or create a new cell.
    TaskTableCell *cell = (TaskTableCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) 
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"TaskTableCell" owner:nil options:nil];
        
        for(id currentObject in topLevelObjects)
        {
            if([currentObject isKindOfClass:[UITableViewCell class]])
            {
                cell = (TaskTableCell *)currentObject;
                break;
            }
        }
        
        cell.backgroundView = [[CustomCellBackground alloc] init];
        cell.selectedBackgroundView = [[CustomCellBackground alloc] init];
    } 
    
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.messageTable beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.messageTable;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            countPendingMaintenanceRequests(managedObjectContext);
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(TaskTableCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.messageTable insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.messageTable deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.messageTable endUpdates];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the managed object at the given index path.
        NSManagedObject *infoToDelete = (Maintenance *)[_fetchedResultsController objectAtIndexPath:indexPath];
        [managedObjectContext deleteObject:infoToDelete];
        
        // Update the selectedItems array
        if([selectedItems containsObject:infoToDelete]){
            [selectedItems removeObject:infoToDelete];
        }
        
        // Commit the change, which will call the delegate method to delete from the table view
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TaskTableCell *newcell = (TaskTableCell *)[tableView cellForRowAtIndexPath:indexPath];
    if([newcell.checkedImageView isHidden]){
        [[newcell checkedImageView]setHidden:NO];
        [selectedItems addObject:(Maintenance *)[_fetchedResultsController objectAtIndexPath:indexPath]];
    }else if(![newcell.checkedImageView isHidden]){
        [[newcell checkedImageView]setHidden:YES];
        [selectedItems removeObject:(Maintenance *)[_fetchedResultsController objectAtIndexPath:indexPath]];
    }
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    
    ScheduleMaintanence *wo = [[ScheduleMaintanence alloc] initWithNibName:@"ScheduleMaintanence" withStoredMainenance:(Maintenance *)[_fetchedResultsController objectAtIndexPath:indexPath]];
    wo.managedObjectContext = managedObjectContext;
    [self.navigationController pushViewController:wo animated:YES];
}

- (void) updateCoreData:(Maintenance *)man{
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
        [entryTask setStatus:[UIImage imageNamed:@"complete.png"]];
        // Commit the change.
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            // Handle the error.
            NSLog(@"error: %@", error);
        }
    }
    
}

-(IBAction)sendMessageSelection:(id)sender{
    //send selected items
    //TODO
    
    //if there is signal that do this...
    
    //update core data to reflect these messages have been sent
    for(id items in selectedItems){
        Maintenance *man = (Maintenance *)items;
        NSString *json = [man json];
        NSLog(@"%@", json);
        //will need to deal with that happens with the notifications, unless rather than alerts they go into the table view
        [self updateCoreData:man];
    }
    
    //deselect all rows
    for (TaskTableCell *cell in [messageTable visibleCells]) {
        [[cell checkedImageView]setHidden:YES];
    }
    
    [selectedItems removeAllObjects];
    
}

-(IBAction)deleteMessageSelection:(id)sender{
    // Delete the managed object at the given index path.
    for(id items in selectedItems){
        Maintenance *man = (Maintenance *)items;
        [managedObjectContext deleteObject:man];
    }
    
    NSError *error = nil;
    if (![managedObjectContext save:&error]) {
        // Handle the error.
    }
    
    for (TaskTableCell *cell in [messageTable visibleCells]) {
        [[cell checkedImageView]setHidden:YES];
    }
    
    [selectedItems removeAllObjects];
    
}

-(IBAction)selectAllMessages:(id)sender{
    for(id item in [_fetchedResultsController fetchedObjects]){
        Maintenance *man = (Maintenance *)item;
        if(![selectedItems containsObject:man]){
            [selectedItems addObject:man];
        }
    }
    
    for (TaskTableCell *cell in [messageTable visibleCells]) {
        [[cell checkedImageView]setHidden:NO];
    }
}

-(IBAction)deselectAllMessages:(id)sender{
    for(id item in [_fetchedResultsController fetchedObjects]){
        Maintenance *man = (Maintenance *)item;
        if([selectedItems containsObject:man]){
            [selectedItems removeObject:man];
        }
    }
    
    for (TaskTableCell *cell in [messageTable visibleCells]) {
        [[cell checkedImageView]setHidden:YES];
    }
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
