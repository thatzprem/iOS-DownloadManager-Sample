//
//  FileDownloadManager.h
//  BackgroundFetchTest
//
//  Created by Prem kumar on 24/03/14.
//  Copyright (c) 2014 happiestminds. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileDownloadManager : NSObject<NSURLSessionDownloadDelegate>

@property (nonatomic,readwrite) BOOL copyDownloadedFilesToDD; //DD - Documents Directory
@property (nonatomic,readwrite) BOOL broadcastPendingDownloads; // Yes, to broadcast 'pending tasks count' for every task completion.

- (void)cancelDownload; // Cancel a download session - only available for download using block.
- (void)resumeDownload; // Resume a cancelled download - Only available for downloading using block.

- (void)downloadUsingDelegates:(NSArray *)downloadUrls; //Use when there are more than one URL to download.
- (void)downloadUsingBlock:(NSURL *)downloadURL; //Single URl to download large data.
- (void)broadcastPendingDownloadTasksCount; // Call this method to get notified on the no of tasks pending on the session queue

@end
