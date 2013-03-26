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
@property(strong) NSString *artworkPath;
@property(strong) NSString *sourcePath;
@property(strong) NSString *videoType;
@property(strong) id videoData;

- (void)guessVideoData:(NSString *)sourcePath;

@end

@implementation MetaData

@synthesize guessedData=_guessedData;
@synthesize videoType=_videoType;
@synthesize videoData=_videoData;
@synthesize artworkPath=_artworkPath;
@synthesize sourcePath=_sourcePath;

- (BOOL)setMetadataInVideo:(NSString *)sourcePath {

    _sourcePath = sourcePath;
    
    [self guessVideoData:sourcePath];
    
    Downloader *dl = [[Downloader alloc] init];
    dl.delegate = self;
    
    _videoType = [self.guessedData objectForKey:@"type"];

    if(self.videoType == nil)
        return NO;

    if([self.videoType isEqual: kHBMovie]) {

        Movie *movie = [Movie getMovie:[self.guessedData objectForKey:@"title"] year:[self.guessedData objectForKey:@"year"]];

        _videoData = movie;
        
        NSString *downloadPath = NSTemporaryDirectory();
        [dl downloadWithUrl:movie.image path:downloadPath];
    }
    else {
        NSLog(@"Bazinga");
    }
    
    return YES;
}

- (void)downloadDone:(NSString *)path {
    
    _artworkPath = path;
    
    [self tagVideo];
}

- (void)tagVideo {
    
    // Add the last missing data to the videoData object
    [self completeVideoData];
    
    NSString *currentPath = [[NSBundle mainBundle] bundlePath];
    NSString *cmd = [currentPath stringByAppendingPathComponent:@"Contents/Resources/SublerCLI"];
    NSString *subtitleLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:@"SubtitleLanguage"];
    
    NSString *metaData = [self.videoData getMetaStringWith:self.videoData];
    
    // -source needs the subtitle path later, when we are ready for it
    NSArray *args = [NSArray arrayWithObjects:@"-dest", self.sourcePath, @"-source", @"", @"-metadata", metaData, @"-language", subtitleLanguage, nil];
    
    [Util executeCommand:cmd args:args];
}

- (void)completeVideoData {
    
    [_videoData setArtworkPath:self.artworkPath];
    [_videoData setSourcePath:self.sourcePath];
    
    if([[self.guessedData objectForKey:@"type"] isEqualToString:@"1080p"] || [[self.guessedData objectForKey:@"type"] isEqualToString:@"720p"])
        [_videoData setHd:YES];
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

@end
