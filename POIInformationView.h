//
//  POIInformationView.h
//  MIDAS
//
//  Created by Susan Rudd on 22/09/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointOfInterest.h"

@protocol OptionsForPOIDelegate;

@interface POIInformationView : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    PointOfInterest *poi;
    NSArray *listData;
    id<OptionsForPOIDelegate>__weak delegate;
}

- (id)initWithNibName:(NSString *)nibNameOrNil andPoi:(PointOfInterest *)newpoi;

@property (nonatomic, strong) NSArray *listData;

@property (nonatomic, weak) id<OptionsForPOIDelegate> delegate;

@end
