//
//  PDFViewController.h
//  MIDAS
//
//  Created by Susan Rudd on 03/04/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PointOfInterest.h"
#import "POIInformationView.h"
#import "CustomButton.h"
#import "MIDASAppDelegate.h"

@interface PDFViewController : UIViewController<UIAlertViewDelegate>{
    UIWebView *webView;
    PointOfInterest *poi;
    NSString *pdfstring;
    
    UIActivityIndicatorView *activityIndicator;
    CGRect incomingFrame;
}

@property (nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) CustomButton *cancelLoad;

- (id)initWithNibName:(NSString *)nibNameOrNil andPoi:(PointOfInterest *)newpoi;
- (id)initWithNibName:(NSString *)nibNameOrNil andPoi:(PointOfInterest *)newpoi andTitle:(NSString *)pdfURLstring;

@end
