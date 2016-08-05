//
//  Line.h
//  StreetView
//
//  Created by Susan Rudd on 06/09/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "IndividualPoint.h"


@interface Line : NSObject {
    NSMutableArray *points;
    UIColor *colour;
    double voltage;
    double scale;
    NSMutableArray *pointsOnScreen;
    NSMutableArray *recursiveScale;
}

@property (nonatomic) NSMutableArray *points;
@property (nonatomic) NSMutableArray *recursiveScale;
@property (nonatomic) UIColor *colour;
@property (nonatomic) double voltage;

@property (nonatomic) double scale;
@property (nonatomic) NSMutableArray *pointsOnScreen;

- (id)initWithPoints:(NSArray *)inpoints;
- (id)initWithPoints:(NSArray *)inpoints andVoltage:(double)voltage;


@end
