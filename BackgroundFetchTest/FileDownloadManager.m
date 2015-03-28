//
//  FileDownloadManager.m
//  BackgroundFetchTest
//
//  Created by Prem kumar on 24/03/14.
//  Copyright (c) 2014 happiestminds. All rights reserved.
//

#import "FileDownloadManager.h"
#import "DownloadCompleteNotification.h"
#import "Utilities.h"

#define FETCH_DESCRIPTION @"Fetch configuration"

@interface FileDownloadManager()

@property (nonatomic, strong) NSURLSession *fileDownloadSession;
@property (nonatomic, strong) NSURLSessionDownloadTask *singleDownloadTask;
@property (nonatomic, strong) NSData *resumeData;
@property (nonatomic, strong) NSDate *startDate;

@end

@implementation FileDownloadManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.copyDownloadedFilesToDD = YES;
        self.broadcastPendingDownloads = NO;
        self.singleDownloadTask = [[NSURLSessionDownloadTask alloc]init];
    }
    return self;
}

- (void)cancelDownload{

    [self.singleDownloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        NSLog(@"Resume Data: %@",resumeData);
        self.resumeData = resumeData;
        self.singleDownloadTask = nil;
    }];
}

- (void)resumeDownload{
    
    //Might have to check if the server has the support to resume the download.
    //http://stackoverflow.com/questions/18084677/determine-if-server-supports-resume-get-request
    
    self.singleDownloadTask = [self.fileDownloadSession downloadTaskWithResumeData:self.resumeData completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Download failed with error: %@", error.localizedDescription);
        } else {
            NSLog(@"Download succesful");
            NSLog(@"File downloaded at: %@",location);
            if (self.broadcastPendingDownloads) {
                [self broadcastPendingDownloadTasksCount];
            }
        }
    }];
    [self.singleDownloadTask resume];
}

- (void)downloadUsingBlock:(NSURL *)downloadURL
{
    if (!downloadURL) {
        NSLog(@"DownloadURL is nil");
        return;
    }
    
    NSDate *startTime = [NSDate date];
    NSLog(@"Download using block started...");
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:downloadURL];
    self.singleDownloadTask = [self.fileDownloadSession downloadTaskWithRequest:request
                                                    completionHandler:^(NSURL *localFile, NSURLResponse *response, NSError *error) {
                                                        if (error) {
                                                            NSLog(@"Download failed with error: %@", error.localizedDescription);
                                                        } else {
                                                            NSLog(@"Download succesful");
//                                                            NSLog(@"File downloaded at: %@",localFile);
                                                            
                                                            NSArray *filesArray = [Utilities getFilesFromDocumentsDirectory];
                                                            NSString *newFileName = [NSString stringWithFormat:@"DownloadedFile%d",[filesArray count]+1];
                                                            if (self.copyDownloadedFilesToDD) {
                                                                [Utilities copyFileToDocumentsFromURL:localFile withFileName:newFileName];
                                                            }
                                                            if (self.broadcastPendingDownloads) {
                                                                [self broadcastPendingDownloadTasksCount];
                                                            }
                                                        }
                                                        NSString *alertString = [NSString stringWithFormat:@"Executed in %.2fsecs",[[NSDate date] timeIntervalSinceDate:startTime]];
                                                        NSLog(@"Blocks: %@",alertString);

                                                    }];
    [self.singleDownloadTask resume];
}

- (void)downloadUsingDelegates:(NSArray *)downloadUrls
{
    

    if (self.startDate) {
        self.startDate = nil;
    }
    self.startDate = [NSDate date];
    
    static int taskID = 1;
    if (![downloadUrls count] ||(downloadUrls == nil)) {
        NSLog(@"Downloads Array is empty");
    }
    else {
        for(id url in downloadUrls)
        {
            NSURLSessionDownloadTask *task = [self.fileDownloadSession downloadTaskWithURL:url];
            task.taskDescription = [NSString stringWithFormat:@"TaskID-%d",taskID];
            taskID++;
            [task resume];
        }
    }
    if (self.broadcastPendingDownloads) {
        [self broadcastPendingDownloadTasksCount];
    }
}

- (NSURLSession *)fileDownloadSession
{
    if (!_fileDownloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
            urlSessionConfig.allowsCellularAccess = NO;
            urlSessionConfig.timeoutIntervalForRequest = 10.0;
            _fileDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig
                                                                 delegate:self
                                                            delegateQueue:nil];
        });
    }
    return _fileDownloadSession;
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)localFile
{
    NSLog(@"DidFinishDownloading task with ID %@",downloadTask.taskDescription);
    
    NSString *alertString = [NSString stringWithFormat:@"Executed in %.2fsecs",[[NSDate date] timeIntervalSinceDate:self.startDate]];
    NSLog(@"Delegates: %@",alertString);
    if (self.broadcastPendingDownloads) {
        [self broadcastPendingDownloadTasksCount];
    }
//    NSArray *filesArray = [Utilities getFilesFromDocumentsDirectory];
//    NSString *newFileName = [NSString stringWithFormat:@"DownloadedFile%d",[filesArray count]+1];
    if (self.copyDownloadedFilesToDD) {
        [Utilities copyFileToDocumentsFromURL:localFile withFileName:downloadTask.taskDescription];
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"Writing...%lld",totalBytesWritten);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error && (session == self.fileDownloadSession)) {
        NSLog(@"Download task failed: %@ for taskID: %@", error.localizedDescription,task.taskDescription);
        if (self.broadcastPendingDownloads) {
            [self broadcastPendingDownloadTasksCount];
        }
    }
}

- (void)broadcastPendingDownloadTasksCount
{
    [self.fileDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        NSDictionary *userInfo = @{DownloadCompleteNotificationContext: [NSNumber numberWithInt:[downloadTasks count]]};
        [[NSNotificationCenter defaultCenter] postNotificationName:DownloadCompleteNotification object:self userInfo:userInfo];
    }];
}

@end
