//
//  CustomHeader.m
//  MIDAS
//
//  Created by Susan Rudd on 03/07/2012.
//  Adapted from Ray Wenderlich tutorials at www.raywenderlich.com
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "CustomHeader.h"
#import "Common.h"

@implementation CustomHeader
@synthesize titleLabel = _titleLabel;
@synthesize lightColor = _lightColor;
@synthesize darkColor = _darkColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)init {
    if ((self = [super init])) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.opaque = NO;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.shadowColor = [UIColor lightGrayColor];
        _titleLabel.shadowOffset = CGSizeMake(0, -1);
        [self addSubview:_titleLabel];
        self.lightColor = [UIColor colorWithRed:105.0f/255.0f green:179.0f/255.0f blue:216.0f/255.0f alpha:1.0];
        self.darkColor = [UIColor colorWithRed:21.0/255.0 green:92.0/255.0 blue:136.0/255.0 alpha:1.0];        
    }
    return self;
}

-(void) layoutSubviews {
    
    CGFloat coloredBoxMargin = 6.0;
    CGFloat coloredBoxHeight = 40.0;
    _coloredBoxRect = CGRectMake(coloredBoxMargin, 
                                 coloredBoxMargin, 
                                 self.bounds.size.width-coloredBoxMargin*2, 
                                 coloredBoxHeight);
    
    CGFloat paperMargin = 9.0;
    _paperRect = CGRectMake(paperMargin, 
                            CGRectGetMaxY(_coloredBoxRect), 
                            self.bounds.size.width-paperMargin*2, 
                            self.bounds.size.height-CGRectGetMaxY(_coloredBoxRect));
    
    _titleLabel.frame = _coloredBoxRect;
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();    

    CGColorRef whiteColor = CGColorRetain([UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor);
    CGColorRef lightColor = CGColorRetain(_lightColor.CGColor);
    CGColorRef darkColor = CGColorRetain(_darkColor.CGColor);
    CGColorRef shadowColor = CGColorRetain([UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5].CGColor);
        
    // Draw paper
    CGContextSetFillColorWithColor(context, whiteColor);
    CGContextFillRect(context, _paperRect);

    // Draw shadow
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 2), 3.0, shadowColor);
    CGContextSetFillColorWithColor(context, lightColor);
    CGContextFillRect(context, _coloredBoxRect);
    CGContextRestoreGState(context);
    
    // Draw gloss and gradient
    drawGlossAndGradient(context, _coloredBoxRect, lightColor, darkColor);  

    // Draw stroke
    CGContextSetStrokeColorWithColor(context, darkColor);
    CGContextSetLineWidth(context, 1.0);    
    CGContextStrokeRect(context, rectFor1PxStroke(_coloredBoxRect));
    
    CGColorRelease (whiteColor);
    CGColorRelease (shadowColor);
    CGColorRelease (lightColor);
    CGColorRelease (darkColor);
    
}

- (void)dealloc
{
    _titleLabel = nil;
    _lightColor = nil;
    _darkColor = nil;
}

@end
