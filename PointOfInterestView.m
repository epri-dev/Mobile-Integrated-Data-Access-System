//
//  PointOfInterestView.m
//  StreetView
//
//  Created by Susan Rudd on 29/08/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "PointOfInterestView.h"
#import "POIInformationView.h"
#import "IconGenerator.h"
#import "StreetViewViewController.h"

@implementation PointOfInterestView
@synthesize delegate;

- (id)initForPOI:(PointOfInterest *)newpoi{
    //this is where we set up the view for a point of interests
    poi = newpoi;
    
    int innerBoxHeight = 18;
    
    CGRect theFrame = CGRectMake(0.0, 0.0, box_width, box_height);
    if ((self = [super initWithFrame:theFrame])) {
        
        UIImageView *marker	= [[UIImageView alloc] initWithFrame:CGRectZero];
        marker.tag = 1;
        UIImage *icon = [UIImage imageNamed:@"POI72Outline@2x.png"];
        
        if ([[newpoi title] isEqualToString:@"Substation"]){
            
            UIImage *overlay = [UIImage imageNamed:@"Substation@2x.png"];
            CGRect iconBoundingBox = CGRectMake (0, 0, icon.size.width, icon.size.height);
            CGRect overlayBoundingBox = CGRectMake (0,0,//icon.size.width-(overlay.size.width+8), 0,
                                                    overlay.size.width, overlay.size.height);
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGContextRef myBitmapContext = CGBitmapContextCreate(NULL, icon.size.width, icon.size.height, 8, 4 * icon.size.width, colorSpace, kCGImageAlphaPremultipliedFirst);
            CGColorSpaceRelease(colorSpace);
            
            CGContextDrawImage(myBitmapContext, iconBoundingBox, icon.CGImage);
            CGContextDrawImage(myBitmapContext, overlayBoundingBox, overlay.CGImage);
            
            CGImageRef image = CGBitmapContextCreateImage (myBitmapContext);
            CGContextRelease (myBitmapContext);
            
            icon = [UIImage imageWithCGImage: image scale:2.0 orientation:UIImageOrientationUp];
            CGImageRelease(image);
        }
        
        if ([[newpoi voltageLevels] count] >0){
            int size = 16;
            //if ([[newpoi voltageLevels] count]> 1)
            //    size =24;
            UIImage *overlay = [IconGenerator getIconOfWidth:size height:size voltages:[newpoi voltageLevels]];
            CGRect iconBoundingBox = CGRectMake (0, 0, icon.size.width*2, icon.size.height*2);
            CGRect overlayBoundingBox = CGRectMake (size*2,0,//icon.size.width-overlay.size.width, 0,
                                                    overlay.size.width*2, overlay.size.height*2);
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGContextRef myBitmapContext = CGBitmapContextCreate(NULL, icon.size.width*2, icon.size.height*2, 8, 4 * icon.size.width*2, colorSpace, kCGImageAlphaPremultipliedFirst);
            CGColorSpaceRelease(colorSpace);
            
            CGContextDrawImage(myBitmapContext, iconBoundingBox, icon.CGImage);
            CGContextDrawImage(myBitmapContext, overlayBoundingBox, overlay.CGImage);
            
            CGImageRef image = CGBitmapContextCreateImage (myBitmapContext);
            CGContextRelease (myBitmapContext);
            
            icon = [UIImage imageWithCGImage: image scale:2.0 orientation:UIImageOrientationUp];
            CGImageRelease(image);
            
        }
        
        [marker setImage: icon];
        
        int imageWidth = [marker image].size.width;
        int imageHeight = [marker image].size.height;
        
        [marker setFrame:CGRectMake(-(imageWidth/2), 0, imageWidth, imageHeight)];
        
        [self addSubview:marker];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((imageWidth/2), 8, box_width, innerBoxHeight)];
        [title setBackgroundColor:[UIColor clearColor]];
        [title setTextColor:[UIColor colorWithRed:0.8 green:0.9 blue:1.0 alpha:1.0]];
        [title setTextAlignment:UITextAlignmentLeft];
        [title setText: newpoi.title];
        title.font = [UIFont fontWithName:@"Helvetica" size: 16.0]; // Sans-Serif font I think :-)
        title.tag = 2;
        
        [self addSubview:title];
        
        UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake((imageWidth/2), 8 + innerBoxHeight, box_width, innerBoxHeight)];
        [description setBackgroundColor:[UIColor clearColor]];
        [description setTextColor:[UIColor colorWithRed:0.9 green:0.8 blue:1.0 alpha:1.0]];
        [description setTextAlignment:UITextAlignmentLeft];
        [description setText: newpoi.name];
        description.font = [UIFont fontWithName:@"Helvetica" size: 12.0];
        description.tag = 3;
        
        [self addSubview:description];
        
        [self setUserInteractionEnabled:YES];
        
        UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapgr];
        
    }
    
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (void)tapEnded:(UITapGestureRecognizer *)gesture{
    if(diagram !=nil ){
        [diagram removeFromSuperview];
        UITapGestureRecognizer *tapgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [self addGestureRecognizer:tapgr];
    }
}

- (void)tap:(UITapGestureRecognizer *)gesture{
    diagram = [[UIImageView alloc] initWithFrame:CGRectZero];
    [delegate popUpOtionsForPOI:poi];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (CGSize)displayImageBasedOnDistancewithPoi:(PointOfInterest *)newpoi{\
    CGSize size;
    for(UIView *view in self.subviews){
        if(view.tag == 1){
            [view removeFromSuperview];
            UIImageView *marker	= [[UIImageView alloc] initWithFrame:CGRectZero];
            marker.tag = 1;
            UIImage *icon = [UIImage imageNamed:@"Substation@2x.png"];
            
            
            if ([[newpoi title] isEqualToString:@"Substation"]){
                
                CGRect iconBoundingBox = CGRectMake (0, 0, icon.size.width, icon.size.height);
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                CGContextRef myBitmapContext = CGBitmapContextCreate(NULL,(icon.size.width + 20), icon.size.height, 8, 4 * (icon.size.width + 20), colorSpace, kCGImageAlphaPremultipliedFirst);
                CGColorSpaceRelease(colorSpace);
                
                CGContextDrawImage(myBitmapContext, iconBoundingBox, icon.CGImage);
                
                CGImageRef image = CGBitmapContextCreateImage (myBitmapContext);
                CGContextRelease (myBitmapContext);
                
                icon = [UIImage imageWithCGImage: image scale:2.0 orientation:UIImageOrientationUp];
                CGImageRelease(image);
                
            }
            
            if ([[newpoi voltageLevels] count] >0){
                int oSize = 16;
                //if ([[newpoi voltageLevels] count]> 1)
                //    size =24;
                UIImage *overlay = [IconGenerator getIconOfWidth:oSize height:oSize voltages:[newpoi voltageLevels]];
                CGRect iconBoundingBox = CGRectMake (0, 0, icon.size.width*2, icon.size.height*2);
                CGRect overlayBoundingBox = CGRectMake (oSize*2,0,//icon.size.width-overlay.size.width, 0,
                                                        overlay.size.width*2, overlay.size.height*2);
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                CGContextRef myBitmapContext = CGBitmapContextCreate(NULL, icon.size.width*2, icon.size.height*2, 8, 4 * icon.size.width*2, colorSpace, kCGImageAlphaPremultipliedFirst);
                CGColorSpaceRelease(colorSpace);
                
                CGContextDrawImage(myBitmapContext, iconBoundingBox, icon.CGImage);
                CGContextDrawImage(myBitmapContext, overlayBoundingBox, overlay.CGImage);
                
                CGImageRef image = CGBitmapContextCreateImage (myBitmapContext);
                CGContextRelease (myBitmapContext);
                
                icon = [UIImage imageWithCGImage: image scale:2.0 orientation:UIImageOrientationUp];
                CGImageRelease(image);
            }
            [marker setImage:	icon];
            
            int imageWidth = [marker image].size.width;
            int imageHeight = [marker image].size.height;
            
            [marker setFrame:CGRectMake(-(imageWidth/2), 0, imageWidth, imageHeight)];
            size = [[marker image] size];
            [self addSubview:marker];
            
        }
    }
    
    return size;
}

- (void)moveTitleandDescriptionForPoi:(PointOfInterest *)newpoi andImageSize:(CGSize)ImageSize{
    
    int imageWidth = ImageSize.width;
    int innerBoxHeight = 18;
    
    for(UIView *view in self.subviews){
        if(view.tag == 2){
            view.frame = CGRectMake((imageWidth/2), 8, box_width, innerBoxHeight);
        }else if(view.tag == 3){
            view.frame = CGRectMake((imageWidth/2), 8 + innerBoxHeight, box_width, innerBoxHeight);
        }
    }
    
}


@end
