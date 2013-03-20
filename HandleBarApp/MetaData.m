//
//  MetaData.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 15-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "MetaData.h"
#import "Movie.h"
#import "Util.h"

#define kHBMovie @"movie"
#define kHBTVShow @"episode"

@interface MetaData()

@property(strong) NSDictionary *guessedData;
@property(strong) NSString *videoType;
@property(strong) id videoData;

- (void)guessVideoData:(NSString *)sourcePath;

@end

@implementation MetaData

@synthesize guessedData=_guessedData;
@synthesize videoType=_videoType;
@synthesize videoData=_videoData;

- (BOOL)setMetadataInVideo:(NSString *)sourcePath {

    [self guessVideoData:sourcePath];
    
    _videoType = [self.guessedData objectForKey:@"type"];
    
    if(self.videoType == nil)
        return NO;

    if([self.videoType isEqual: kHBMovie])
        _videoData = [Movie getMovie:[self.guessedData objectForKey:@"title"] year:[self.guessedData objectForKey:@"year"]];
    else
        NSLog(@"Bazinga");
    
    [self downloadArtwork:@""];
    
    return YES;
}

- (void)tagVideo {
    
}

- (void)guessVideoData:(NSString *)sourcePath {
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *scriptPath = [path stringByAppendingPathComponent:@"Contents/Resources/HandleBar/guess.py"];
    
    NSString *cmd = @"/usr/bin/python";
    NSArray *args = [NSArray arrayWithObjects:scriptPath, sourcePath, nil];
    
    NSDictionary *resp = [Util executeCommand:cmd args:args];
    NSString *json = [resp objectForKey:@"response"];
    
    _guessedData = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:nil error:nil];
}

- (void)downloadArtwork:(NSString *)url
{
    // Create the request.
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]
                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                            timeoutInterval:60.0];
    
    NSURLDownload  *theDownload = [[NSURLDownload alloc] initWithRequest:theRequest delegate:self];
    if (!theDownload) {
        NSLog(@"not good"); // Inform the user that the download failed.
    }
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename
{
    NSString *destinationFilename;
    NSString *homeDirectory = NSHomeDirectory();
    
    destinationFilename = [[homeDirectory stringByAppendingPathComponent:@"Desktop"]
                           stringByAppendingPathComponent:filename];
    [download setDestination:destinationFilename allowOverwrite:NO];
}


- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{    
    // Inform the user.
    NSLog(@"Download failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
    
    // Do something with the data.
    NSLog(@"%@",@"downloadDidFinish");
}

@end
