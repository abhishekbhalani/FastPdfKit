//
//  MagReaderViewController.m
//  MagTestApp
//
//  Created by Nicolò Tosi on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MagReaderViewController.h"

@interface MagReaderViewController ()

@end

@implementation MagReaderViewController

@synthesize dismissDelegate;

-(IBAction) actionDismiss:(id)sender {
	
    [super actionDismiss:sender];
    
    [dismissDelegate readerViewControllerDidDismiss:self];
}


@end
