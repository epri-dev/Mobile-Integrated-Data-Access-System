//
//  MIDASAppDelegate.h
//  MIDAS
//
//  Created by Susan Rudd on 15/09/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"
#import "Reachability.h"

@class Reachability;

@interface ImageToDataTransformer : NSValueTransformer { }
@end

@interface MIDASAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UIAlertViewDelegate> {
    IBOutlet UITabBarController *tabBarController;
    
    Settings *mySettings;
    Reachability* hostReach;
    NetworkStatus netStatus;
}

@property (nonatomic) IBOutlet UIWindow *window;

@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) UITabBarController *tabBarController;
@property (nonatomic) UINavigationController *navController;
@property (nonatomic) NetworkStatus netStatus;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end
