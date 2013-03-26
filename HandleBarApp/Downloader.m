//
//  Downloader.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 20-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "Downloader.h"

@interface Downloader()

@property(strong) NSString *downloadPath;
@property(strong) NSString *downloadFilepath;

@end

@implementation Downloader

@synthesize delegate=_delegate;
@synthesize downloadPath=_downloadPath;
@synthesize downloadFilepath=_downloadFilepath;

- (void)downloadWithUrl:(NSString *)url path:(NSString *)path
{
    
    // Set the download path
    _downloadPath = path;
    
    // Create the request.
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:60.0];
    
    NSURLDownload  *theDownload = [[NSURLDownload alloc] initWithRequest:theRequest delegate:self];
    if (!theDownload) {
        NSLog(@"Downloader: Download failed at start");
        
        [self downloadDone:nil];
    }
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename
{
    NSString *destinationFilename;
    
    destinationFilename = [self.downloadPath stringByAppendingPathComponent:filename];

    _downloadFilepath = destinationFilename;
    
    [download setDestination:destinationFilename allowOverwrite:NO];
}


- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
    // Inform the user.
    NSLog(@"Download failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    [self downloadDone:nil];
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
    [self downloadDone:download];
}

- (void)downloadDone:(NSURLDownload *)download {
    
    if(_delegate && [_delegate respondsToSelector:@selector(downloadDone:)]) {
        [_delegate downloadDone:self.downloadFilepath];
    }
}

@end
