//
//  NSImage+Download.h
//  HandleBarApp
//
//  Created by Johan Kuijt on 20-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Downloader : NSObject <NSURLDownloadDelegate>

@property (nonatomic, strong) id delegate;

- (void)downloadWithUrl:(NSString *)url path:(NSString *)path;

@end

@protocol DownloaderDelegate

- (void)downloadDone:(NSString *)path;

@end
