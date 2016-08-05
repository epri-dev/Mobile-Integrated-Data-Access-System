//
//  IconGenerator.h
//  MapViewer
//
//  Created by Alan McMorran on 10/08/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface IconGenerator : NSObject {
    
    
}

+(NSDictionary *) voltageColours;
+(NSMutableDictionary *) iconImages;
+(UIImage *) getIconOfWidth: (NSInteger)x height: (NSInteger) y voltages: (NSArray *) voltages;

+(UIColor *) getVoltageColour: (NSNumber *) voltage;
+ (UIColor *) getColourForComponents: (NSDictionary *) components;
+ (UIImage *) applyIconHighlightToImage: (UIImage *) icon;
@end
