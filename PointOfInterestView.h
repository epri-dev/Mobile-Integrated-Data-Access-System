//
//  PointOfInterestView.h
//  StreetView
//
//  Created by Susan Rudd on 29/08/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointOfInterest.h"

#define box_width 250
#define box_height 130

@protocol OptionsForPOIDelegate;

@interface PointOfInterestView : UIView <UIGestureRecognizerDelegate> {
    PointOfInterest *poi;
    UIImageView *diagram;
    id<OptionsForPOIDelegate>__weak delegate;
}

@property (nonatomic, weak) id<OptionsForPOIDelegate> delegate;

- (id)initForPOI:(PointOfInterest *)newpoi;
- (CGSize)displayImageBasedOnDistancewithPoi:(PointOfInterest *)newpoi;
- (void)moveTitleandDescriptionForPoi:(PointOfInterest *)newpoi andImageSize:(CGSize)ImageSize;

@end
