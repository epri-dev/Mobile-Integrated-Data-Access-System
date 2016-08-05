//
//  MessagesViewController.h
//  MIDAS
//
//  Created by Susan Rudd on 19/04/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Maintenance.h"
#import "CustomButton.h"

@class CustomButton;

@interface MessagesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>{
    IBOutlet UITableView *messageTable;

    NSManagedObjectContext *managedObjectContext;
    NSMutableArray *selected;
    CustomButton *sendSelection;
    UINavigationController *navController;

}

-(IBAction)sendMessageSelection:(id)sender;
-(IBAction)deleteMessageSelection:(id)sender;
-(IBAction)selectAllMessages:(id)sender;
-(IBAction)deselectAllMessages:(id)sender;

@property (nonatomic) IBOutlet UITableView *messageTable;
@property (nonatomic) NSMutableArray *selectedItems;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic) IBOutlet CustomButton *sendSelection;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

@end
