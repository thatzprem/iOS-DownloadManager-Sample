//
//  Utilities.h
//  BackgroundFetchTest
//
//  Created by Prem kumar on 25/03/14.
//  Copyright (c) 2014 happiestminds. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject

+ (NSArray *)getFilesFromDocumentsDirectory;

+ (void)copyFileToDocumentsFromURL:(NSURL *)localFile withFileName:(NSString *)newFileName;

+ (void)clearDocmentsDirectory;

@end
