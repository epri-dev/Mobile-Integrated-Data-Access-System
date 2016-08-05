//
//  LineView.h
//  StreetView
//
//  Created by Susan Rudd on 05/09/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Line.h"


@interface LineView : UIImageView {
    Line *line;
    NSMutableArray *pointsOnScreen;
    NSMutableArray *lines;
}

@property (nonatomic) NSMutableArray *pointsOnScreen;
@property (nonatomic) NSMutableArray *lines;

- (id)initWithFrame:(CGRect)frame forLine:(Line *)inputLine;
- (void)addPoints:(NSArray *)inpoints;
- (void)addLines:(NSArray *)allLines;
- (UIImage*)refresh;

@end
