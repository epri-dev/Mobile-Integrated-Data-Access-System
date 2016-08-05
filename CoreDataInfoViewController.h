//
//  CoreDataInfoViewController.h
//  MIDAS
//
//  Created by Susan Rudd on 23/04/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkDataInfo.h"
#import "Settings.h"

@protocol CoreDataDelegate

- (void)displayNetworkInfo:(NetworkDataInfo *)chosenNetwork;

@end

@interface CoreDataInfoViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    
    NSMutableArray *dataInfoArray;
    NSManagedObjectContext *managedObjectContext;
    id<CoreDataDelegate> __weak delegate;
    Settings *mySettings;
    NetworkDataInfo *networkInfo;
    
    IBOutlet UIActivityIndicatorView *chosenNetworkLoading;

    
}

@property (nonatomic) NSMutableArray *dataInfoArray;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, weak) id<CoreDataDelegate>  delegate;


@property (nonatomic) IBOutlet UITableView *networkTableView;

@end