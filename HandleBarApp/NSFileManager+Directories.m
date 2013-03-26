//
//  NSFileManager+Directories.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 10-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "NSFileManager+Directories.h"

@implementation NSFileManager (Directories)

- (NSString *)getOrCreatePath:(NSString *)path {
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    if(![fileManager fileExistsAtPath:path])
        if(![fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL])
            NSLog(@"Error: Create folder failed %@", path);

    return path;
}

- (NSString *)applicationSupportFolder {
    
    NSArray *paths =
    NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                        NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:
                                                0] : NSTemporaryDirectory();
    NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    
    return [basePath
            stringByAppendingPathComponent:appName];
}

- (NSString *)copyFileToNewPath:(NSString *)originalPath dir:(NSString *)newDir {
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    NSString *newPath = [newDir stringByAppendingPathComponent:[originalPath lastPathComponent]];
    [fileManager moveItemAtPath:originalPath toPath:newPath error:nil];
    
    return newPath;
}

@end
