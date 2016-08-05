//
//  NetworkData.h
//  MIDAS
//
//  Created by Susan Rudd on 23/04/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class NetworkDataInfo;

@interface NetworkData : NSManagedObject

@property (nonatomic) NSString * uuid;
@property (nonatomic) NSString * altitude;
@property (nonatomic) NSString * longitude;
@property (nonatomic) NSString * latitude;
@property (nonatomic) NSString * type;
@property (nonatomic) NSString * name;
@property (nonatomic) id voltages;
@property (nonatomic) NetworkDataInfo *info;

@end
