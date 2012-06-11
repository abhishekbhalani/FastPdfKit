//
//  FPKSynchronizerServer.h
//  CommunicatorServer
//
//  Created by Nicolò Tosi on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FPKSynchronizerServer;

@protocol FPKSynchronizerServerDelegate 

@optional

-(void)synchronizerServerDidStartListening:(FPKSynchronizerServer *)server port:(int)port;
-(void)synchronizerServerDidStopListening:(FPKSynchronizerServer *)server;
-(void)synchronizerServerDidSynchronizeItem:(NSUInteger)item totalCount:(NSUInteger)count;
-(void)synchronizerServerDidAcceptConnection:(FPKSynchronizerServer *)server;

-(void)synchronizerServer:(FPKSynchronizerServer *)server didStartSynchronzingFolder:(NSString *)folder path:(NSString *)path;
-(void)synchronizerServer:(FPKSynchronizerServer *)server didSynchronizeItem:(NSUInteger)item totalCount:(NSUInteger)count;

-(void)synchronizerServer:(FPKSynchronizerServer *)server didSucceedSynchronizingFolder:(NSString *)folder path:(NSString *)path;
-(void)synchronizerServer:(FPKSynchronizerServer *)server didReceiveHash:(NSUInteger)hash total:(NSUInteger)total;
-(BOOL)synchronizerServer:(FPKSynchronizerServer *)server shouldSynchronizeFolder:(NSString *)folder path:(NSString *)path;
-(void)synchronizerServer:(FPKSynchronizerServer *)server didTransferBytes:(NSUInteger)bytes total:(NSUInteger)total;

-(void)synchronizerServer:(FPKSynchronizerServer *)server didDeleteFolder:(NSString *)folderName;
-(void)synchronizerServer:(FPKSynchronizerServer *)server didFailToDeleteFolder:(NSString *)folderName;

-(void)synchronizerServerDidFail:(FPKSynchronizerServer *)server;

@end

@interface FPKSynchronizerServer : NSObject

-(void)start;
-(void)stop;
-(void)resume;
-(void)cancel;

@property (nonatomic,retain) NSString * rootPath;
@property (nonatomic, readwrite) BOOL showDeviceType;

@property(nonatomic,assign) NSObject<FPKSynchronizerServerDelegate> * delegate;
@property(nonatomic,readwrite) int port;

@property (nonatomic, copy) NSString * serviceName;
@property (readwrite,getter = isRunning) BOOL running;

-(id)initWithDirectoryAtPath:(NSString *)directory;

// Info

-(NSUInteger)numberOfFolderBeingSynchronized;
-(NSUInteger)numberOfFolders;

-(NSUInteger)indexOfFolderWithName:(NSString *)name;
-(NSArray *)folderNames;
-(NSString *)fullPathOfFolderWithName:(NSString *)name;
-(BOOL)isFolderBeingSynchronized:(NSString *)name;
-(void)deleteFolder:(NSString *)name;
@end
