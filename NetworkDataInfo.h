//
//  NetworkDataInfo.h
//  MIDAS
//
//  Created by Susan Rudd on 24/04/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NetworkDataInfo : NSManagedObject

@property (nonatomic) NSString * name;
@property (nonatomic) UIImage *thumbnail;
@property (nonatomic) NSString * networkDescription;
@property (nonatomic) UIImage *retinalThumbnail;
@property (nonatomic) UIImage *icon;
@property (nonatomic) UIImage *retinaIcon;
@property (nonatomic) NSString * workManagerHref;
@property (nonatomic) NSString * json;

@end
