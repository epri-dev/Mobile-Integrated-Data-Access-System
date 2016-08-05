//
//  Common.h
//  MIDAS
//
//  Created by Susan Rudd on 03/07/2012.
//  Adapted from Ray Wenderlich tutorials at www.raywenderlich.com
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, 
                        CGColorRef  endColor);

CGRect rectFor1PxStroke(CGRect rect);

void draw1PxStroke(CGContextRef context, CGPoint startPoint, CGPoint endPoint, 
                   CGColorRef color);

void drawGlossAndGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor);

CGMutablePathRef createRoundedRectForRect(CGRect rect, CGFloat radius);