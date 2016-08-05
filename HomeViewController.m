//
//  HomeViewController.m
//  MIDAS
//
//  Created by Susan Rudd on 20/09/2011.
//  Copyright 2011 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import "HomeViewController.h"
#import "Settings.h"
#import "NetworkDataInfo.h"
#import "ASIHTTPRequest.h"
#import "Asset.h"
#import "PositionPoint.h"

@implementation HomeViewController
@synthesize url;
@synthesize json;
@synthesize networkImage;
@synthesize networkTitle;
@synthesize networkDescription;
@synthesize serverURL;
@synthesize portraitView, landscapeView;
@synthesize networkImageLand, networkTitleLand, networkDescriptionLand, serverURLLand;
@synthesize managedObjectContext;
@synthesize selectNetwork;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //perhaps check device n set dimensions in settings?
    }
    
    return self;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == serverURL) {
        [textField resignFirstResponder];
    }else if (textField == serverURLLand) {
        [textField resignFirstResponder];
    }
    return NO;
}

-(IBAction)setServer:(id)sender{
    if(sender == applyServer){
        self.url = serverURL.text;
        [serverURL resignFirstResponder];
    }else if(sender == applyServerLand){
        self.url = serverURLLand.text;
        [serverURLLand resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    // Do any additional setup after loading the view from its nib.
    [super viewDidLoad];
    self.url = @"http://epri.opengrid.com/epri/";
    serverURL.text = self.url;
    serverURLLand.text = self.url;
    self.view.tag = 101;
    
    mySettings =  [Settings sharedInstance];

}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    serverURL.delegate = self;
    serverURLLand.delegate = self;
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    [loadingNetworks stopAnimating];
    [loadingNetworksLandscape stopAnimating];
}

- (void)displayNetwork:(NSArray*)chosenNetwork
{
    NSString * name = [chosenNetwork valueForKey:@"name"];
    NSString * description = [chosenNetwork valueForKey:@"description"];
    
    networkTitle.text = name;
    networkTitleLand.text = name;
    
    networkDescription.text = description;
    networkDescriptionLand.text = description;
    
    [self.networkDescription sizeToFit];
    [self.networkDescriptionLand sizeToFit];
    
    //image
    NSString * thumbnailHref;
    CGFloat scale = 1.0;
    //if([[mySettings device] hasPrefix:@"iPad3"] || [[mySettings device] hasPrefix:@"iPhone4"]){
        thumbnailHref = [chosenNetwork valueForKey:@"retinaIconHref"];
        scale = 2.0;
    /*}else{
        thumbnailHref = [chosenNetwork valueForKey:@"iconHref"];
    }
     */
    
    //do something with the imageURL
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: thumbnailHref]];
    //networkImage.image = [UIImage imageWithData: imageData];
    networkImage.image = [UIImage imageWithCGImage:[[UIImage imageWithData:imageData] CGImage] scale:scale orientation:UIImageOrientationUp];
    //networkImageLand.image = [UIImage imageWithData: imageData];
    networkImageLand.image = [UIImage imageWithCGImage:[[UIImage imageWithData:imageData] CGImage] scale:scale orientation:UIImageOrientationUp];
    
    // Create and configure a new instance of the Event entity.
    //only store if it doesnt already exist
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"NetworkDataInfo" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set predicate and sort orderings...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name == %@)", name];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    if (array == nil){
        NSLog(@"%@", error);
    }else if([array count] == 0){
        NetworkDataInfo *networkinfo = (NetworkDataInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"NetworkDataInfo" inManagedObjectContext:managedObjectContext];
        
        [networkinfo setName:name];
        [networkinfo setNetworkDescription:description];
        [networkinfo setThumbnail:[UIImage imageWithCGImage:[[UIImage imageWithData:[[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [chosenNetwork valueForKey:@"thumbnailHref"]]]] CGImage] scale:1.0 orientation:UIImageOrientationUp]];
        [networkinfo setRetinalThumbnail:[UIImage imageWithCGImage:[[UIImage imageWithData:[[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [chosenNetwork valueForKey:@"retinaThumbnailHref"]]]] CGImage] scale:2.0 orientation:UIImageOrientationUp]];
        [networkinfo setIcon:[UIImage imageWithCGImage:[[UIImage imageWithData:[[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [chosenNetwork valueForKey:@"iconHref"]]]] CGImage] scale:1.0 orientation:UIImageOrientationUp]]; 
        [networkinfo setRetinaIcon:[UIImage imageWithCGImage:[[UIImage imageWithData:[[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: [chosenNetwork valueForKey:@"retinaIconHref"]]]] CGImage] scale:2.0 orientation:UIImageOrientationUp]];
        [networkinfo setWorkManagerHref:[chosenNetwork valueForKey:@"workManagerHref"]];
        [networkinfo setJson:json];
        NSError *error = nil;
        if (![managedObjectContext save:&error]) {
            NSLog(@"%@", error);
        }
        
    }
   
}

- (void)setJSON:(NSString *)jsonString{
    json = [[NSString alloc] initWithFormat:@"%@", jsonString];    
}

- (void)displayNetworkInfo:(NetworkDataInfo *)chosenNetwork{
    networkTitle.text = [chosenNetwork name];
    networkTitleLand.text = [chosenNetwork name];
    
    networkDescription.text = [chosenNetwork networkDescription];
    networkDescriptionLand.text = [chosenNetwork networkDescription];
    
    [self.networkDescription sizeToFit];
    [self.networkDescriptionLand sizeToFit];
    
    if([[mySettings device] hasPrefix:@"iPad3"] || [[mySettings device] hasPrefix:@"iPhone4"]){
        networkImage.image = [chosenNetwork retinaIcon];
        networkImageLand.image  = [chosenNetwork retinaIcon];
    }else{
        networkImage.image = [chosenNetwork icon];
        networkImageLand.image = [chosenNetwork icon];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        
        if(UIDeviceOrientationIsLandscape(toInterfaceOrientation)){
            self.view = self.landscapeView;
            serverURLLand.text = self.url;
        }else{
            self.view = self.portraitView;
            serverURL.text = self.url;
        }
        
    }
}

- (void)displayAlertForUsernameAndPassword{
    //slight cheat at the moment but we will eventual all have authentication
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server Authentication" 
                                                        message:nil  
                                                       delegate:self 
                                              cancelButtonTitle:@"Cancel" 
                                              otherButtonTitles:@"Done", nil];
        // 6
        [alert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
        UITextField *nameField = [alert textFieldAtIndex:0];
        nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        nameField.placeholder = @"User Name"; // Replace the standard placeholder text with something more applicable
        [alert show];        
}
 
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
    if(buttonIndex == 1){
        NSString *username = [[alertView textFieldAtIndex:0]text];
        NSString *password = [[alertView textFieldAtIndex:1] text];
        nextView = [[NetworkTableView alloc] initWithURL:self.url andUsername:username andPassword:password];
        nextView.delegate = self;
        nextView.managedObjectContext = self.managedObjectContext;
        [self.navigationController pushViewController:nextView animated:YES ];
    }
}
- (void)setUpNetworks{
    NSURL *urlForData = [NSURL URLWithString:url];
    __weak ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:urlForData];
    [request startSynchronous];
    
    int statusCode = [request responseStatusCode];
    
    if(statusCode == 401){
        [self displayAlertForUsernameAndPassword];
    }else{
        nextView = [[NetworkTableView alloc] initWithURL:self.url];
        nextView.delegate = self;
        nextView.managedObjectContext = self.managedObjectContext;
        [self.navigationController pushViewController:nextView animated:YES ];
    }
}

- (IBAction)selectNetwork:(id)sender{
    
    [loadingNetworks startAnimating];
    [loadingNetworksLandscape startAnimating];
    
    [self performSelector:@selector(setUpNetworks) withObject:nil afterDelay:.06];
        
}


- (IBAction)selectStoredNetwork:(id)sender{
    [loadingNetworks startAnimating];
    [loadingNetworksLandscape startAnimating];

    coreDataView = [[CoreDataInfoViewController alloc] initWithNibName:@"CoreDataInfoViewController" bundle:nil];
    coreDataView.managedObjectContext = self.managedObjectContext;
    coreDataView.delegate = self;
    [self.navigationController pushViewController:coreDataView animated:YES ];
}

//depricated in ios6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
    }
	return YES;
}

//for rotation in ios6
-(NSUInteger)supportedInterfaceOrientations{
    if([[[UIDevice currentDevice] model] hasPrefix:@"iPhone"]){
        return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
    }
    
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
    return YES;
}

@end
