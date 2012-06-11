//
//  ViewController.m
//  MagTestApp
//
//  Created by Nicolò Tosi on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MagViewController.h"
#import <FastPdfKit/ReaderViewController.h>
#import "FPKSynchronizerServer.h"
#import <FastPdfKit/MFDocumentManager.h>
#import "OverlayManager.h"
#import "MagReaderViewController.h"
#import <FastPdfKit/MFDocumentViewController.h>

@interface MagViewController ()

@property (nonatomic, strong) FPKSynchronizerServer * synchronizerServer;
@property (nonatomic, copy) NSString * folderBeingSynchronzed;
@property (nonatomic, copy) NSString * currentlyOpenFolder;

@property (nonatomic, readwrite) BOOL isDocumentOpen;
@property (nonatomic, readwrite) BOOL isSynchronizing;
@property (nonatomic, readwrite) BOOL isListening;
@property (nonatomic, readwrite) BOOL isWaitingForDocumentToClose;

@property (nonatomic, copy) NSString * lastOpenDocument;
@property (nonatomic, strong) ReaderViewController * readerViewController;
@end

@implementation MagViewController

@synthesize startStopButton;
@synthesize synchronizerServer;
@synthesize folderBeingSynchronzed, currentlyOpenFolder;
@synthesize isDocumentOpen, isSynchronizing;
@synthesize isListening;
@synthesize activityIndicatorView;
@synthesize serverStatusLabel;
@synthesize isWaitingForDocumentToClose;
@synthesize readerViewController;
@synthesize tableView;
@synthesize lastOpenDocument;
@synthesize trackedFolders;

#pragma mark - UITableViewDelegate & DataSource

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString * name = [self.trackedFolders objectAtIndex:indexPath.row];
    
    if([self.synchronizerServer isFolderBeingSynchronized:name]) {
        
        return;
        
    } else {
        
        [self openDocument:name];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.trackedFolders count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * cellId = @"MagTestAppCell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if(!cell) {
        
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId]autorelease];
        cell.backgroundColor = [UIColor darkGrayColor];
    }
 
    if([self.synchronizerServer isFolderBeingSynchronized:[self.trackedFolders objectAtIndex:indexPath.row]]) {
        
        cell.textLabel.textColor = [UIColor lightGrayColor];
        
    } else {
        
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    
    cell.textLabel.text = [self.trackedFolders objectAtIndex:indexPath.row];
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    if([self.synchronizerServer isFolderBeingSynchronized:[self.trackedFolders objectAtIndex:indexPath.row]]) {
        return UITableViewCellEditingStyleNone;
    }
    
    return UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSString * name = [self.trackedFolders objectAtIndex:indexPath.row];
     
        [self.synchronizerServer deleteFolder:name];
        
    }
}


#pragma mark -

-(void)updateFolders {
    
    NSArray * folders = [self.synchronizerServer folderNames];
    
    self.trackedFolders = [folders sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    [self.tableView reloadData];
}

-(void)updateFolder:(NSString *)folder {
    
    // Beware that -indexOfObject: on a nil array will always return 0
    // rathern than NSNotFound, even if the object is not in the array!
    
    NSUInteger index = [self.trackedFolders indexOfObject:folder];
    
    NSLog(@"%d of %d", index, [self.trackedFolders count]);
    
    if(index!=NSNotFound) {
        
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
        

-(void)updateServerStatusLabel {
    
    if(isSynchronizing) {
        
        self.startStopButton.enabled = NO;
        self.serverStatusLabel.text = @"synching";
    
    } else if(isListening) {
        self.startStopButton.enabled = YES;
        [self.startStopButton setTitle:@"Stop" forState:UIControlStateNormal];
        self.serverStatusLabel.text = @"listening";
        
    } else {
        
        self.startStopButton.enabled = YES;
        [self.startStopButton setTitle:@"Start" forState:UIControlStateNormal];
        self.serverStatusLabel.text = @"stopped";
    }
}

-(void)openDocument:(NSString *)name {
    
    NSString * folder = [[MagViewController resourceRootFolder]stringByAppendingPathComponent:name];
    
    if(folder) {
        
        NSString * pdfDocumentPath = [MagViewController pathOfPDFInFolder:folder];
        
        if(pdfDocumentPath) {
            
            NSURL * url = nil;
            
            MFDocumentManager * manager = nil;
            MagReaderViewController * controller = nil;
            OverlayManager * overlay = nil;
            
            isDocumentOpen = YES;
            self.lastOpenDocument = name;
            
            url = [NSURL fileURLWithPath:pdfDocumentPath];
            
            manager = [[MFDocumentManager alloc]initWithFileUrl:url];
            manager.resourceFolder = folder;
            
            controller = [[MagReaderViewController alloc]initWithDocumentManager:manager];
            controller.documentId = name;
            
            self.readerViewController = controller;
            
            overlay = [[OverlayManager alloc]init];
            
            [controller addOverlayViewDataSource:overlay];
            [controller addDocumentDelegate:overlay];
            
            // [overlay setDocumentViewController:(MFDocumentViewController<FPKOverlayManagerDelegate> *)controller];
            
            [overlay setGlobalParametersFromAnnotation];

            [self presentModalViewController:controller animated:NO];
            
            [overlay release];
            [controller release];
            [manager release];
        }
    }
}

-(void)openLastSynchronizedDocument {

    if(self.lastOpenDocument) {
        
        [self openDocument:self.lastOpenDocument];
    }
}

-(void)closeOpenDocumentIfNecessary {
    
    if(isDocumentOpen) {
        self.isDocumentOpen = NO;
        [self.navigationController popToViewController:self animated:YES];
    }
}

+(NSString *)resourceRootFolder {
    
    static NSString * folder = nil;
    
    if(!folder) {
        
        folder = [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Synchronizer"]copy];
        
        NSFileManager * fileManager = [NSFileManager defaultManager];
        BOOL isDir = NO;
        
        if(![fileManager fileExistsAtPath:folder isDirectory:&isDir]) {
            if([fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:NULL]) {
                
            }
        }
    }
    
    return folder;
}

+(NSString *)pathOfPDFInFolder:(NSString *)folderPath {
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSArray * subPaths = [fileManager subpathsAtPath:folderPath];
    
    for(NSString * subPath in subPaths) {
        
        if([[subPath pathExtension]compare:@"pdf" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            return [folderPath stringByAppendingPathComponent:subPath];
        }
    }
    
    return nil;
}

-(void)resumeSync {
    
    [self.synchronizerServer resume];
}

-(void)readerViewControllerDidDismiss:(MagReaderViewController *)controller {
    
    isDocumentOpen = NO;
    
    if(self.isWaitingForDocumentToClose) {
        
        self.isWaitingForDocumentToClose = NO;
        
        [self.synchronizerServer resume];
    }
}

-(BOOL)synchronizerServer:(FPKSynchronizerServer *)server shouldSynchronizeFolder:(NSString *)folder path:(NSString *)path {

    if([folder isEqualToString:self.lastOpenDocument] && isDocumentOpen) {
        
        self.isWaitingForDocumentToClose = YES;
        
        return NO;
    }
    
    return YES;
}

-(void)synchronizerServer:(FPKSynchronizerServer *)server didDeleteFolder:(NSString *)folderName {
    
    // TODO: alternatively, remove only the cell for the name
    
    [self updateFolders];
}

-(void)synchronizerServerDidStartListening:(FPKSynchronizerServer *)server port:(int)port {
    
    self.isListening = YES;
    [self updateServerStatusLabel];
    [self updateFolders];
}

-(void)synchronizerServerDidStopListening:(FPKSynchronizerServer *)server {
    
    self.isListening = NO;
    [self updateServerStatusLabel];
    [self updateFolders];
}

-(void)synchronizerServerDidFail:(FPKSynchronizerServer *)server {
    
    self.isSynchronizing = NO;
    self.isWaitingForDocumentToClose = NO;
    self.folderBeingSynchronzed = nil;
    
    [self.activityIndicatorView stopAnimating];
    [self updateServerStatusLabel];
    [self updateFolders];
}

-(void)synchronizerServerDidAcceptConnection:(FPKSynchronizerServer *)server {
    
    self.isSynchronizing = YES;
    
    [self.activityIndicatorView startAnimating];
    [self updateFolders];
}

-(void)synchronizerServer:(FPKSynchronizerServer *)server didSynchronizeItem:(NSUInteger)item totalCount:(NSUInteger)count {
    
    // Update...
    
}

-(void)synchronizerServer:(FPKSynchronizerServer *)server didSucceedSynchronizingFolder:(NSString *)folder path:(NSString *)path {
    
    self.isSynchronizing = NO;
    self.isWaitingForDocumentToClose = NO;
    [self.activityIndicatorView stopAnimating];
    [self openLastSynchronizedDocument];
    [self updateServerStatusLabel];
    [self updateFolders];
}

-(void)synchronizerServer:(FPKSynchronizerServer *)server didStartSynchronzingFolder:(NSString *)folder path:(NSString *)path {
    
    [self updateFolders];
    //[self updateFolder:folder];
}

-(BOOL)synchronizerServer:(FPKSynchronizerServer *)server shouldProceedSynchronzingFolder:(NSString *)folder path:(NSString *)path {
    
    if(isDocumentOpen) {
        
        self.isWaitingForDocumentToClose = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self closeOpenDocumentIfNecessary];
        });
        
        return NO;
    }
    
    return YES;
}

-(void)dosomething {
    return;
}

-(IBAction)actionStartStop:(id)sender {
    
    // Allocate the server if hasn't been already done
    
    if(!self.synchronizerServer) {
        
        FPKSynchronizerServer * server = [[FPKSynchronizerServer alloc]initWithDirectoryAtPath:[MagViewController resourceRootFolder]];
        server.showDeviceType = YES;
        server.port = 10000;
        server.delegate = self;
        
        self.synchronizerServer = server;
        
        [server release];
    }
    
    // Start or stop upon server status
    
    if(!self.synchronizerServer.isRunning) {
        
        [self.synchronizerServer start];
        
    } else {
     
        [self.synchronizerServer stop];
    }
}

-(void)actionOpenLast:(id)sender {
    
    if(!(isSynchronizing||isDocumentOpen)) {
        [self openLastSynchronizedDocument];
    }
}

-(void)dealloc {

    [synchronizerServer startStop];
    
    [synchronizerServer release];
    
    [startStopButton release];
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        [self actionStartStop:startStopButton];
    }
    return self;
}

//- (void)loadView
//{
//    // If you create your views manually, you MUST override this method and use it to create your views.
//    // If you use Interface Builder to create your views, then you must NOT override this method.
//}


-(void)viewDidAppear:(BOOL)animated {
    
    self.isDocumentOpen = NO;
    
    if(self.isWaitingForDocumentToClose) {
        [self.synchronizerServer proceed];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    
    self.isDocumentOpen = YES;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self updateServerStatusLabel];
    [self updateFolders];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    self.tableView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
