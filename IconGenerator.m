//
//  IconGenerator.m
//  MapViewer
//
//  Created by Alan McMorran on 10/08/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "IconGenerator.h"

#define TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@implementation IconGenerator

static NSMutableDictionary *dict = NULL;
static NSString *NOVOLTAGE = @"NOVOLTAGE";
static NSDictionary * DEFAULT_VOLTAGES = NULL;
static NSMutableDictionary *colours = NULL;


+ (NSDictionary *) voltageColours
{
    if (DEFAULT_VOLTAGES == NULL){
        DEFAULT_VOLTAGES = [[NSDictionary alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"DefaultVoltageColours.plist"]];
    }
    return DEFAULT_VOLTAGES;
}

+ (NSMutableDictionary * ) iconImages
{

    
    if(dict == NULL)
    {
        dict = [[NSMutableDictionary alloc] init];
    }
    return dict;
}

+(UIImage *) getIconOfWidth: (NSInteger) width 
                     height: (NSInteger) height 
                   voltages: (NSArray *) voltages{
    
    width *= 2.0;
    height *= 2.0;
    NSString * key;
    if (voltages == nil || [voltages count] == 0){
        key = NOVOLTAGE;
    }else{
        NSSortDescriptor *sorter = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
        NSArray *sorters = [[NSArray alloc] initWithObjects:sorter, nil];
        NSArray *sortedArray = [voltages sortedArrayUsingDescriptors:sorters];
        key = [NSString stringWithFormat:@"%@/%d/%d",[sortedArray description], width, height];
    }
    
    UIImage * icon = [self.iconImages objectForKey:key];
    if (icon != nil)
        return icon;
    
    NSMutableArray * colours = [[NSMutableArray alloc] init];
    if ([voltages count] == 0){
        UIColor * defaultColor = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
        [colours addObject:defaultColor];
    }else{    
        for (NSNumber * voltage in voltages){
            [colours addObject:[IconGenerator getVoltageColour:voltage]];
        }
    }

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);

    float arcSegment = 360 / [colours count];
    
    int start = 90;
    for (int i=0; i<[colours count]; i++){
        UIColor * colour = [colours objectAtIndex:i];
        CGContextSetFillColorWithColor(context, colour.CGColor);
        CGContextSetStrokeColorWithColor(context, colour.CGColor);        
        CGContextSetLineWidth(context, 2);
        CGContextMoveToPoint(context, width/2, height/2);
        CGContextAddArc(context, height/2, width/2, width/2, TO_RADIANS(start), TO_RADIANS(start+arcSegment), false);
        CGContextClosePath(context);
        CGContextFillPath(context);
        start += arcSegment;
    }

    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);        
    CGContextSetLineWidth(context, 1);
    CGContextAddEllipseInRect(context, CGRectMake(0, 0, width, height));
    CGContextStrokePath(context);
    
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    icon = [IconGenerator applyIconHighlightToImage: [UIImage imageWithCGImage:imageMasked scale:2.0 orientation:UIImageOrientationUp]];
    [self.iconImages setObject:icon forKey:key];
    
    //since we are using ARC and this is created not in ARC then we need to release it
    CGImageRelease(imageMasked);
    
    return icon;
}

NSInteger floatSort(id num1, id num2, void *context)
{
    float v1 = [num1 floatValue];
    float v2 = [num2 floatValue];
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

+ (UIColor *) getColourForComponents: (NSDictionary *) components{
    NSNumber * red = [components objectForKey:@"red"];
    NSNumber * green = [components objectForKey:@"green"];
    NSNumber * blue = [components objectForKey:@"blue"];
    NSNumber * alpha = [components objectForKey:@"alpha"];
    
    return [[UIColor alloc] initWithRed:[red floatValue] 
                                    green: [green floatValue]
                                     blue:[blue floatValue]
                                    alpha:[alpha floatValue]];
}

+ (UIColor *) getVoltageColour:(NSNumber*)voltage{
    if (colours == NULL){
        colours = [[NSMutableDictionary alloc] init];
    }
    
    UIColor * color = [colours objectForKey:voltage];
    if (color != nil)
        return color;
    NSDictionary * vColors = [IconGenerator voltageColours];
    NSDictionary * components = [vColors objectForKey:[voltage stringValue]];
    if (components!=nil){
        color = [IconGenerator getColourForComponents:components];
    }
    
    /* Interprolate */
    
    NSArray * sortedKeys = [[vColors allKeys] sortedArrayUsingFunction:floatSort context: NULL];
    
    NSNumber * upper = NULL;
    NSNumber * lower = NULL;
    
    float v = [voltage floatValue];
    for (NSString * vS in sortedKeys){
        float n = [vS floatValue];
        if (n > v){
            if (upper == NULL) upper = [[NSNumber alloc] initWithFloat:n];
            else{
                if ((n - v) < ([upper floatValue] - v))
                    upper = [[NSNumber alloc] initWithFloat:n];
                                                                
            }
        }else{
            if (lower == NULL) lower = [[NSNumber alloc] initWithFloat:n];
            else{
                if ((v-n)<(v - [lower floatValue]))
                    lower = [[NSNumber alloc] initWithFloat:n];
            }
        }
    }


    if (upper!=NULL || lower!=NULL){
        
        if (upper!=NULL ^ lower!=NULL){
            if (upper!=NULL){
                color = [colours objectForKey:upper];
                if (color == nil){
                    NSDictionary * components = [vColors objectForKey:[upper stringValue]];
                    color = [IconGenerator getColourForComponents: components];
                }
            }else{
                color = [colours objectForKey:lower];
                if (color == nil){
                    NSDictionary * components = [vColors objectForKey:[lower stringValue]];
                    color = [IconGenerator getColourForComponents: components];
                }
            }
        }else{
            NSDictionary * uComponents = [vColors objectForKey:[upper stringValue]];
            NSDictionary * lComponents = [vColors objectForKey:[lower stringValue]];
            
            float normVoltage = v-[lower floatValue];
            float normUpperVoltage = [upper floatValue]-[lower floatValue];
            
            float vPos = normVoltage/normUpperVoltage;
            
            float red = ([[uComponents objectForKey:@"red"] floatValue] - [[lComponents objectForKey:@"red"] floatValue]) * vPos + [[lComponents objectForKey:@"red"] floatValue];
            float green = ([[uComponents objectForKey:@"green"] floatValue] - [[lComponents objectForKey:@"green"] floatValue]) * vPos + [[lComponents objectForKey:@"green"] floatValue];
            float blue = ([[uComponents objectForKey:@"blue"] floatValue] - [[lComponents objectForKey:@"blue"] floatValue]) * vPos + [[lComponents objectForKey:@"blue"] floatValue];
            float alpha = ([[uComponents objectForKey:@"alpha"] floatValue] - [[lComponents objectForKey:@"alpha"] floatValue]) * vPos + [[lComponents objectForKey:@"alpha"] floatValue];            
            
            color = [[UIColor alloc] initWithRed:red 
                                   green:green
                                    blue:blue
                                   alpha:alpha];
        }
    }
        
    if (color == nil){
        color = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    }
    
    [colours setObject:color forKey:[voltage stringValue]];
    return color;
}



static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight) {
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0) {
        CGContextAddRect(context, rect);
        return;
    }
    CGContextSaveGState(context);
    CGContextTranslateCTM (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM (context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth (rect) / ovalWidth;
    fh = CGRectGetHeight (rect) / ovalHeight;
    CGContextMoveToPoint(context, fw, fh/2);
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

static void addGlossPath(CGContextRef context, CGRect rect) {
    CGFloat quarterHeight = CGRectGetMidY(rect) / 2;
    CGContextSaveGState(context);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, -1* rect.size.width, 0);
    
    CGContextAddLineToPoint(context, -1* rect.size.width, quarterHeight);
    CGContextAddQuadCurveToPoint(context, CGRectGetMidX(rect), quarterHeight * 3, CGRectGetMaxX(rect) + rect.size.width, quarterHeight);
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect) + rect.size.width, 0);
    
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}

+ (UIImage *) applyIconHighlightToImage: (UIImage *) icon{
    UIImage *newImage;
    CGContextRef context;
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    CGRect currentBounds = CGRectMake(0, 0, icon.size.width, icon.size.height);
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMidY(currentBounds));
    
    CGFloat locations[2] = {0.0, 1.0};
    CGFloat components[8] = {1.0, 1.0, 1.0, 0.75, 1.0, 1.0, 1.0, 0.2};
    
    UIGraphicsBeginImageContextWithOptions(icon.size, false, icon.scale);
    context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    addRoundedRectToPath(context, currentBounds, [icon size].width/2, [icon size].height/2);
    CGContextClosePath(context);
    CGContextClip(context);
    [icon drawInRect:currentBounds];
    
    addGlossPath(context, currentBounds);
    CGContextClip(context);
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, 2);
    CGColorSpaceRelease(rgbColorspace);
    
    CGContextDrawLinearGradient(context, glossGradient, topCenter, midCenter, 0);
    CGGradientRelease(glossGradient);

    UIGraphicsPopContext();
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
@end
