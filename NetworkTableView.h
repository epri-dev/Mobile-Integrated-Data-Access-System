//
//  NetworkTableView.h
//  MIDAS
//
//  Created by Susan Rudd on 18/01/2012.
//  Copyright (c) 2012 EPRI/Open Grid Systems Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Settings.h"

@protocol VCDelegate

- (void)displayNetwork:(NSArray *)chosenNetwork;
- (void)setJSON:(NSString *)jsonString;

@end

@interface NetworkTableView : UIViewController<UITableViewDelegate, UITableViewDataSource>{
    NSMutableArray *listData;
    UITableView *networkTableView;
    
    NSArray *row;
    
    NSString *networksURL;
    NSString *username;
    NSString *password;
    
    Settings *mySettings;
    id<VCDelegate> __weak delegate;
    
    IBOutlet UIActivityIndicatorView *chosenNetworkLoading;
    
    NSManagedObjectContext *managedObjectContext;

}

- (void)setUpPointsFromJSON;
- (void)performLibraryJSON:(NSString *)url;
- (void)setUpArray:(NSString *)responseString;
- (id)initWithURL:(NSString *)url;
- (id)initWithURL:(NSString *)url andUsername:(NSString *)user andPassword:(NSString *)pass;


@property (nonatomic) NSMutableArray *listData;
@property (nonatomic) IBOutlet UITableView *networkTableView;
@property (nonatomic) NSString* networksURL;

@property (nonatomic) NSString *username;
@property (nonatomic) NSString *password;
@property (nonatomic) NSArray *row;

@property (nonatomic, weak) id<VCDelegate>  delegate;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;


@end
