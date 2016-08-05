//
//  CustomButton.m
//  MIDAS
//
//  Created by Susan Rudd on 03/07/2012.
//  Adapted from Ray Wenderlich at Raywenderlich.com
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "CustomButton.h"
#import "Common.h"

#define _hue 0.586957
#define _saturation 0.060386
#define _brightness 0.842995

@implementation CustomButton

-(id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat actualBrightness = _brightness;
    if (self.state == UIControlStateHighlighted) {
        actualBrightness -= 0.10;
    }   
    
    CGColorRef blackColor = CGColorRetain([UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor);
    CGColorRef highlightStart = CGColorRetain([UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.4].CGColor);
    CGColorRef highlightStop = CGColorRetain([UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1].CGColor);
    CGColorRef shadowColor = CGColorRetain([UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5].CGColor);
    
    CGColorRef outerTop = CGColorRetain([UIColor colorWithHue:_hue saturation:_saturation brightness:1.0*actualBrightness alpha:1.0].CGColor);
    CGColorRef outerBottom = CGColorRetain([UIColor colorWithHue:_hue saturation:_saturation brightness:0.80*actualBrightness alpha:1.0].CGColor);
    CGColorRef innerStroke = CGColorRetain([UIColor colorWithHue:_hue saturation:_saturation brightness:0.80*actualBrightness alpha:1.0].CGColor);
    CGColorRef innerTop = CGColorRetain([UIColor colorWithHue:_hue saturation:_saturation brightness:0.90*actualBrightness alpha:1.0].CGColor);
    CGColorRef innerBottom = CGColorRetain([UIColor colorWithHue:_hue saturation:_saturation brightness:0.70*actualBrightness alpha:1.0].CGColor);
    
    CGFloat outerMargin = 5.0f;
    CGRect outerRect = CGRectInset(self.bounds, outerMargin, outerMargin);            
    CGMutablePathRef outerPath = createRoundedRectForRect(outerRect, 10.0);
    
    CGFloat innerMargin = 3.0f;
    CGRect innerRect = CGRectInset(outerRect, innerMargin, innerMargin);
    CGMutablePathRef innerPath = createRoundedRectForRect(innerRect, 10.0);
    
    CGFloat highlightMargin = 2.0f;
    CGRect highlightRect = CGRectInset(outerRect, highlightMargin, highlightMargin);
    CGMutablePathRef highlightPath = createRoundedRectForRect(highlightRect, 10.0);
    
    // Draw shadow
    if (self.state != UIControlStateHighlighted) {
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, outerTop);
        CGContextSetShadowWithColor(context, CGSizeMake(0, 2), 3.0, shadowColor);
        CGContextAddPath(context, outerPath);
        CGContextFillPath(context);
        CGContextRestoreGState(context);
    }
    
    // Draw gradient for outer path
    CGContextSaveGState(context);
    CGContextAddPath(context, outerPath);
    CGContextClip(context);
    drawGlossAndGradient(context, outerRect, outerTop, outerBottom);
    CGContextRestoreGState(context);
    
    // Draw gradient for inner path
    CGContextSaveGState(context);
    CGContextAddPath(context, innerPath);
    CGContextClip(context);
    drawGlossAndGradient(context, innerRect, innerTop, innerBottom);
    CGContextRestoreGState(context);      
    
    // Draw highlight (if not selected)
    if (self.state != UIControlStateHighlighted) {
        CGContextSaveGState(context);
        CGContextSetLineWidth(context, 4.0);
        CGContextAddPath(context, outerPath);
        CGContextAddPath(context, highlightPath);
        CGContextEOClip(context);
        drawLinearGradient(context, outerRect, highlightStart, highlightStop);
        CGContextRestoreGState(context);
    }
    
    // Stroke outer path
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, blackColor);
    CGContextAddPath(context, outerPath);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
    
    // Stroke inner path
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, innerStroke);
    CGContextAddPath(context, innerPath);
    CGContextClip(context);
    CGContextAddPath(context, innerPath);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);    
    
    CFRelease(outerPath);
    CFRelease(innerPath);
    CFRelease(highlightPath);
    
    CGColorRelease(blackColor);
    CGColorRelease(highlightStart);
    CGColorRelease(highlightStop);
    CGColorRelease(shadowColor);
    CGColorRelease(outerTop);
    CGColorRelease(outerBottom);
    CGColorRelease(innerStroke);
    CGColorRelease(innerTop);
    CGColorRelease(innerBottom);
    
}

@end
