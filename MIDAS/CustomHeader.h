//
//  CustomHeader.h
//  MIDAS
//
//  Created by Susan Rudd on 03/07/2012.
//  Adapted from Ray Wenderlich tutorials at www.raywenderlich.com
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomHeader : UIView{
    UILabel *_titleLabel;
    UIColor *_lightColor;
    UIColor *_darkColor;
    CGRect _coloredBoxRect;
    CGRect _paperRect;
}

@property (retain) UILabel *titleLabel;
@property (retain) UIColor *lightColor;
@property (retain) UIColor *darkColor;

@end
