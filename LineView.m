//
//  LineView.m
//  StreetView
//
//  Created by Susan Rudd on 05/09/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "LineView.h"


@implementation LineView

@synthesize pointsOnScreen;
@synthesize lines;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        pointsOnScreen = [[NSMutableArray alloc] init];
        lines = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame forLine:(Line *)inputLine{
    self = [super initWithFrame:frame];
    if (self) {
        line = inputLine;
        pointsOnScreen = [[NSMutableArray alloc] init];
        lines = [[NSMutableArray alloc] init];
        
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)addPoints:(NSArray *)inpoints{
    pointsOnScreen = [[NSMutableArray alloc] init];
    
    for(NSValue *item in inpoints){
        [pointsOnScreen addObject:item];
    } 
}

- (void)addLines:(NSArray *)allLines{
    lines = [[NSMutableArray alloc] init];
    
    for(Line *l in allLines){
        [lines addObject:l];
    }
}


- (UIImage*) refresh{
    
    double width = 0;
    double height = 0;
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"])
    {
        width = 320.0;
        height = 460.0;
    }else{
        
        width = 768.0;
        height = 1024.0;
    }
    
    if(UIDeviceOrientationIsLandscape([[UIDevice currentDevice]orientation])){
        
        if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"])
        {
            height = 300.0;
            width = 480.0;
        }else{
            height = 768.0;
            width = 1024.0;
        }
        
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);

    CGContextSetLineWidth(ctx, 4);
    for(Line *l in lines){
        
        NSMutableArray *scaleArray = l.recursiveScale;
        
        CGColorRef colour =  [l.colour CGColor];
        
        CGContextSetStrokeColorWithColor(ctx, colour);
        
        int countPoints = [l.pointsOnScreen count];
        
        if(countPoints > 1){
            int i = 0;
            CGPoint lastPoint;
            float prevScale = -1;
            for(NSValue *item in l.pointsOnScreen){
                CGPoint p = [item CGPointValue];
                if (i!=0){
                    
                     float scaleBetweenPoints;
                     if ([[scaleArray objectAtIndex:i-1] floatValue] ==0)
                     scaleBetweenPoints = [[scaleArray objectAtIndex:i] floatValue];
                     else if ([[scaleArray objectAtIndex:i] floatValue] == 0)
                     scaleBetweenPoints = [[scaleArray objectAtIndex:i-1] floatValue];
                     else
                     scaleBetweenPoints = ([[scaleArray objectAtIndex:i-1] floatValue] + [[scaleArray objectAtIndex:i] floatValue])/2;
                     
                     if (prevScale == -1 || fabs(prevScale - scaleBetweenPoints) > 0.1){
                     if (i>1) CGContextStrokePath(ctx);
                     CGContextSetLineWidth(ctx, 4 * scaleBetweenPoints);
                     prevScale = scaleBetweenPoints;
                     }
                    
                    CGContextMoveToPoint (ctx, lastPoint.x, lastPoint.y);
                    CGContextAddLineToPoint (ctx, p.x, p.y);
                    CGContextStrokePath(ctx);
                }
                i++;
                lastPoint = p;
            }
            /*
             NSMutableArray* pointsToPlotArray = [[NSMutableArray alloc] init];
             
             for(NSValue *item in l.pointsOnScreen){
             CGPoint p = [item CGPointValue];
             [pointsToPlotArray addObject:[NSValue valueWithCGPoint:p]];
             }
             
             float prevScale = -1;
             for (int k = 0; k < countPoints-1; k++) {
             float scaleBetweenPoints;
             if ([[scaleArray objectAtIndex:k] doubleValue] ==0)
             scaleBetweenPoints = [[scaleArray objectAtIndex:k+1] doubleValue];
             else if ([[scaleArray objectAtIndex:k+1] doubleValue] == 0)
             scaleBetweenPoints = [[scaleArray objectAtIndex:k] doubleValue];
             else
             scaleBetweenPoints = ([[scaleArray objectAtIndex:k] doubleValue] + [[scaleArray objectAtIndex:k+1] doubleValue])/2;
             
             if (prevScale == -1 || fabs(prevScale - scaleBetweenPoints) > 0.1){
             CGContextStrokePath(ctx);
             CGContextSetLineWidth(ctx, 4 * scaleBetweenPoints);
             prevScale = scaleBetweenPoints;
             }
             
             CGContextMoveToPoint (ctx, [[pointsToPlotArray objectAtIndex:k] CGPointValue].x, [[pointsToPlotArray objectAtIndex:k] CGPointValue].y);
             CGContextAddLineToPoint (ctx, [[pointsToPlotArray objectAtIndex:k+1] CGPointValue].x, [[pointsToPlotArray objectAtIndex:k+1] CGPointValue].y);
             CGContextStrokePath(ctx);
             }
             
             pointsToPlotArray =s nil;
             */
        }
        
    }
    CGImageRef ref = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    UIImage* img = [UIImage imageWithCGImage: ref scale:1.0 orientation:UIImageOrientationDownMirrored];
    CGImageRelease(ref);
    return img;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*
- (void)drawRect:(CGRect)rect{
    
    double width = 0;
    double height = 0;
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"])
    {
        width = 320.0;
        height = 460.0;
    }else{
        
        width = 768.0;
        height = 1024.0;
    }
    
    if(UIDeviceOrientationIsLandscape([[UIDevice currentDevice]orientation])){
        
        if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"])
        {
            height = 300.0;
            width = 480.0;    
        }else{
            height = 768.0;
            width = 1024.0;    
        }
        
    }
    
    [self setFrame:CGRectMake(0, 0, width, height)];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 4);
    for(Line *l in lines){        
        
        NSMutableArray *scaleArray = l.recursiveScale;
        
        CGColorRef colour =  [l.colour CGColor];
        
        CGContextSetStrokeColorWithColor(ctx, colour);
        
        int countPoints = [l.pointsOnScreen count];
        
        if(countPoints > 1){
            int i = 0;
            CGPoint lastPoint;
            float prevScale = -1;
            for(NSValue *item in l.pointsOnScreen){
                CGPoint p = [item CGPointValue];
                if (i!=0){
                   /*
                    float scaleBetweenPoints;
                    if ([[scaleArray objectAtIndex:i-1] floatValue] ==0)
                        scaleBetweenPoints = [[scaleArray objectAtIndex:i] floatValue];
                    else if ([[scaleArray objectAtIndex:i] floatValue] == 0)
                        scaleBetweenPoints = [[scaleArray objectAtIndex:i-1] floatValue];
                    else
                        scaleBetweenPoints = ([[scaleArray objectAtIndex:i-1] floatValue] + [[scaleArray objectAtIndex:i] floatValue])/2;
                    
                    if (prevScale == -1 || fabs(prevScale - scaleBetweenPoints) > 0.1){
                        if (i>1) CGContextStrokePath(ctx);
                        CGContextSetLineWidth(ctx, 4 * scaleBetweenPoints);
                        prevScale = scaleBetweenPoints;
                    }
                    */
/*
                    CGContextMoveToPoint (ctx, lastPoint.x, lastPoint.y);
                    CGContextAddLineToPoint (ctx, p.x, p.y);
                    CGContextStrokePath(ctx);
                }
                i++;
                lastPoint = p;
            }
            /*
            NSMutableArray* pointsToPlotArray = [[NSMutableArray alloc] init];
            
            for(NSValue *item in l.pointsOnScreen){
                CGPoint p = [item CGPointValue];
                [pointsToPlotArray addObject:[NSValue valueWithCGPoint:p]];
            }
            
            float prevScale = -1;
            for (int k = 0; k < countPoints-1; k++) {
               float scaleBetweenPoints;
                if ([[scaleArray objectAtIndex:k] doubleValue] ==0)
                    scaleBetweenPoints = [[scaleArray objectAtIndex:k+1] doubleValue];
                else if ([[scaleArray objectAtIndex:k+1] doubleValue] == 0)
                    scaleBetweenPoints = [[scaleArray objectAtIndex:k] doubleValue];
                else
                    scaleBetweenPoints = ([[scaleArray objectAtIndex:k] doubleValue] + [[scaleArray objectAtIndex:k+1] doubleValue])/2;
                
                if (prevScale == -1 || fabs(prevScale - scaleBetweenPoints) > 0.1){
                    CGContextStrokePath(ctx);
                    CGContextSetLineWidth(ctx, 4 * scaleBetweenPoints);
                    prevScale = scaleBetweenPoints;
                }
                
                CGContextMoveToPoint (ctx, [[pointsToPlotArray objectAtIndex:k] CGPointValue].x, [[pointsToPlotArray objectAtIndex:k] CGPointValue].y);
                CGContextAddLineToPoint (ctx, [[pointsToPlotArray objectAtIndex:k+1] CGPointValue].x, [[pointsToPlotArray objectAtIndex:k+1] CGPointValue].y);
                CGContextStrokePath(ctx);
            }
            
            pointsToPlotArray = nil;
            */
/*
        }
        
    }
}
 */



@end
