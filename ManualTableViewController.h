//
//  ManualTableViewController.h
//  MIDAS
//
//  Created by Susan Rudd on 30/05/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointOfInterest.h"
#import "MapViewerViewController.h"

@interface ManualTableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>{
    UITableView *manualTableView;
    PointOfInterest *poi;
    id<ManualsDelegate> __weak delegate;
    
    NSMutableArray *listManuals;

}

@property (nonatomic) IBOutlet UITableView *manualTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil andPoi:(PointOfInterest *)newpoi;
@property (nonatomic, weak) id<ManualsDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *listManuals;


@end
