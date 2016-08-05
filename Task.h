//
//  Task.h
//  MIDAS
//
//  Created by Susan Rudd on 06/06/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) UIImage *status;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * taskName;
@property (nonatomic, retain) NSString * assetID;
@property (nonatomic, retain) NSString * assetName;
@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSString * json;

@end
