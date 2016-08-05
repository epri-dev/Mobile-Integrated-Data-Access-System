//
//  Asset.h
//  MIDAS
//
//  Created by Susan Rudd on 25/06/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PositionPoint;

@interface Asset : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) UIImage *icon;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * voltageLevels;
@property (nonatomic, retain) NSString * locationUUID;
@property (nonatomic, retain) NSSet *location;
@end

@interface Asset (CoreDataGeneratedAccessors)

- (void)addLocationObject:(PositionPoint *)value;
- (void)removeLocationObject:(PositionPoint *)value;
- (void)addLocation:(NSSet *)values;
- (void)removeLocation:(NSSet *)values;

@end
