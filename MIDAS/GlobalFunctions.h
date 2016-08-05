//
//  GlobalFunctions.h
//  MIDAS
//
//  Created by Susan Rudd on 10/09/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MessagesViewController.h"
#import "MIDASAppDelegate.h"

void countPendingMaintenanceRequests(NSManagedObjectContext *managedObjectContext);
void setButtonFromConnectionStatus(CustomButton *button);