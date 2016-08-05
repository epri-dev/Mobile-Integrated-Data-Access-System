//
//  MIDASAppDelegate.m
//  MIDAS
//
//  Created by Susan Rudd on 15/09/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "MIDASAppDelegate.h"
#import "Settings.h"
#import "SBJson.h"
#import "HomeViewController.h"
#import "MessagesViewController.h"
#import "MapViewerViewController.h"
#import "StreetViewViewController.h"
#import "GlobalFunctions.h"

@implementation ImageToDataTransformer

+ (BOOL)allowsReverseTransformation {
	return YES;
}
+ (Class)transformedValueClass {
	return [NSData class];
}
- (id)transformedValue:(id)value {
	NSData *data = UIImagePNGRepresentation(value);
	return data;
}
- (id)reverseTransformedValue:(id)value {
	UIImage *uiImage = [[UIImage alloc] initWithData:value];
	return uiImage;
}

@end

@implementation MIDASAppDelegate

@synthesize tabBarController;
@synthesize window=_window;
@synthesize managedObjectContext=__managedObjectContext;
@synthesize managedObjectModel=__managedObjectModel;
@synthesize persistentStoreCoordinator=__persistentStoreCoordinator;
@synthesize navController;
@synthesize netStatus;


- (void)addMessageFromRemoteNotification:(NSDictionary*)userInfo updateUI:(BOOL)updateUI
{
    
	NSString* alertValue = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    
	NSMutableArray* parts = [NSMutableArray arrayWithArray:[alertValue componentsSeparatedByString:@": "]];
    
    NSString *mrID = [parts objectAtIndex:0];
    NSString *status = nil;
    if([parts count] >1)
        status = [parts objectAtIndex:1];
    NSString *reason = nil;
    if([parts count] > 2)
        reason = [parts objectAtIndex:2];
    if(status != nil){
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[NSString stringWithFormat:@"Status: %@", status]
                              message:reason
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:[NSString stringWithFormat:@"Message:"]
                              message:mrID
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
    
    
    NSString *message;
    
    if(reason != nil){
        message = [NSString stringWithFormat:@"%@: ", status];
        message = [message stringByAppendingString:reason];
    }else{
        message = status;
    }
    
    if(status != nil){
        //now update the status of the entry
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Maintenance" inManagedObjectContext:__managedObjectContext];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];
        
        // Set predicate and sort orderings...
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(workOrderMRID == %@)", mrID];
        [request setPredicate:predicate];
        
        NSError *errorFetch = nil;
        NSArray *entry = [__managedObjectContext executeFetchRequest:request error:&errorFetch];
        if(!errorFetch){
            NSManagedObject *entryTask = [entry objectAtIndex:0];
            [entryTask setValue:message forKey:@"serverResponse"];
            
            if([status isEqualToString:@"Approved"]){
                [entryTask setValue:[UIImage imageNamed:@"complete.png"] forKey:@"status"];
            }else{
                [entryTask setValue:[UIImage imageNamed:@"denied.png"] forKey:@"status"];
            }
            // Commit the change.
            NSError *error = nil;
            if (![__managedObjectContext save:&error]) {
                // Handle the error.
                NSLog(@"error: %@", error);
            }
        }
        
        countPendingMaintenanceRequests(__managedObjectContext);
    }
    
    
}

//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    netStatus = [curReach currentReachabilityStatus];
    
    mySettings.connectionStatus = netStatus;
    
    //need to do this incase there is a more button and user configures order
    for(UIViewController *control in [tabBarController viewControllers]){
        if([control isKindOfClass:[UINavigationController class]]){
            if([[[(UINavigationController *)control viewControllers] objectAtIndex:0] isKindOfClass:[HomeViewController class]]){
                    HomeViewController *hvc = (HomeViewController*)[[(UINavigationController *)control viewControllers] objectAtIndex:0];
                    setButtonFromConnectionStatus(hvc.selectNetwork);
            }else if([[[(UINavigationController *)control viewControllers] objectAtIndex:0] isKindOfClass:[MapViewerViewController class]]){
                MapViewerViewController *map = (MapViewerViewController*)[[(UINavigationController *)control viewControllers] objectAtIndex:0];
                if(netStatus == NotReachable){
                    map.mapTypeLabel.text = nil;
                }else{
                    if(map.previousMapType != nil && ![map.previousMapType isEqualToString:@""] && ![map.previousMapType isEqualToString:@"Apple"]){
                        map.mapTypeLabel.text = @"OpenStreetMap";
                    }
                }
            }else if([[[(UINavigationController *)control viewControllers] objectAtIndex:0] isKindOfClass:[MessagesViewController class]]){
                MessagesViewController *mvc = (MessagesViewController *)[[(UINavigationController *)control viewControllers] objectAtIndex:0];
                setButtonFromConnectionStatus(mvc.sendSelection);
            }
        }
    }
}

-(void)showEULA{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Accept User Agreement"
                                                    message:@"*************************************** \n MIDAS Version 1.0 \n\n Electric Power Research Institute (EPRI) \n 3420 Hillview Ave. \n Palo Alto, \n CA 94304 \n\n Copyright © 2012 Electric Power Research Institute, Inc. All rights reserved. \n\n As a user of this EPRI preproduction software, you accept and acknowledge that: \n •	This software is a preproduction version which may have problems that could potentially harm your system \n •	To satisfy the terms and conditions of the Master License Agreement or Preproduction License Agreement between EPRI and your company, you understand what to do with this preproduction product after the preproduction review period has expired \n •	Reproduction or distribution of this preproduction software is in violation of the terms and conditions of the Master License Agreement or Preproduction License Agreement currently in place between EPRI and your company \n •	Your company's funding will determine if you have the rights to the final production release of this product \n •	EPRI will evaluate all tester suggestions and recommendations, but does not guarantee they will be incorporated into the final production product \n •	As a preproduction tester, you agree to provide feedback as a condition of obtaining the preproduction software \n **************************************"
                                                   delegate:self
                                          cancelButtonTitle:@"Accept"
                                          otherButtonTitles:@"Reject", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if(buttonIndex == 1){
        NSURL *url = [NSURL URLWithString:@"http://www.epri.com"];
        
        if (![[UIApplication sharedApplication] openURL:url])
            NSLog(@"%@%@",@"Failed to open url:",[url description]);
        
        [self showEULA];
        
    }else{
        //set up the global settings class to recieve the device token
        mySettings =  [Settings sharedInstance];
        //set up device type
        [mySettings setDevice];
        
        // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the
        // method "reachabilityChanged" will be called.
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
        
        //Change the host name here to change the server your monitoring
        hostReach = [Reachability reachabilityWithHostName: @"www.apple.com"];
        [hostReach startNotifier];
        
        tabBarController.delegate = self;
        
        [self.window setRootViewController:tabBarController];
        //[self.window addSubview:tabBarController.view];
        [self.window makeKeyAndVisible];
        
        // Let the device know we want to receive push notifications
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
        
        //not sure if this is the right way to pass this managedObjectContext but people were saying it was bad to access the delegate the other way so....
        for(UIViewController *control in [tabBarController viewControllers]){
            if([control isKindOfClass:[UINavigationController class]]){
                    if([[[(UINavigationController *)control viewControllers] objectAtIndex:0] isKindOfClass:[HomeViewController class]]){
                        HomeViewController *hvc = (HomeViewController*)[[(UINavigationController *)control viewControllers] objectAtIndex:0];
                        hvc.managedObjectContext = self.managedObjectContext;
                    }else if([[[(UINavigationController *)control viewControllers] objectAtIndex:0] isKindOfClass:[MapViewerViewController class]]){
                        MapViewerViewController *mvc = (MapViewerViewController *)[[(UINavigationController *)control viewControllers] objectAtIndex:0];
                        mvc.managedObjectContext = self.managedObjectContext;
                    }else if([[[(UINavigationController *)control viewControllers] objectAtIndex:0] isKindOfClass:[StreetViewViewController class]]){
                        StreetViewViewController *svc = (StreetViewViewController *)[[(UINavigationController *)control viewControllers] objectAtIndex:0];
                        svc.managedObjectContext = self.managedObjectContext;
                    }else if([[[(UINavigationController *)control viewControllers] objectAtIndex:0] isKindOfClass:[MessagesViewController class]]){
                        MessagesViewController *mvc = (MessagesViewController *)[[(UINavigationController *)control viewControllers] objectAtIndex:0];
                        mvc.managedObjectContext = self.managedObjectContext;
                    }
            }
        }
        
        countPendingMaintenanceRequests(self.managedObjectContext);
    }
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //if launching from notification
    if (launchOptions != nil)
    {
        NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
        {
            NSLog(@"Launched from push notification: %@", dictionary);
            //application.applicationIconBadgeNumber = 0;
            [self addMessageFromRemoteNotification:dictionary updateUI:NO];
        }
    }else{
        [self showEULA];
    }
    
    return YES;
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	NSLog(@"Received notification: %@", userInfo);
    //application.applicationIconBadgeNumber = 0;
	[self addMessageFromRemoteNotification:userInfo updateUI:YES];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    
	NSString* newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    mySettings.deviceToken = newToken;
    NSLog(@"new token %@", newToken);
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


- (void)awakeFromNib
{
    /*
     Typically you should set up the Core Data stack here, usually by passing the managed object context to the first view controller.
     self.<#View controller#>.managedObjectContext = self.managedObjectContext;
     */
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
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MIDAS" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MIDAS.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
    if(changed) {
        countPendingMaintenanceRequests(self.managedObjectContext);
    }
}

//will only fire if tap more button not the one inside it....
//- (void)tabBarController:(UITabBarController *)tabBarControl didSelectViewController:(UIViewController *)viewController{
//    int index = [[tabBarControl viewControllers] indexOfObject:viewController];
//    if(([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"] && index > 4 )|| ([[[UIDevice currentDevice] model] hasPrefix:@"iPad"] && index > 6)){
//        //this means that the view is in the more tab
//        [[[tabBarControl navigationController] navigationBar] setHidden:YES];
//    }
//
//}




@end
