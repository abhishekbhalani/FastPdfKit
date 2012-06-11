//
//  ViewController.h
//  MagTestApp
//
//  Created by Nicolò Tosi on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPKSynchronizerServer.h"
#import <FastPdfKit/MFDocumentViewControllerDelegate.h>

@interface MagViewController : UIViewController <FPKSynchronizerServerDelegate, MFDocumentViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

-(IBAction)actionStartStop:(id)sender;
-(IBAction)actionOpenLast:(id)sender;

@property (nonatomic,strong) IBOutlet UIActivityIndicatorView * activityIndicatorView;
@property (nonatomic,strong) IBOutlet UIButton * startStopButton;
@property (nonatomic,strong) IBOutlet UILabel * serverStatusLabel;

@property (nonatomic,retain) IBOutlet UITableView * tableView;
@property (nonatomic,retain) NSArray * trackedFolders;

@end
