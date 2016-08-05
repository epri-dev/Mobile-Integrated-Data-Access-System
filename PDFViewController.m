//
//  PDFViewController.m
//  MIDAS
//
//  Created by Susan Rudd on 03/04/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "PDFViewController.h"

@implementation PDFViewController
@synthesize webView;
@synthesize cancelLoad;

- (id)initWithNibName:(NSString *)nibNameOrNil andPoi:(PointOfInterest *)newpoi
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        poi = newpoi;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil andPoi:(PointOfInterest *)newpoi andTitle:(NSString *)pdfURLstring;
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self) {
        poi = newpoi;
        pdfstring = pdfURLstring;
    }
    
    return self;
}

- (IBAction)cancelButtonPressed {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed)];
        [self.navigationItem setRightBarButtonItem:cancel];
    }
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    
    MIDASAppDelegate *appDel = (MIDASAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDel.netStatus == NotReachable){
       UIAlertView *alert = [[UIAlertView alloc]
                 initWithTitle:[NSString stringWithFormat:@"Connection Error"]
                 message:@"You are not connected to the internet, the manual cannot be loaded."
                 delegate:self
                 cancelButtonTitle:@"OK"
                 otherButtonTitles:nil];
        alert.delegate = self;
        [alert show];
    }
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
    activityIndicator.center = self.view.center;
    
    cancelLoad = [[CustomButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, 40.0)];
    cancelLoad.center = self.view.center;
    [cancelLoad setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelLoad addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchDown];
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        CGRect frame = CGRectMake(0, 0, 120, 25);
        UILabel *label = [[UILabel alloc] initWithFrame:frame];
        label.font = [UIFont boldSystemFontOfSize:11.0];
        // Optional - label.text = @"NavLabel";
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        [label setText:pdfstring];
        [self.navigationItem setTitleView:label];
    }else{
        self.navigationItem.title =  pdfstring;
    }
    
    NSString *finalPath = [NSString stringWithFormat:@"https://cimphony.com/ex/ipadDocs/%@", pdfstring];
    NSURL *pdfURL = [NSURL URLWithString:finalPath];
    NSURLRequest *request = [NSURLRequest requestWithURL:pdfURL];
    [webView loadRequest:request];
    
    [self.view addSubview:webView];
    [self.view addSubview:cancelLoad];
    [self.view addSubview:activityIndicator];

}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [activityIndicator stopAnimating];
    [cancelLoad removeFromSuperview];
}


@end
