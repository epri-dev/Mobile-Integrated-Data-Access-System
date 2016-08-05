//
//  GlobalFunctions.m
//  MIDAS
//
//  Created by Susan Rudd on 10/09/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "GlobalFunctions.h"

void countPendingMaintenanceRequests(NSManagedObjectContext *managedObjectContext){
    //count how many in core data are pending or denied
    NSEntityDescription *entryPending = [NSEntityDescription entityForName:@"Maintenance" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *requestPending = [[NSFetchRequest alloc] init];
    [requestPending setEntity:entryPending];
    
    // Set predicate and sort orderings...
    NSPredicate *predicatePending = [NSPredicate predicateWithFormat:@"(status == %@ || status == %@)", [UIImage imageNamed:@"denied.png"], [UIImage imageNamed:@"pending.png"]];
    [requestPending setPredicate:predicatePending];
    
    NSError *errorFetchPending = nil;
    NSArray *allPendings = [managedObjectContext executeFetchRequest:requestPending error:&errorFetchPending];
    if(!errorFetchPending){
        MIDASAppDelegate *appDelegate = (MIDASAppDelegate *)[[UIApplication sharedApplication] delegate];
        for(UIViewController *control in [[appDelegate tabBarController] viewControllers]){
            if([control isKindOfClass:[UINavigationController class]]){
                if([[[(UINavigationController *)control viewControllers] objectAtIndex:0] isKindOfClass:[MessagesViewController class]]){
                    int index = [[appDelegate tabBarController].viewControllers indexOfObject:control];
                    if(([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"] && index > 4 )|| ([[[UIDevice currentDevice] model] hasPrefix:@"iPad"] && index > 6)){
                        if([allPendings count] > 0){
                            [[[[appDelegate tabBarController] moreNavigationController] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d", [allPendings count]]];
                        }else{
                            [[[[appDelegate tabBarController] moreNavigationController] tabBarItem] setBadgeValue:NULL];
                        }
                    }else{
                        if([allPendings count] > 0){
                            [[control tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%d", [allPendings count]]];
                        }else{
                            [[control tabBarItem] setBadgeValue:NULL];
                        }
                        
                        if([[[appDelegate tabBarController] moreNavigationController] tabBarItem] != nil){
                            [[[[appDelegate tabBarController] moreNavigationController] tabBarItem] setBadgeValue:NULL];
                        }
                    }
                }
            }
            
        }
        
    }
}

void setButtonFromConnectionStatus(CustomButton *button){
    Settings *mySettings = [Settings sharedInstance];
    int netStatus = mySettings.connectionStatus;
    
    switch (netStatus)
    {
        case NotReachable:
        {
            button.enabled = NO;
            break;
        }
            
        case ReachableViaWWAN:
        {
            button.enabled = YES;
            break;
        }
        case ReachableViaWiFi:
        {
            button.enabled = YES;
            break;
        }
    }
}
