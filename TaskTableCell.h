//
//  TaskTableCell.h
//  MIDAS
//
//  Created by Susan Rudd on 16/08/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaskTableCell : UITableViewCell{
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *subNameLabel;
    IBOutlet UILabel *approvedOrDenied;
    IBOutlet UIImageView *statusImageView;
    IBOutlet UIImageView *checkedImageView;
}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *subNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *approvedOrDenied;
@property (nonatomic, retain) IBOutlet UIImageView *statusImageView;
@property (nonatomic, retain) IBOutlet UIImageView *checkedImageView;

@end
