//
//  Maintenance.h
//  MIDAS
//
//  Created by Susan Rudd on 06/09/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Maintenance : NSManagedObject

@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) UIImage  * status;
@property (nonatomic, retain) NSString * workOrderMRID;
@property (nonatomic, retain) NSString * json;
@property (nonatomic, retain) NSString * deviceToken;
@property (nonatomic, retain) NSString * priority;
@property (nonatomic, retain) NSString * endDate;
@property (nonatomic, retain) NSString * descriptionString;
@property (nonatomic, retain) NSString * poiName;
@property (nonatomic, retain) NSString * organisation;
@property (nonatomic, retain) NSString * startDate;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSString * kind;
@property (nonatomic, retain) NSString * serverResponse;

@end
