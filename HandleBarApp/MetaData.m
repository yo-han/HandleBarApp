//
//  MetaData.m
//  HandleBarApp
//
//  Created by Johan Kuijt on 15-03-13.
//  Copyright (c) 2013 Mustacherious. All rights reserved.
//

#import "MetaData.h"
#import "Movie.h"
#import "TVShow.h"
#import "Util.h"
#import "iTunes.h"
#import "NSFileManager+Directories.h"

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
    _artworkPath = @"";
    
    [self guessVideoData:sourcePath];
       
    _videoType = [self.guessedData objectForKey:@"type"];

    if(self.videoType == nil)
        return NO;

    if([self.videoType isEqual: kHBMovie]) {

        Movie *movie = [Movie getMovie:[self.guessedData objectForKey:@"title"] year:[self.guessedData objectForKey:@"year"]];
       
        if(movie.name == nil)
            return NO;
        
        _videoData = movie;        
        
        [self downloadArtwork:movie.image];
        
    } else {
        
        TVShow *tvShow = [TVShow getShow:self.guessedData];
        
        if(tvShow == nil)
            return NO;
        
        _videoData = tvShow;
        
        [self downloadArtwork:tvShow.image];
    }
    
    return YES;
}
        
- (void)downloadArtwork:(NSString *)image {
    
    Downloader *dl = [[Downloader alloc] init];
    dl.delegate = self;
    
    if(image != nil) {
        
        NSString *downloadPath = NSTemporaryDirectory();
        [dl downloadWithUrl:image path:downloadPath];
        
    } else {
        [self tagVideo];
    }
}
 
- (void)downloadDone:(NSString *)path {

    NSFileManager *fm = [[NSFileManager alloc] init];
    
    NSString *appSupportPath = [fm applicationSupportFolder];
    NSString *newPath = [appSupportPath stringByAppendingPathComponent:@"media/images"];
    
    NSString *artworkPath = [fm copyFileToNewPath:path dir:newPath];
    
    _artworkPath = artworkPath;
    
    [self tagVideo];
}

- (void)tagVideo {
    
    // Add the last missing data to the videoData object
    [self completeVideoData];
    
    NSString *currentPath = [[NSBundle mainBundle] bundlePath];
    NSString *cmd = [currentPath stringByAppendingPathComponent:@"Contents/Resources/SublerCLI"];
    NSString *subtitleLanguage = [[NSUserDefaults standardUserDefaults] objectForKey:@"SubtitleLanguage"];
    
    if(subtitleLanguage == nil)
        subtitleLanguage = @"English";
    
    NSString *metaData = [self.videoData getMetaStringWith:self.videoData];

    // -source needs the subtitle path later, when we are ready for it
    // @"-source", @""
    NSArray *args = [NSArray arrayWithObjects:@"-dest", self.sourcePath, @"-metadata", metaData, @"-language", subtitleLanguage, nil];

    [Util executeCommand:cmd args:args notifyStdOut:NO];
    
    [self copyToItunes:self.sourcePath];
}

- (void)copyToItunes:(NSString *)path {
    
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    iTunesTrack * track = [iTunes add:[NSArray arrayWithObject:[NSURL fileURLWithPath:path]] to:nil];
    
    NSLog(@"Added %@ to track: %@",path,track);
    NSLog(@"Debug mode: %d",[Util inDebugMode]);
    if(![Util inDebugMode]) {
        NSLog(@"Remove copy in coverted dir");
        [Util trashWithPath:path];
    } else {
        
        NSFileManager *fm = [NSFileManager defaultManager];
       
        NSString *debugRemovePath = [[fm applicationSupportFolder] stringByAppendingPathComponent:@"/media/done"];
        [fm copyFileToNewPath:path dir:debugRemovePath];
    }
}

- (void)completeVideoData {
    
    [_videoData setArtworkPath:self.artworkPath];
    [_videoData setSourcePath:self.sourcePath];

    if([[self.guessedData objectForKey:@"screenSize"] isEqualToString:@"1080p"] || [[self.guessedData objectForKey:@"screenSize"] isEqualToString:@"720p"])
        [_videoData setHd:[NSNumber numberWithBool:YES]];
}

- (void)guessVideoData:(NSString *)sourcePath {
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *scriptPath = [path stringByAppendingPathComponent:@"Contents/Resources/python/guess.py"];
    
    NSString *cmd = @"/usr/bin/python";
    NSArray *args = [NSArray arrayWithObjects:scriptPath, sourcePath, nil];
    
    NSDictionary *resp = [Util executeCommand:cmd args:args notifyStdOut:NO];
    NSString *json = [resp objectForKey:@"response"];
    
    if(json == nil)
        return;
    
    _guessedData = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:nil error:nil];
}

@end
