//
//  PositionPoint.h
//  MIDAS
//
//  Created by Susan Rudd on 25/06/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Asset;

@interface PositionPoint : NSManagedObject

@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * seqNo;
@property (nonatomic, retain) Asset *asset;

@end
