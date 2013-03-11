//
//  NSFileManager+Directories.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 10-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Directories) 

- (NSString *)getOrCreatePath:(NSString *)path;
- (NSString *)applicationSupportFolder;

@end
