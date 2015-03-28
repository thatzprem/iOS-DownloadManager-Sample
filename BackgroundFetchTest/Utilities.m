//
//  Utilities.m
//  BackgroundFetchTest
//
//  Created by Prem kumar on 25/03/14.
//  Copyright (c) 2014 happiestminds. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

+ (NSArray *)getFilesFromDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsPath error:NULL];
    return directoryContent;
}

+ (void)copyFileToDocumentsFromURL:(NSURL *)localFile withFileName:(NSString *)newFileName
{
    dispatch_queue_t queue;
    queue = dispatch_queue_create("FileOperationQueue", NULL);
    dispatch_sync(queue, ^{
        NSData *data = [NSData dataWithContentsOfURL:localFile];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSString *filePath = [documentsPath stringByAppendingPathComponent:newFileName];
        [data writeToFile:filePath atomically:YES];
    });
}

+ (void)clearDocmentsDirectory
{
    NSString *folderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSError *error = nil;
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:&error]) {
        [[NSFileManager defaultManager] removeItemAtPath:[folderPath stringByAppendingPathComponent:file] error:&error];
    }
}

@end
